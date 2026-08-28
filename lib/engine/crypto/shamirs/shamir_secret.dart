import 'dart:math';
import 'dart:typed_data';

/// A well-known 256-bit prime (secp256k1's field prime), used here
/// purely as a convenient large prime for Shamir's Secret Sharing
/// arithmetic. It has no cryptographic relationship to elliptic curve
/// operations — it just defines the finite field GF(kPrime) that the
/// polynomial math happens in.
final BigInt kPrime = BigInt.parse(
  'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F',
  radix: 16,
);

const int kMinShareId = 1;
// Field is ~2^256; there's no cryptographic reason to cap total shares
// tightly. 255 keeps IDs a single byte and is far more than any real
// deployment needs. Raise if you genuinely need more shares.
const int kMaxShareId = 255;

class Share {
  final int id;
  final String value; // 64-char hex string, 32 bytes, < kPrime

  const Share({required this.id, required this.value});

  @override
  String toString() => 'Share(id: $id, value: $value)';
}

class ShamirException implements Exception {
  final String message;
  ShamirException(this.message);

  @override
  String toString() => 'ShamirException: $message';
}

final Random _secureRandom = Random.secure();

BigInt mod(BigInt value) {
  final BigInt r = value % kPrime;
  return r.isNegative ? r + kPrime : r;
}

BigInt modInverse(BigInt value) {
  BigInt a = mod(value);
  BigInt b = kPrime;
  BigInt x0 = BigInt.one;
  BigInt x1 = BigInt.zero;
  while (b != BigInt.zero) {
    final BigInt q = a ~/ b;
    final BigInt nextB = a - q * b;
    a = b;
    b = nextB;
    final BigInt nextX1 = x0 - q * x1;
    x0 = x1;
    x1 = nextX1;
  }
  if (a != BigInt.one) {
    throw ShamirException('No modular inverse');
  }
  return mod(x0);
}

BigInt bytesToBigInt(Uint8List bytes) {
  BigInt result = BigInt.zero;
  for (final int byte in bytes) {
    result = (result << 8) | BigInt.from(byte);
  }
  return result;
}

String bigIntToHex(BigInt value, int byteLength) {
  return value.toRadixString(16).padLeft(byteLength * 2, '0');
}

Uint8List hexToBytes(String hex) {
  if (hex.length % 2 != 0 || !RegExp(r'^[0-9a-fA-F]*$').hasMatch(hex)) {
    throw ShamirException('Invalid hex string');
  }
  final Uint8List bytes = Uint8List(hex.length ~/ 2);
  for (int i = 0; i < bytes.length; i++) {
    bytes[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return bytes;
}

Uint8List _randomBytes(int length) {
  final Uint8List bytes = Uint8List(length);
  for (int i = 0; i < length; i++) {
    bytes[i] = _secureRandom.nextInt(256);
  }
  return bytes;
}

/// Returns a cryptographically random field element in [0, kPrime).
///
/// Uses rejection sampling rather than `% kPrime` so every value in
/// the field is equally likely, and so a raw 256-bit random draw that
/// happens to land in [kPrime, 2^256) is never silently wrapped
/// instead of resampled. kPrime is only ~2^32 less than 2^256, so a
/// resample is astronomically unlikely but still handled correctly.
///
/// `Random.secure()` is backed by the platform CSPRNG and is
/// synchronous, unlike expo-crypto's async API.
BigInt randomFieldElement() {
  while (true) {
    final Uint8List bytes = _randomBytes(32);
    final BigInt value = bytesToBigInt(bytes);
    if (value < kPrime) {
      return value;
    }
  }
}

final RegExp _shareValuePattern = RegExp(r'^[0-9a-fA-F]{64}$');

void validateShare(Share share) {
  if (share.id < kMinShareId || share.id > kMaxShareId) {
    throw ShamirException('Invalid share ID');
  }
  if (!_shareValuePattern.hasMatch(share.value)) {
    throw ShamirException('Invalid share value');
  }
  final BigInt value = BigInt.parse(share.value, radix: 16);
  if (value >= kPrime) {
    throw ShamirException('Share value outside field');
  }
}

/// Evaluates a polynomial (coefficients[0] = constant term) at x, mod
/// kPrime, via Horner's method.
BigInt _evaluatePolynomial(List<BigInt> coefficients, BigInt x) {
  BigInt result = BigInt.zero;
  for (int i = coefficients.length - 1; i >= 0; i--) {
    result = mod(result * x + coefficients[i]);
  }
  return result;
}

/// Splits a 32-byte secret into `totalShares` shares such that any
/// `threshold` of them can reconstruct it, and fewer than `threshold`
/// reveal no information about it (information-theoretic security).
///
/// NOTE: `threshold` is not stored in the shares. This is standard for
/// SSS — the scheme does not itself detect an insufficient quorum;
/// combining fewer than `threshold` shares silently produces a wrong
/// secret rather than throwing. Callers who need that guarantee should
/// verify reconstruction against a separate checksum/MAC of the secret.
List<Share> splitSecret({
  required Uint8List secret,
  required int threshold,
  required int totalShares,
}) {
  if (secret.length != 32) {
    throw ShamirException('Secret must be 32 bytes');
  }
  if (threshold < 2) {
    throw ShamirException('threshold must be >= 2');
  }
  if (totalShares < threshold) {
    throw ShamirException('totalShares must be >= threshold');
  }
  if (totalShares > kMaxShareId) {
    throw ShamirException('totalShares must be <= $kMaxShareId');
  }

  final BigInt secretInt = bytesToBigInt(secret);
  if (secretInt >= kPrime) {
    // Astronomically unlikely (~2^-224) for a random 32-byte value,
    // but must be checked: a secret outside the field would silently
    // wrap during arithmetic and reconstruct to the wrong value.
    throw ShamirException('Secret is outside the field');
  }

  // Random polynomial of degree (threshold - 1) with the secret as
  // the constant term: f(x) = secret + c1*x + c2*x^2 + ...
  final List<BigInt> coefficients = <BigInt>[secretInt];
  for (int i = 1; i < threshold; i++) {
    coefficients.add(randomFieldElement());
  }

  final List<Share> shares = <Share>[];
  for (int id = kMinShareId; id <= totalShares; id++) {
    final BigInt y = _evaluatePolynomial(coefficients, BigInt.from(id));
    shares.add(Share(id: id, value: bigIntToHex(y, 32)));
  }

  // Best-effort scrub. Not a strict guarantee in Dart either (BigInt
  // is immutable and the GC may retain copies), but clears the
  // references we control.
  for (int i = 0; i < coefficients.length; i++) {
    coefficients[i] = BigInt.zero;
  }

  return shares;
}

/// Reconstructs the original secret from `threshold` or more shares
/// via Lagrange interpolation at x = 0. Throws on malformed shares or
/// duplicate share IDs; does NOT throw if fewer than the original
/// threshold are supplied (see note on splitSecret).
Uint8List combineShares(List<Share> shares) {
  if (shares.length < 2) {
    throw ShamirException('At least 2 shares are required');
  }
  for (final Share share in shares) {
    validateShare(share);
  }
  final Set<int> ids = shares.map((Share s) => s.id).toSet();
  if (ids.length != shares.length) {
    throw ShamirException('Duplicate share IDs');
  }

  BigInt secret = BigInt.zero;
  for (int i = 0; i < shares.length; i++) {
    final BigInt xi = BigInt.from(shares[i].id);
    final BigInt yi = BigInt.parse(shares[i].value, radix: 16);

    // Lagrange basis polynomial L_i(0) = product_{j != i} (0 - x_j) / (x_i - x_j)
    BigInt numerator = BigInt.one;
    BigInt denominator = BigInt.one;
    for (int j = 0; j < shares.length; j++) {
      if (i == j) continue;
      final BigInt xj = BigInt.from(shares[j].id);
      numerator = mod(numerator * mod(-xj));
      denominator = mod(denominator * mod(xi - xj));
    }

    final BigInt lagrangeCoefficient =
        mod(numerator * modInverse(denominator));
    secret = mod(secret + mod(yi * lagrangeCoefficient));
  }

  return hexToBytes(bigIntToHex(secret, 32));
}