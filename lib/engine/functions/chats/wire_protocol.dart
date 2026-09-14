// module name: wire_protocol
//
// The v1 wire protocol shared by every chat message type module. Two
// carriers exist:
//
//   * encrypted  — the `message` field is a JSON object
//                  { v, chain_index, ciphertext, nonce, mac, sender_sequence }
//                  produced by NullCrypto.encryptMessage(). Same envelope as
//                  type 1 (01_send_message.dart / recieve_message.dart).
//   * control    — the `message` field is a JSON [ControlEnvelope]
//                  { v, ts, seq, kind, payload }. Ephemeral, never touches
//                  the ratchet, never persisted (like handshake type 0).
//
// AAD is bound to the canonical utf-8 bytes of the conversationId for both
// carriers, matching the existing type-1 behaviour.

import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart';

import '../../crypto/chat/null_crypto.dart';
import '../../database/app_database.dart';
import '../../database/queries/messages_queries.dart';
import '../../database/queries/sessions_queries.dart';
import 'message_types.dart';

/// Bumped whenever a breaking change is made to an encrypted wire payload.
const int kProtocolVersion = 1;

/// Version inside plaintext control envelopes.
const int kControlEnvelopeVersion = 1;

/// AAD used for every post-handshake AEAD operation. Must stay in sync with
/// message type 1: the conversationId is used verbatim.
List<int> messageAad(String conversationId) => utf8.encode(conversationId);

/// Encrypts [plaintext] with the conversation ratchet and returns the JSON
/// object that becomes the wire `message` field. AAD = conversationId.
Future<Map<String, dynamic>> buildEncryptedWirePayload(
  NullCrypto crypto, {
  required String conversationId,
  required String plaintext,
  required int senderSequence,
}) async {
  final encrypted = await crypto.encryptMessage(
    conversationId: conversationId,
    plaintext: plaintext,
    aad: messageAad(conversationId),
  );
  return {
    'v': kProtocolVersion,
    'chain_index': encrypted.chainIndex,
    'ciphertext': base64UrlEncode(encrypted.ciphertext),
    'nonce': base64UrlEncode(encrypted.nonce),
    'mac': base64UrlEncode(encrypted.mac),
    'sender_sequence': senderSequence,
  };
}

/// Decrypts a raw `message` field produced by [buildEncryptedWirePayload]
/// and returns the JSON payload inside it. This advances the receiving
/// ratchet (or consumes a skipped key), exactly like type 1.
Future<Map<String, dynamic>> decryptEncryptedWirePayload(
  NullCrypto crypto, {
  required String conversationId,
  required String rawMessage,
}) async {
  final decoded = jsonDecode(rawMessage) as Map<String, dynamic>;
  final wireVersion = decoded['v'] as int? ?? kProtocolVersion;
  if (wireVersion != kProtocolVersion) {
    throw StateError('Unsupported encrypted wire version $wireVersion.');
  }

  final plaintext = await crypto.decryptMessage(
    conversationId: conversationId,
    chainIndex: decoded['chain_index'] as int,
    ciphertext: Uint8List.fromList(
      base64Url.decode(decoded['ciphertext'] as String),
    ),
    nonce: Uint8List.fromList(
      base64Url.decode(decoded['nonce'] as String),
    ),
    mac: Uint8List.fromList(base64Url.decode(decoded['mac'] as String)),
    aad: messageAad(conversationId),
  );

  return jsonDecode(plaintext) as Map<String, dynamic>;
}

/// Plaintext envelope for ephemeral / control message types. Signed
/// implicitly by the server's sender attribution; never advances the
/// ratchet, so high-frequency events (typing, receipts, signaling) do not
/// burn through the skipped-key budget.
class ControlEnvelope {
  const ControlEnvelope({
    required this.kind,
    required this.payload,
    this.version = kControlEnvelopeVersion,
    this.sequence = 0,
    this.timestamp,
  });

  final int version;
  final String kind;
  final Map<String, dynamic> payload;
  final int sequence;
  final int? timestamp;

  Map<String, dynamic> toJson() => {
        'v': version,
        'ts': timestamp ?? DateTime.now().millisecondsSinceEpoch,
        'seq': sequence,
        'kind': kind,
        'payload': payload,
      };

  String encode() => jsonEncode(toJson());

  factory ControlEnvelope.decode(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return ControlEnvelope(
      version: json['v'] as int? ?? kControlEnvelopeVersion,
      timestamp: json['ts'] as int?,
      sequence: json['seq'] as int? ?? 0,
      kind: json['kind'] as String? ?? '<unknown>',
      payload: (json['payload'] as Map<String, dynamic>?) ?? const {},
    );
  }

  @override
  String toString() => 'ControlEnvelope(kind: $kind, seq: $sequence)';
}

/// Metadata that accompanies every incoming message, mirrors the useful
/// fields of the server's `QueuedMessage`/`MessageEmit` shape.
class IncomingContext {
  const IncomingContext({
    required this.senderContactId,
    required this.conversationId,
    required this.messageId,
    required this.logicalId,
    required this.messageOrder,
    required this.senderSequence,
    required this.rawMessage,
    this.serverId,
    this.protocolVersion = kProtocolVersion,
    this.timestamp = 0,
  });

  final String senderContactId;
  final String conversationId;
  final String messageId;
  final String logicalId;
  final int messageOrder;
  final int senderSequence;

  /// The raw `message` field as received off the wire (encrypted wire JSON
  /// for content types, plaintext [ControlEnvelope] JSON for control types).
  final String rawMessage;
  final String? serverId;
  final int protocolVersion;
  final int timestamp;
}

/// What a receive handler did with an incoming message. `detail` carries
/// the parsed payload so the SSE wiring (main isolate) can turn the event
/// into UI feedback without re-parsing.
class IncomingMessageResult {
  const IncomingMessageResult({
    required this.type,
    required this.handled,
    required this.messageId,
    this.detail,
    this.reason,
  });

  final MessageType type;
  final bool handled;
  final String messageId;
  final dynamic detail;
  final String? reason;

  @override
  String toString() =>
      'IncomingMessageResult(${type.name}, handled: $handled)';
}

/// Ensures the receiving ratchet exists for [conversationId]. In this
/// protocol the local user is always the handshake initiator, so the
/// receiving chain is the responder chain — established state is created
/// with `initiator: true`, matching the sender-side guard.
Future<void> ensureRatchetReady(
  NullCrypto crypto,
  SessionsDao sessionsDao,
  String conversationId,
) async {
  if (await crypto.ratchetStore.loadState(conversationId) != null) return;
  final session = await sessionsDao.getSessionByConversationId(conversationId);
  final sharedSecret = session?.symmetricKey;
  if (sharedSecret == null) {
    throw StateError(
      'No symmetric key available to initialize the ratchet for '
      '$conversationId.',
    );
  }
  await crypto.establishConversation(
    conversationId: conversationId,
    sharedSecret: sharedSecret,
    initiator: true,
  );
}

/// Decrypts an incoming encrypted `message` field, initializing the ratchet
/// first if it does not exist yet on this device.
Future<Map<String, dynamic>> decryptContentPayload(
  NullCrypto crypto,
  SessionsDao sessionsDao, {
  required String conversationId,
  required String rawMessage,
}) async {
  await ensureRatchetReady(crypto, sessionsDao, conversationId);
  return decryptEncryptedWirePayload(
    crypto,
    conversationId: conversationId,
    rawMessage: rawMessage,
  );
}

/// Persists an already-decrypted content message into the `Messages` table.
/// [rawMessage] must be the same encrypted wire JSON that was received so
/// ciphertext/nonce/mac/chainIndex can be reconstructed for resend/sync.
/// Returns the fully populated [Message] row, or null if it could not be
/// decoded (in which case a metadata-only row is still written).
Future<void> storeDecryptedContent(
  MessagesDao messagesDao, {
  required String conversationId,
  required String senderId,
  required IncomingContext ctx,
  required MessageType type,
  required Map<String, dynamic> payload,
  required String rawMessage,
  String? replyTo,
  int edited = 0,
  int status = 0,
  int receivedAt = 0,
}) async {
  final now = DateTime.now().millisecondsSinceEpoch;
  final decoded = jsonDecode(rawMessage) as Map<String, dynamic>;
  final chainIndex = (decoded['chain_index'] as int?) ?? ctx.messageOrder;
  final hasCipher = decoded['ciphertext'] is String;

  final companion = MessagesCompanion.insert(
    messageId: ctx.messageId,
    logicalMessageId: ctx.logicalId,
    conversationId: conversationId,
    senderId: senderId,
    senderSequence: ctx.senderSequence,
    messageOrder: chainIndex,
    chainIndex: chainIndex,
    timestamp: now,
    ciphertext: hasCipher
        ? Uint8List.fromList(
            base64Url.decode(decoded['ciphertext'] as String),
          )
        : Uint8List(0),
    nonce: decoded['nonce'] is String
        ? Uint8List.fromList(base64Url.decode(decoded['nonce'] as String))
        : Uint8List(0),
    mac: decoded['mac'] is String
        ? Uint8List.fromList(base64Url.decode(decoded['mac'] as String))
        : Uint8List(0),
    decryptedMessage: Value(jsonEncode(payload)),
    messageType: type.value,
    replyTo: Value(replyTo),
    edited: Value(edited),
    status: status,
    keyVersion: 1,
    protocolVersion: Value(kProtocolVersion),
    receivedAt: Value(receivedAt > 0 ? receivedAt : now),
  );

  await messagesDao.insertMessage(companion);
}