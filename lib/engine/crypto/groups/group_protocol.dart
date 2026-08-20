import 'package:cryptography/cryptography.dart';

import 'group_key.dart';
import 'group_key_envelope.dart';
import 'group_key_rotation.dart';
import 'group_message.dart';

class GroupProtocol {
  GroupProtocol._();

  // ------------------------------------------------------------
  // KEY GENERATION
  // ------------------------------------------------------------

  /// Generate a completely new group key.
  static Future<String> createGroupKey() {
    return GroupKey.generate();
  }

  // ------------------------------------------------------------
  // MEMBER KEY DISTRIBUTION
  // ------------------------------------------------------------

  /// Encrypt a group key for one member.
  static Future<GroupKeyEnvelope> prepareMemberKey({
    required String memberId,
    required List<int> memberPublicKey,
    required String groupKey,
  }) {
    return GroupKeyEnvelopeCrypto.encryptForMember(
      recipientId: memberId,
      recipientPublicKey: memberPublicKey,
      groupKey: groupKey,
    );
  }

  /// Recover a group key from an encrypted envelope.
  static Future<String> recoverMemberKey({
    required GroupKeyEnvelope envelope,
    required SimpleKeyPair memberPrivateKey,
  }) {
    return GroupKeyEnvelopeCrypto.decryptEnvelope(
      envelope: envelope,
      recipientPrivateKey: memberPrivateKey,
    );
  }

  // ------------------------------------------------------------
  // ROTATION
  // ------------------------------------------------------------

  /// Prepare a new group-key rotation.
  ///
  /// This:
  ///
  /// 1. Generates a new random key.
  /// 2. Encrypts it separately for every member.
  /// 3. Creates a key commitment.
  /// 4. Signs the complete rotation.
  ///
  /// The caller stores the new key locally as `newPrivateKey`
  /// and uses [effectiveAt] as `swapTime`.
  static Future<GroupRotationResult> createRotation({
    required String groupId,
    required int keyVersion,
    required int effectiveAt,
    required List<GroupMemberPublicKey> members,
    required SimpleKeyPair adminSigningKey,
  }) async {
    final newKey = await GroupKey.generate();

    final envelopes = <GroupKeyEnvelope>[];

    for (final member in members) {
      final envelope =
          await GroupKeyEnvelopeCrypto.encryptForMember(
        recipientId: member.memberId,
        recipientPublicKey: member.publicKey,
        groupKey: newKey,
      );

      envelopes.add(envelope);
    }

    final commitment =
        await GroupKeyRotationCrypto.commitment(newKey);

    final signature =
        await GroupKeyRotationCrypto.signRotation(
      groupId: groupId,
      keyVersion: keyVersion,
      effectiveAt: effectiveAt,
      keyCommitment: commitment,
      envelopes: envelopes,
      adminSigningKey: adminSigningKey,
    );

    final rotation = GroupKeyRotation(
      groupId: groupId,
      keyVersion: keyVersion,
      effectiveAt: effectiveAt,
      keyCommitment: commitment,
      envelopes: envelopes,
      signature: signature,
    );

    return GroupRotationResult(
      newGroupKey: newKey,
      rotation: rotation,
    );
  }

  // ------------------------------------------------------------
  // MESSAGE ENCRYPTION
  // ------------------------------------------------------------

  /// Encrypt a group message using the currently active key.
  static Future<GroupEncryptedMessage> encryptMessage({
    required String messageId,
    required String conversationId,
    required String senderId,
    required int messageOrder,
    required int keyVersion,
    required int timestamp,
    required String plaintext,
    required String groupKey,
  }) {
    return GroupMessageCrypto.encrypt(
      messageId: messageId,
      conversationId: conversationId,
      senderId: senderId,
      messageOrder: messageOrder,
      keyVersion: keyVersion,
      timestamp: timestamp,
      plaintext: plaintext,
      groupKey: groupKey,
    );
  }

  /// Decrypt a group message.
  static Future<String> decryptMessage({
    required GroupEncryptedMessage message,
    required String groupKey,
  }) {
    return GroupMessageCrypto.decrypt(
      message: message,
      groupKey: groupKey,
    );
  }
}

/// Public key belonging to one group member.
///
/// This is the X25519 public key used to wrap the group key.
class GroupMemberPublicKey {
  final String memberId;
  final List<int> publicKey;

  const GroupMemberPublicKey({
    required this.memberId,
    required this.publicKey,
  });
}

/// Result returned after preparing a key rotation.
class GroupRotationResult {
  /// The plaintext symmetric key that the admin stores as
  /// `newPrivateKey` in the encrypted SQLite database.
  final String newGroupKey;

  /// Signed rotation packet sent to the group/server.
  final GroupKeyRotation rotation;

  const GroupRotationResult({
    required this.newGroupKey,
    required this.rotation,
  });
}