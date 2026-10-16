import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';

import '../../engine/functions/settings/categories.dart';

/// Runs the MiniLM ONNX encoder and compares an update to selected category
/// descriptions. The ONNX model is an embedding model, so category matching is
/// performed with cosine similarity rather than a classification head.
class FilterModel {
  FilterModel._();

  static final FilterModel instance = FilterModel._();

  final Map<int, Completer<bool>> _pending = {};
  Isolate? _isolate;
  SendPort? _workerPort;
  Future<void>? _starting;
  int _nextRequestId = 0;

  ReceivePort? _responsePort;
  ReceivePort? _errorPort;
  ReceivePort? _exitPort;

  Future<bool> matchesSelectedCategory(
    String text,
    Iterable<Categories> selected,
  ) async {
    final descriptions = selected.map(_categoryDescription).toList(growable: false);
    if (text.trim().isEmpty || descriptions.isEmpty) return false;

    await _ensureWorker();
    final requestId = _nextRequestId++;
    final completer = Completer<bool>();
    _pending[requestId] = completer;
    _workerPort!.send({
      'id': requestId,
      'text': text,
      'categories': descriptions,
    });
    return completer.future;
  }

  String _categoryDescription(Categories category) =>
      category.subcategories.isEmpty
      ? category.label
      : '${category.label}: ${category.subcategories.join(', ')}';

  Future<void> _ensureWorker() async {
    if (_workerPort != null) return;
    final starting = _starting;
    if (starting != null) {
      await starting;
      return;
    }
    final newStarting = _startWorker();
    _starting = newStarting;
    try {
      await newStarting;
    } finally {
      if (identical(_starting, newStarting)) _starting = null;
    }
  }

  Future<void> _startWorker() async {
    final rootToken = RootIsolateToken.instance;
    if (rootToken == null) {
      throw StateError('The feed filter must be started from the root isolate.');
    }

    final readyPort = ReceivePort();
    final responsePort = ReceivePort();
    final errorPort = ReceivePort();
    final exitPort = ReceivePort();
    _responsePort = responsePort;
    _errorPort = errorPort;
    _exitPort = exitPort;

    responsePort.listen(_handleWorkerResponse);
    errorPort.listen((error) => _failPending('ONNX worker failed: $error'));
    exitPort.listen((_) {
      _isolate = null;
      _workerPort = null;
      _failPending('ONNX worker exited.');
    });

    final ready = Completer<SendPort>();
    readyPort.listen((message) {
      if (message is SendPort && !ready.isCompleted) ready.complete(message);
    });

    try {
      _isolate = await Isolate.spawn<_WorkerBootstrap>(
        _onnxFilterWorker,
        _WorkerBootstrap(rootToken, readyPort.sendPort, responsePort.sendPort),
        onError: errorPort.sendPort,
        onExit: exitPort.sendPort,
      );
      _workerPort = await ready.future.timeout(const Duration(seconds: 20));
    } catch (_) {
      _isolate?.kill(priority: Isolate.immediate);
      _isolate = null;
      _workerPort = null;
      _responsePort?.close();
      _errorPort?.close();
      _exitPort?.close();
      _responsePort = null;
      _errorPort = null;
      _exitPort = null;
      rethrow;
    } finally {
      readyPort.close();
    }
  }

  void _handleWorkerResponse(dynamic message) {
    if (message is! Map) return;
    final id = message['id'];
    if (id is! int) return;
    final completer = _pending.remove(id);
    if (completer == null || completer.isCompleted) return;
    completer.complete(message['matches'] == true);
  }

  void _failPending(String reason) {
    for (final completer in _pending.values) {
      if (!completer.isCompleted) completer.completeError(StateError(reason));
    }
    _pending.clear();
  }
}

class _WorkerBootstrap {
  const _WorkerBootstrap(this.rootToken, this.readyPort, this.responsePort);

  final RootIsolateToken rootToken;
  final SendPort readyPort;
  final SendPort responsePort;
}

void _onnxFilterWorker(_WorkerBootstrap bootstrap) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(bootstrap.rootToken);
  final requests = ReceivePort();
  bootstrap.readyPort.send(requests.sendPort);
  final inference = _OnnxCategoryEncoder();

  await for (final message in requests) {
    if (message is! Map) continue;
    final id = message['id'];
    final text = message['text'];
    final categories = message['categories'];
    if (id is! int || text is! String || categories is! List<String>) continue;
    try {
      final matches = await inference.matchesAny(text, categories);
      bootstrap.responsePort.send({'id': id, 'matches': matches});
    } catch (error) {
      bootstrap.responsePort.send({'id': id, 'matches': false, 'error': '$error'});
    }
  }
}

/// Owns the model and tokenizer inside the worker isolate.
class _OnnxCategoryEncoder {
  _OnnxCategoryEncoder();

  static const String modelAsset = 'lib/ai_algorithm/model.onnx';
  static const String modelConfigAsset = 'lib/ai_algorithm/config.json';
  static const String vocabAsset = 'lib/ai_algorithm/vocab.txt';
  static const String tokenizerAsset = 'lib/ai_algorithm/tokenizer.json';
  static const String tokenizerConfigAsset =
      'lib/ai_algorithm/tokenizer_config.json';
  static const String specialTokensAsset =
      'lib/ai_algorithm/special_tokens_map.json';
  static const double minimumSimilarity = 0.35;

  final OnnxRuntime _runtime = OnnxRuntime();
  final Map<String, List<double>> _categoryEmbeddings = {};

  OrtSession? _session;
  Map<String, int>? _vocabulary;
  int _maxLength = 128;
  int _expectedHiddenSize = 384;
  int _clsTokenId = 101;
  int _sepTokenId = 102;
  int _padTokenId = 0;
  int _unknownTokenId = 100;

  Future<bool> matchesAny(String text, List<String> categoryDescriptions) async {
    if (text.trim().isEmpty || categoryDescriptions.isEmpty) return false;

    final textEmbedding = await _embed(text);
    var bestSimilarity = double.negativeInfinity;
    for (final description in categoryDescriptions) {
      final candidate = _categoryEmbeddings.putIfAbsent(
        description,
        () => <double>[],
      );
      if (candidate.isEmpty) {
        _categoryEmbeddings[description] = await _embed(description);
      }
      final similarity = _cosineSimilarity(
        textEmbedding,
        _categoryEmbeddings[description]!,
      );
      if (similarity > bestSimilarity) bestSimilarity = similarity;
    }
    return bestSimilarity >= minimumSimilarity;
  }

  Future<List<double>> _embed(String text) async {
    await _ensureLoaded();
    final session = _session!;
    final encoded = _encode(text);
    final inputs = <String, OrtValue>{};
    final outputs = <String, OrtValue>{};
    try {
      for (final name in session.inputNames) {
        final normalizedName = name.toLowerCase();
        final values = normalizedName.contains('mask')
            ? encoded.attentionMask
            : normalizedName.contains('token_type') ||
                  normalizedName.contains('segment')
            ? encoded.tokenTypeIds
            : encoded.inputIds;
        inputs[name] = await OrtValue.fromList(
          Int64List.fromList(values),
          [1, _maxLength],
        );
      }

      outputs.addAll(await session.run(inputs));
      if (outputs.isEmpty) {
        throw StateError('The ONNX model returned no outputs.');
      }

      final outputName = session.outputNames.firstWhere(
        (name) => name.toLowerCase().contains('sentence_embedding'),
        orElse: () => session.outputNames.first,
      );
      final output = outputs[outputName]!;
      final flattened = (await output.asFlattenedList())
          .map((value) => (value as num).toDouble())
          .toList(growable: false);
      final shape = output.shape;

      List<double> vector;
      if (shape.length >= 3) {
        final sequenceLength = shape[shape.length - 2];
        final hiddenSize = shape.last;
        vector = List<double>.filled(hiddenSize, 0);
        var tokenCount = 0;
        for (var token = 0;
            token < sequenceLength && token < encoded.attentionMask.length;
            token++) {
          if (encoded.attentionMask[token] == 0) continue;
          tokenCount++;
          for (var dimension = 0; dimension < hiddenSize; dimension++) {
            vector[dimension] +=
                flattened[token * hiddenSize + dimension];
          }
        }
        if (tokenCount == 0) return vector;
        for (var i = 0; i < vector.length; i++) {
          vector[i] /= tokenCount;
        }
      } else {
        final hiddenSize = shape.isEmpty ? flattened.length : shape.last;
        vector = flattened.take(hiddenSize).toList(growable: false);
      }
      if (vector.length != _expectedHiddenSize) {
        throw StateError(
          'Expected an embedding of size $_expectedHiddenSize, got ${vector.length}.',
        );
      }
      return _normalize(vector);
    } finally {
      for (final value in inputs.values) {
        await value.dispose();
      }
      for (final value in outputs.values) {
        await value.dispose();
      }
    }
  }

  Future<void> _ensureLoaded() async {
    if (_session != null && _vocabulary != null) return;
    final modelConfig = jsonDecode(await rootBundle.loadString(modelConfigAsset))
        as Map<String, dynamic>;
    _expectedHiddenSize =
        (modelConfig['hidden_size'] as num?)?.toInt() ?? _expectedHiddenSize;
    final config = jsonDecode(await rootBundle.loadString(tokenizerConfigAsset))
        as Map<String, dynamic>;
    _maxLength = (config['max_length'] as num?)?.toInt() ?? 128;
    final vocab = await rootBundle.loadString(vocabAsset);
    final vocabulary = <String, int>{
      for (final entry in vocab.split('\n').asMap().entries)
        if (entry.value.trim().isNotEmpty) entry.value.trim(): entry.key,
    };
    final tokenizer = jsonDecode(await rootBundle.loadString(tokenizerAsset))
        as Map<String, dynamic>;
    for (final token in tokenizer['added_tokens'] as List<dynamic>? ?? const []) {
      if (token is Map<String, dynamic>) {
        final content = token['content'];
        final id = token['id'];
        if (content is String && id is num) {
          vocabulary[content] = id.toInt();
        }
      }
    }
    final specialTokens =
        jsonDecode(await rootBundle.loadString(specialTokensAsset))
            as Map<String, dynamic>;
    _clsTokenId = _specialTokenId(specialTokens, 'cls_token', vocabulary, 101);
    _sepTokenId = _specialTokenId(specialTokens, 'sep_token', vocabulary, 102);
    _padTokenId = _specialTokenId(specialTokens, 'pad_token', vocabulary, 0);
    _unknownTokenId =
        _specialTokenId(specialTokens, 'unk_token', vocabulary, 100);
    _vocabulary = vocabulary;
    _session = await _runtime.createSessionFromAsset(modelAsset);
  }

  int _specialTokenId(
    Map<String, dynamic> specialTokens,
    String key,
    Map<String, int> vocabulary,
    int fallback,
  ) {
    final token = specialTokens[key];
    final content = token is Map ? token['content'] : token;
    return content is String ? vocabulary[content] ?? fallback : fallback;
  }

  _EncodedText _encode(String text) {
    final vocabulary = _vocabulary!;
    final ids = <int>[_clsTokenId];
    final words = _basicTokens(text);
    for (final word in words) {
      ids.addAll(_wordPiece(word, vocabulary));
      if (ids.length >= _maxLength - 1) break;
    }
    if (ids.length > _maxLength - 1) {
      ids.removeRange(_maxLength - 1, ids.length);
    }
    ids.add(_sepTokenId);
    final attentionMask = List<int>.filled(_maxLength, 0);
    for (var i = 0; i < ids.length; i++) {
      attentionMask[i] = 1;
    }
    final inputIds = List<int>.filled(_maxLength, _padTokenId);
    inputIds.setRange(0, ids.length, ids);
    return _EncodedText(
      inputIds: inputIds,
      attentionMask: attentionMask,
      tokenTypeIds: List<int>.filled(_maxLength, 0),
    );
  }

  List<String> _basicTokens(String text) {
    final normalized = text
        .toLowerCase()
        .replaceAll(RegExp(r'[\u0000-\u001f]'), ' ')
        .replaceAll(RegExp(r'[\u0300-\u036f]'), '');
    return RegExp(r'[A-Za-z0-9]+|[^\sA-Za-z0-9]', unicode: true)
        .allMatches(normalized)
        .map((match) => match.group(0)!)
        .toList(growable: false);
  }

  List<int> _wordPiece(String word, Map<String, int> vocabulary) {
    if (word.runes.length > 100) return [_unknownTokenId];
    final runes = word.runes.toList(growable: false);
    final pieces = <int>[];
    var start = 0;
    while (start < runes.length) {
      var end = runes.length;
      int? pieceId;
      while (start < end) {
        final piece = String.fromCharCodes(runes.sublist(start, end));
        final token = start == 0 ? piece : '##$piece';
        pieceId = vocabulary[token];
        if (pieceId != null) break;
        end--;
      }
      if (pieceId == null) return [_unknownTokenId];
      pieces.add(pieceId);
      start = end;
    }
    return pieces;
  }

  List<double> _normalize(List<double> values) {
    final norm = math.sqrt(values.fold<double>(0, (sum, value) => sum + value * value));
    if (norm == 0) return values;
    return values.map((value) => value / norm).toList(growable: false);
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length || a.isEmpty) return -1;
    var sum = 0.0;
    for (var i = 0; i < a.length; i++) {
      sum += a[i] * b[i];
    }
    return sum;
  }
}

class _EncodedText {
  const _EncodedText({
    required this.inputIds,
    required this.attentionMask,
    required this.tokenTypeIds,
  });

  final List<int> inputIds;
  final List<int> attentionMask;
  final List<int> tokenTypeIds;
}
