// module name: encryption

import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

/// Asymmetric ("sealed box" style) encryption using X25519 + AES-GCM.
///
/// This encrypts [plaintext] so that only the holder of the private key
/// matching [publicKey] can decrypt it — the sender doesn't need a
/// keypair of their own, since a fresh ephemeral keypair is generated
/// per message (this mirrors libsodium's crypto_box_seal / NaCl sealed
/// box pattern):
///
///   1. Generate a fresh ephemeral X25519 keypair for this message only.
///   2. Do an X25519 key exchange between the ephemeral private key and
///      the recipient's public key to get a shared secret.
///   3. Use that shared secret as an AES-256-GCM key to encrypt the
///      plaintext, with a random 12-byte nonce.
///   4. Package [ephemeral public key | nonce | ciphertext | MAC] together
///      and Base64-encode it as the single output string.
///
/// [publicKey] must be the recipient's X25519 public key, Base64-encoded
/// (32 raw bytes before encoding) — matching the format your app already
/// uses for stored public keys.
///
/// Returns a single Base64 string containing everything needed to
/// decrypt on the recipient's side, safe to drop straight into the
/// `message` field of SendMessageService.sendMessage.
Future<String> encryptMessage({
  required String publicKey,
  required String plaintext,
}) async {
  final x25519 = X25519();
  final aesGcm = AesGcm.with256bits();

  // 1. Ephemeral keypair, unique to this message.
  final ephemeralKeyPair = await x25519.newKeyPair();
  final ephemeralPublicKey = await ephemeralKeyPair.extractPublicKey();

  // 2. Recipient's public key, from the Base64 string passed in.
  final recipientPublicKeyBytes = base64Decode(publicKey);
  if (recipientPublicKeyBytes.length != 32) {
    throw FormatException('Recipient public key must be 32 bytes.');
  }
  final recipientPublicKey = SimplePublicKey(
    recipientPublicKeyBytes,
    type: KeyPairType.x25519,
  );

  // 3. ECDH shared secret -> AES-256-GCM key.
  final sharedSecret = await x25519.sharedSecretKey(
    keyPair: ephemeralKeyPair,
    remotePublicKey: recipientPublicKey,
  );

  // 4. Encrypt the plaintext.
  final plaintextBytes = utf8.encode(plaintext);
  final secretBox = await aesGcm.encrypt(
    plaintextBytes,
    secretKey: sharedSecret,
  );

  // 5. Package everything the recipient needs: ephemeral pub key + nonce +
  // ciphertext + MAC, all concatenated then Base64-encoded as one string.
  final ephemeralPublicKeyBytes = ephemeralPublicKey.bytes;
  final packed = BytesBuilder()
    ..add(ephemeralPublicKeyBytes) // 32 bytes
    ..add(secretBox.nonce) // 12 bytes
    ..add(secretBox.cipherText) // variable length
    ..add(secretBox.mac.bytes); // 16 bytes

  return base64Encode(packed.toBytes());
}

/// The matching decrypt function, for reference / for whoever implements
/// the receiving side. Requires the recipient's own X25519 KeyPair (the
/// private key matching the publicKey that was encrypted to).
Future<String> decryptMessage({
  required SimpleKeyPair recipientKeyPair,
  required String packedMessage,
}) async {
  final x25519 = X25519();
  final aesGcm = AesGcm.with256bits();

  final packed = base64Decode(packedMessage);

  const pubKeyLen = 32;
  const nonceLen = 12;
  const macLen = 16;

  if (packed.length < pubKeyLen + nonceLen + macLen) {
    throw FormatException('Encrypted message is malformed or truncated.');
  }

  final ephemeralPublicKeyBytes = packed.sublist(0, pubKeyLen);
  final nonce = packed.sublist(pubKeyLen, pubKeyLen + nonceLen);
  final cipherText = packed.sublist(
    pubKeyLen + nonceLen,
    packed.length - macLen,
  );
  final macBytes = packed.sublist(packed.length - macLen);

  final ephemeralPublicKey = SimplePublicKey(
    ephemeralPublicKeyBytes,
    type: KeyPairType.x25519,
  );

  final sharedSecret = await x25519.sharedSecretKey(
    keyPair: recipientKeyPair,
    remotePublicKey: ephemeralPublicKey,
  );

  final secretBox = SecretBox(
    cipherText,
    nonce: nonce,
    mac: Mac(macBytes),
  );

  final plaintextBytes = await aesGcm.decrypt(
    secretBox,
    secretKey: sharedSecret,
  );

  return utf8.decode(plaintextBytes);
}