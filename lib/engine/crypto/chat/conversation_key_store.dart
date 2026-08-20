import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'crypto_types.dart';

class ConversationKeyStore {
  final FlutterSecureStorage storage;

  const ConversationKeyStore({
    this.storage = const FlutterSecureStorage(),
  });

  String _rootKeyName(String conversationId) =>
      'conversation:$conversationId:root';

  String _stateName(String conversationId) =>
      'conversation:$conversationId:ratchet';

  /// Stores the root key for a conversation.
  Future<void> saveRootKey(
    String conversationId,
    Uint8List rootKey,
  ) async {
    if (rootKey.length != 32) {
      throw ArgumentError('Root key must be 32 bytes.');
    }

    await storage.write(
      key: _rootKeyName(conversationId),
      value: base64UrlEncode(rootKey),
    );
  }

  Future<Uint8List?> loadRootKey(
    String conversationId,
  ) async {
    final value = await storage.read(
      key: _rootKeyName(conversationId),
    );

    if (value == null) {
      return null;
    }

    return Uint8List.fromList(base64Url.decode(value));
  }

  Future<void> deleteConversation(
    String conversationId,
  ) async {
    await storage.delete(
      key: _rootKeyName(conversationId),
    );

    await storage.delete(
      key: _stateName(conversationId),
    );
  }

  /// Stores the complete current ratchet state.
  ///
  /// The entire state is encoded into one Secure Storage value so that
  /// updates are atomic at the application level.
  Future<void> saveRatchetState(
    String conversationId,
    RatchetState state,
  ) async {
    final object = <String, dynamic>{
      'root': base64UrlEncode(state.rootKey),
      'send': base64UrlEncode(state.sendingChainKey),
      'receive': base64UrlEncode(state.receivingChainKey),
      'sendIndex': state.sendingIndex,
      'receiveIndex': state.receivingIndex,
    };

    await storage.write(
      key: _stateName(conversationId),
      value: jsonEncode(object),
    );
  }

  Future<RatchetState?> loadRatchetState(
    String conversationId,
  ) async {
    final value = await storage.read(
      key: _stateName(conversationId),
    );

    if (value == null) {
      return null;
    }

    final object = jsonDecode(value) as Map<String, dynamic>;

    return RatchetState(
      rootKey: Uint8List.fromList(
        base64Url.decode(object['root'] as String),
      ),
      sendingChainKey: Uint8List.fromList(
        base64Url.decode(object['send'] as String),
      ),
      receivingChainKey: Uint8List.fromList(
        base64Url.decode(object['receive'] as String),
      ),
      sendingIndex: object['sendIndex'] as int,
      receivingIndex: object['receiveIndex'] as int,
    );
  }
}