// Requires the `cryptography` package for AES-256-GCM (Dart's core libs
// have no built-in symmetric cipher). Add to pubspec.yaml:
//   dependencies:
//     cryptography: ^2.7.0
//
// Depends on shamir_secret_sharing.dart from the same project (splitSecret,
// combineShares, Share).

import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

import 'shamir_secret.dart';

/// AES-256-GCM output: ciphertext + the nonce and authentication tag
/// needed to decrypt and verify it. All fields are base64-encoded so the
/// payload can be stored/transmitted as plain text (e.g. JSON).
class EncryptedPayload {
  final String nonce; // 12 bytes, base64
  final String ciphertext; // base64
  final String mac; // 16-byte GCM auth tag, base64

  const EncryptedPayload({
    required this.nonce,
    required this.ciphertext,
    required this.mac,
  });

  Map<String, String> toJson() => {
        'nonce': nonce,
        'ciphertext': ciphertext,
        'mac': mac,
      };

  factory EncryptedPayload.fromJson(Map<String, dynamic> json) =>
      EncryptedPayload(
        nonce: json['nonce'] as String,
        ciphertext: json['ciphertext'] as String,
        mac: json['mac'] as String,
      );
}

/// Everything produced by [createPasswordVault].
///
/// SECURITY NOTE: [key] is the raw 32-byte AES key that both decrypts
/// [payload] directly AND can be reconstructed from just 2 of the 5
/// [shares]. Storing `key` next to `shares` anywhere defeats the point of
/// splitting it — anyone with both no longer needs a quorum of shares.
/// The intended flow is: show `key` to the caller once (e.g. "here is
/// your one-time recovery key, save it now and we'll discard it"), keep
/// `keyHash` for verifying a key presented later, and distribute the 5
/// `shares` to separate custodians. Don't persist `key` yourself.
class VaultResult {
  final List<Share> shares; // remaining unshared shares; starts at 5
  final EncryptedPayload payload; // the encrypted password
  final String key; // raw AES key, hex — show once, then discard
  final String keyHash; // SHA-256(key), hex — safe to store long-term
  final int passwordVersion; // starts at 1, incremented on each re-encrypt

  const VaultResult({
    required this.shares,
    required this.payload,
    required this.key,
    required this.keyHash,
    required this.passwordVersion,
  });

  Map<String, dynamic> toJson() => {
        'shares': shares.map((s) => s.toJson()).toList(),
        'payload': payload.toJson(),
        'key': key,
        'keyHash': keyHash,
        'passwordVersion': passwordVersion,
      };

  factory VaultResult.fromJson(Map<String, dynamic> json) => VaultResult(
        shares: (json['shares'] as List)
            .map((e) => Share.fromJson(e as Map<String, dynamic>))
            .toList(),
        payload: EncryptedPayload.fromJson(
          json['payload'] as Map<String, dynamic>,
        ),
        key: json['key'] as String,
        keyHash: json['keyHash'] as String,
        // Vaults saved before this field existed won't have it; treat
        // those as version 1 rather than failing to parse.
        passwordVersion: json['passwordVersion'] as int? ?? 1,
      );
}

const int _shamirThreshold = 2;
const int _shamirTotalShares = 5;

String _bytesToHex(List<int> bytes) => bytes
    .map((b) => b.toRadixString(16).padLeft(2, '0'))
    .join();

/// Generates a random AES-256 key, encrypts [password] with it, splits
/// the key into 5 Shamir shares (any 2 reconstruct it), and returns
/// everything: the shares, the encrypted payload, the raw key, and a
/// SHA-256 hash of the key for later verification.
///
/// See [VaultResult] for the security note on handling the returned key.
Future<VaultResult> createPasswordVault(String password) async {
  // 1. Generate the key.
  final algorithm = AesGcm.with256bits();
  final secretKey = await algorithm.newSecretKey();
  final keyBytes = Uint8List.fromList(await secretKey.extractBytes());

  // 2. Encrypt the password with it.
  final payload = await encryptPasswordWithKey(password, keyBytes);

  // 3. Split the key: 5 shares, any 2 reconstruct it.
  final shares = splitSecret(
    secret: keyBytes,
    threshold: _shamirThreshold,
    totalShares: _shamirTotalShares,
  );

  // 4. Hash the key so a reconstructed/presented key can be verified
  //    later without needing to store the key itself.
  final hash = await Sha256().hash(keyBytes);
  final keyHash = _bytesToHex(hash.bytes);

  return VaultResult(
    shares: shares,
    payload: payload,
    key: _bytesToHex(keyBytes),
    keyHash: keyHash,
    passwordVersion: 1,
  );
}

/// Encrypts [password] with an already-existing AES-256 [key] (raw 32
/// bytes) rather than generating a new one. Used internally by
/// [createPasswordVault], and directly by callers who want to change the
/// password without touching the key or its Shamir shares — e.g. a
/// password-change flow where the 5 share-holders shouldn't need to do
/// anything.
Future<EncryptedPayload> encryptPasswordWithKey(
  String password,
  Uint8List key,
) async {
  final algorithm = AesGcm.with256bits();
  final secretKey = SecretKey(key);
  final secretBox = await algorithm.encrypt(
    utf8.encode(password),
    secretKey: secretKey,
  );
  return EncryptedPayload(
    nonce: base64Encode(secretBox.nonce),
    ciphertext: base64Encode(secretBox.cipherText),
    mac: base64Encode(secretBox.mac.bytes),
  );
}

/// Reconstructs the AES key from >= 2 of the 5 shares produced by
/// [createPasswordVault]. Throws [ShamirException] on malformed or
/// duplicate shares. Does not itself confirm the result is the *correct*
/// key — pair with [verifyKeyHash] against the stored `keyHash`.
Uint8List reconstructKey(List<Share> shares) => combineShares(shares);

/// Checks whether [key] hashes to [expectedHashHex] (the `keyHash` from
/// [VaultResult]). Use this after [reconstructKey] to confirm the shares
/// supplied actually recombine to the right key, since Shamir
/// reconstruction with too few/wrong shares fails silently rather than
/// throwing.
Future<bool> verifyKeyHash(Uint8List key, String expectedHashHex) async {
  final hash = await Sha256().hash(key);
  return _bytesToHex(hash.bytes).toLowerCase() ==
      expectedHashHex.toLowerCase();
}

/// Decrypts an [EncryptedPayload] produced by [createPasswordVault] using
/// the raw AES key (either the one returned directly, or one recovered
/// via [reconstructKey]). Throws if the key or payload is wrong/corrupted
/// — GCM's authentication tag makes tampering detectable rather than
/// silently returning garbage.
Future<String> decryptPassword(
  EncryptedPayload payload,
  Uint8List key,
) async {
  final algorithm = AesGcm.with256bits();
  final secretKey = SecretKey(key);
  final secretBox = SecretBox(
    base64Decode(payload.ciphertext),
    nonce: base64Decode(payload.nonce),
    mac: Mac(base64Decode(payload.mac)),
  );
  final clearBytes = await algorithm.decrypt(secretBox, secretKey: secretKey);
  return utf8.decode(clearBytes);
}

/// Convenience: hex string -> bytes, for turning a stored/entered `key`
/// (as returned in [VaultResult.key]) back into bytes for [decryptPassword]
/// or [verifyKeyHash].
Uint8List keyFromHex(String hex) => hexToBytes(hex);