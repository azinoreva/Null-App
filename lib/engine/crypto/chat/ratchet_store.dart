import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'crypto_types.dart';

class RatchetStore {
  final FlutterSecureStorage storage;

  const RatchetStore({
    this.storage = const FlutterSecureStorage(),
  });

  String _stateKey(String conversationId) =>
      'conversation:$conversationId:ratchet';

  String _skippedKey(String conversationId) =>
      'conversation:$conversationId:skipped';

  Future<void> saveState(
    String conversationId,
    RatchetState state,
  ) async {
    final data = {
      'root': base64UrlEncode(state.rootKey),
      'send': base64UrlEncode(
        state.sendingChainKey,
      ),
      'receive': base64UrlEncode(
        state.receivingChainKey,
      ),
      'sendIndex': state.sendingIndex,
      'receiveIndex': state.receivingIndex,
    };

    await storage.write(
      key: _stateKey(conversationId),
      value: jsonEncode(data),
    );
  }

  Future<RatchetState?> loadState(
    String conversationId,
  ) async {
    final raw = await storage.read(
      key: _stateKey(conversationId),
    );

    if (raw == null) return null;

    final data =
        jsonDecode(raw) as Map<String, dynamic>;

    return RatchetState(
      rootKey: Uint8List.fromList(
        base64Url.decode(data['root']),
      ),
      sendingChainKey: Uint8List.fromList(
        base64Url.decode(data['send']),
      ),
      receivingChainKey: Uint8List.fromList(
        base64Url.decode(data['receive']),
      ),
      sendingIndex: data['sendIndex'],
      receivingIndex: data['receiveIndex'],
    );
  }

  Future<Map<int, Uint8List>> loadSkipped(
    String conversationId,
  ) async {
    final raw = await storage.read(
      key: _skippedKey(conversationId),
    );

    if (raw == null) return {};

    final data =
        jsonDecode(raw) as Map<String, dynamic>;

    return data.map(
      (key, value) => MapEntry(
        int.parse(key),
        Uint8List.fromList(
          base64Url.decode(value),
        ),
      ),
    );
  }

  Future<void> saveSkipped(
    String conversationId,
    Map<int, Uint8List> skipped,
  ) async {
    final data = <String, String>{};

    for (final entry in skipped.entries) {
      data[entry.key.toString()] =
          base64UrlEncode(entry.value);
    }

    await storage.write(
      key: _skippedKey(conversationId),
      value: jsonEncode(data),
    );
  }

  Future<void> deleteConversation(
    String conversationId,
  ) async {
    await storage.delete(
      key: _stateKey(conversationId),
    );

    await storage.delete(
      key: _skippedKey(conversationId),
    );
  }
}