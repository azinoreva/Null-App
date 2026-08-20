import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import 'group_key.dart';
import 'group_key_envelope.dart';

class GroupKeyRotation {
  final String groupId;
  final int keyVersion;
  final int effectiveAt;

  /// SHA-256 hash of the new group key.
  final String keyCommitment;

  final List<GroupKeyEnvelope> envelopes;

  /// Admin Ed25519 signature.
  final String signature;

  const GroupKeyRotation({
    required this.groupId,
    required this.keyVersion,
    required this.effectiveAt,
    required this.keyCommitment,
    required this.envelopes,
    required this.signature,
  });

  Map<String, dynamic> toJson() {
    return {
      'version': 1,
      'type': 'group_key_rotation',
      'groupId': groupId,
      'keyVersion': keyVersion,
      'effectiveAt': effectiveAt,
      'keyCommitment': keyCommitment,
      'envelopes':
          envelopes.map((e) => e.toJson()).toList(),
      'signature': signature,
    };
  }

  factory GroupKeyRotation.fromJson(
    Map<String, dynamic> json,
  ) {
    return GroupKeyRotation(
      groupId: json['groupId'] as String,
      keyVersion: json['keyVersion'] as int,
      effectiveAt: json['effectiveAt'] as int,
      keyCommitment: json['keyCommitment'] as String,
      envelopes: (json['envelopes'] as List)
          .map(
            (e) => GroupKeyEnvelope.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList(),
      signature: json['signature'] as String,
    );
  }
}

class GroupKeyRotationCrypto {
  GroupKeyRotationCrypto._();

  static final Ed25519 _ed25519 = Ed25519();

  static final Sha256 _sha256 = Sha256();

  /// Creates the canonical bytes that are signed.
  ///
  /// The signature deliberately excludes the signature field itself.
  static List<int> signingBytes({
    required String groupId,
    required int keyVersion,
    required int effectiveAt,
    required String keyCommitment,
    required List<GroupKeyEnvelope> envelopes,
  }) {
    final data = {
      'version': 1,
      'type': 'group_key_rotation',
      'groupId': groupId,
      'keyVersion': keyVersion,
      'effectiveAt': effectiveAt,
      'keyCommitment': keyCommitment,
      'envelopes':
          envelopes.map((e) => e.toJson()).toList(),
    };

    return utf8.encode(
      jsonEncode(data),
    );
  }

  /// Generate a SHA-256 commitment to a group key.
  static Future<String> commitment(
    String groupKey,
  ) async {
    final bytes = base64Url.decode(groupKey);
    final hash = await _sha256.hash(bytes);

    return base64UrlEncode(hash.bytes);
  }

  /// Sign a rotation using the admin's Ed25519 private key.
  static Future<String> signRotation({
    required String groupId,
    required int keyVersion,
    required int effectiveAt,
    required String keyCommitment,
    required List<GroupKeyEnvelope> envelopes,
    required SimpleKeyPair adminSigningKey,
  }) async {
    final bytes = signingBytes(
      groupId: groupId,
      keyVersion: keyVersion,
      effectiveAt: effectiveAt,
      keyCommitment: keyCommitment,
      envelopes: envelopes,
    );

    final signature = await _ed25519.sign(
      bytes,
      keyPair: adminSigningKey,
    );

    return base64UrlEncode(signature.bytes);
  }

  /// Verify an admin-signed rotation.
  static Future<bool> verifyRotation({
    required GroupKeyRotation rotation,
    required List<int> adminPublicKey,
  }) async {
    final publicKey = SimplePublicKey(
      adminPublicKey,
      type: KeyPairType.ed25519,
    );

    final signature = Signature(
      base64Url.decode(rotation.signature),
      publicKey: publicKey,
    );

    final bytes = signingBytes(
      groupId: rotation.groupId,
      keyVersion: rotation.keyVersion,
      effectiveAt: rotation.effectiveAt,
      keyCommitment: rotation.keyCommitment,
      envelopes: rotation.envelopes,
    );

    return _ed25519.verify(
      bytes,
      signature: signature,
    );
  }

  /// Generate a completely new group key.
  static Future<String> generateNewKey() {
    return GroupKey.generate();
  }
}