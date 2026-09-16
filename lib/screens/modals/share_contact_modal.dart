// lib/services/connection_identity_service.dart
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../engine/database/app_database.dart';
import '../../engine/functions/people/sendmycontact.dart';
import '../../engine/task_queue.dart';

// This file now also needs `path_provider` and `share_plus` in pubspec.yaml
// (on top of the existing `barcode` and `flutter_svg`) to rasterize and
// hand the share QR off to the native share sheet.

/// The three things the "Personal Card" screen needs, generated together
/// so they all represent the same connection identity - but note these
/// are three genuinely different artifacts, not one image reused:
///
///  1. [displayQrSvg]  - a bare QR code, sized for in-app scanning.
///  2. [manualCode]    - the human-typeable PIN, e.g. "GRNN-9X211".
///  3. [shareQrSvg]    - a separate, larger *composed* SVG: the QR code
///     framed on a card with a title and the PIN printed underneath it -
///     built for sharing as a standalone image, not just a bigger version
///     of #1.
class ConnectionIdentity {
  final String displayQrSvg;
  final String manualCode;
  final String shareQrSvg;

  const ConnectionIdentity({
    required this.displayQrSvg,
    required this.manualCode,
    required this.shareQrSvg,
  });
}

/// Generates a personal connection identity: a bare QR for display, the
/// matching PIN, and a separately-composed branded QR card for sharing.
///
/// Requires the `barcode` package (add it to pubspec.yaml if it isn't
/// there yet) - it renders a QR code straight to an SVG string without
/// needing a widget/canvas, which is what lets this live in a plain
/// service function instead of a widget.
class ConnectionIdentityService {
  ConnectionIdentityService._();

  static const double _displaySizePx = 240.0;
  static const double _shareQrSizePx = 420.0; // size of the QR *within* the share card
  static const double _shareCardWidthPx = 640.0;
  static const double _shareCardHeightPx = 760.0;

  /// Normalises a manual code for display as "XXXX-YYYYY". Keys coming
  /// straight from the server already include the dash; if one doesn't, a
  /// "-" is inserted after the 4th character so it always reads grouped.
  static String formatManualCode(String code) {
    if (code.contains('-')) return code;
    final clean = code.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (clean.length <= 4) return clean;
    return '${clean.substring(0, 4)}-${clean.substring(4)}';
  }

  /// Generates a fresh identity. Pass [existingCode] to re-render both
  /// SVGs for a PIN you already have (e.g. loaded from storage) instead
  /// of generating a new one.
  ///
  /// TODO: swap `_buildPayload` below for whatever your real connection
  /// deep link / invite payload format actually is.
  static Future<ConnectionIdentity> generate({String? existingCode}) async {
    final code = existingCode ?? _generateManualCode();
    final payload = _buildPayload(code);

    final qr = Barcode.qrCode(errorCorrectLevel: BarcodeQRCorrectionLevel.medium);

    final displaySvg = qr.toSvg(
      payload,
      width: _displaySizePx,
      height: _displaySizePx,
      drawText: false,
    );

    final rawShareQr = qr.toSvg(
      payload,
      width: _shareQrSizePx,
      height: _shareQrSizePx,
      drawText: false,
    );
    final shareSvg = _composeShareCard(rawQrSvg: rawShareQr, code: code);

    return ConnectionIdentity(
      displayQrSvg: displaySvg,
      manualCode: code,
      shareQrSvg: shareSvg,
    );
  }

  /// Renders an arbitrary connection payload as a bare QR SVG.
  static String qrSvgForPayload(String payload, {double size = _displaySizePx}) {
    return Barcode.qrCode(
      errorCorrectLevel: BarcodeQRCorrectionLevel.medium,
    ).toSvg(
      payload,
      width: size,
      height: size,
      drawText: false,
    );
  }

  static String _buildPayload(String code) => 'yourapp://connect?code=$code';

  /// Builds a standalone "share card": dark background, a title, the QR
  /// on a white tile, and the PIN printed underneath - a different
  /// composition from [displaySvg], not the same QR just scaled up.
  static String _composeShareCard({required String rawQrSvg, required String code}) {
    final qrInner = _extractInnerSvg(rawQrSvg);
    final qrOffsetX = (_shareCardWidthPx - _shareQrSizePx) / 2;
    const qrOffsetY = 140.0;
    final tilePadding = 24.0;

    return '''
<svg xmlns="http://www.w3.org/2000/svg" width="$_shareCardWidthPx" height="$_shareCardHeightPx" viewBox="0 0 $_shareCardWidthPx $_shareCardHeightPx">
  <rect width="100%" height="100%" rx="32" fill="#171A1F"/>
  <text x="${_shareCardWidthPx / 2}" y="70" font-family="Roboto, sans-serif" font-size="32" font-weight="700" fill="#FFFFFF" text-anchor="middle">Scan to connect</text>
  <rect x="${qrOffsetX - tilePadding}" y="${qrOffsetY - tilePadding}" width="${_shareQrSizePx + tilePadding * 2}" height="${_shareQrSizePx + tilePadding * 2}" rx="20" fill="#FFFFFF"/>
  <svg x="$qrOffsetX" y="$qrOffsetY" width="$_shareQrSizePx" height="$_shareQrSizePx" viewBox="0 0 $_shareQrSizePx $_shareQrSizePx">
    $qrInner
  </svg>
  <text x="${_shareCardWidthPx / 2}" y="${qrOffsetY + _shareQrSizePx + tilePadding + 60}" font-family="Inter, sans-serif" font-size="22" fill="#9095A1" text-anchor="middle">Manual PIN</text>
  <text x="${_shareCardWidthPx / 2}" y="${qrOffsetY + _shareQrSizePx + tilePadding + 100}" font-family="Roboto, sans-serif" font-size="36" font-weight="700" letter-spacing="2" fill="#FFFFFF" text-anchor="middle">$code</text>
</svg>
''';
  }

  /// Strips the outer `<svg ...>...</svg>` wrapper off a generated QR SVG
  /// so its paths/rects can be nested inside another SVG document.
  static String _extractInnerSvg(String svg) {
    final start = svg.indexOf('>') + 1;
    final end = svg.lastIndexOf('</svg>');
    if (start <= 0 || end < 0 || end <= start) return '';
    return svg.substring(start, end);
  }

  static String _generateManualCode() {
    final random = Random.secure();
    const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const alnum = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final part1 = List.generate(4, (_) => letters[random.nextInt(letters.length)]).join();
    final part2 = List.generate(5, (_) => alnum[random.nextInt(alnum.length)]).join();
    return '$part1-$part2';
  }
}

// ---------------------------------------------------------------------------
// Visual tokens for the "Connections" screen, pulled out so the palette used
// by ShareContactModal / _ErrorView stays in one place.
// ---------------------------------------------------------------------------
const Color _kBg = Color(0xFF0C0E11);
const Color _kCardBg = Color(0xFF17191D);
const Color _kPinBg = Color(0xFF1E2125);
const Color _kAccentGreen = Color(0xFF3FE88B);
const Color _kMutedText = Color(0xFF9096A1);

/// Runs the real contact exchange and presents its three share artifacts.
class ShareContactModal extends StatefulWidget {
  final AppDatabase database;
  final TaskQueue taskQueue;
  final String mainServerId;

  const ShareContactModal({
    super.key,
    required this.database,
    required this.taskQueue,
    this.mainServerId = 'server_1',
  });

  @override
  State<ShareContactModal> createState() => _ShareContactModalState();
}

class _ShareContactModalState extends State<ShareContactModal> {
  late final Future<SendMyContactResult> _exchange;

  // The share QR is generated once the contact exchange resolves and kept
  // here in memory only - it is never built into a visible widget in the
  // normal layout. It's only ever painted into the offstage RepaintBoundary
  // below, purely so it can be rasterized on demand when the user taps
  // "Share QR".
  String? _shareQrSvg;
  final GlobalKey _shareCaptureKey = GlobalKey();
  bool _isSharing = false;

  @override
  void initState() {
    super.initState();
    _exchange = sendMyContact(
      database: widget.database,
      taskQueue: widget.taskQueue,
      mainServerId: widget.mainServerId,
    );
    _exchange.then((result) {
      final svg = ConnectionIdentityService.qrSvgForPayload(result.shareQRSVG);
      if (mounted) setState(() => _shareQrSvg = svg);
    });
  }

  void _copyPin(String pin) {
    Clipboard.setData(ClipboardData(text: pin));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PIN copied to clipboard')),
    );
  }

  /// Rasterizes the in-memory share QR (via the hidden RepaintBoundary
  /// below) to a PNG and hands it to the OS share sheet.
  Future<void> _handleShareQr() async {
    if (_shareQrSvg == null || _isSharing) return;
    setState(() => _isSharing = true);
    try {
      final boundary = _shareCaptureKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final pngBytes = byteData.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/connection_qr_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Scan this QR code to connect with me.',
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not share QR code. Please retry.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _kBg,
      child: Stack(
        children: [
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(context),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: FutureBuilder<SendMyContactResult>(
                      future: _exchange,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const SizedBox(
                            height: 420,
                            child: Center(
                              child: CircularProgressIndicator(color: _kAccentGreen),
                            ),
                          );
                        }
                        if (snapshot.hasError) {
                          return _ErrorView(error: snapshot.error!);
                        }

                        final result = snapshot.data!;
                        final pin = ConnectionIdentityService.formatManualCode(
                          result.manualCode,
                        );

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _PersonalCardPanel(
                              displayQrSvg: ConnectionIdentityService.qrSvgForPayload(
                                result.displayQRSVG,
                              ),
                              pin: pin,
                              onCopyPin: () => _copyPin(pin),
                            ),
                            const SizedBox(height: 24),
                            _ShareQrButton(
                              // Disabled until the in-memory share QR is
                              // ready; shows a spinner while rasterizing.
                              onPressed: _shareQrSvg == null ? null : _handleShareQr,
                              isBusy: _isSharing,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Offstage capture target: parked far outside the viewport (not
          // hidden via Offstage/Opacity, since those skip painting - and
          // toImage() needs an actual painted layer to read from).
          if (_shareQrSvg != null)
            Positioned(
              left: -9999,
              top: -9999,
              child: RepaintBoundary(
                key: _shareCaptureKey,
                child: Container(
                  width: 320,
                  height: 320,
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: SvgPicture.string(_shareQrSvg!, fit: BoxFit.contain),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: _kAccentGreen, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'Connections',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white70, size: 22),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

/// The dark "Personal Card" panel: title + badge, QR with corner brackets,
/// contact-identity pill, manual PIN row, and the helper copy underneath.
class _PersonalCardPanel extends StatelessWidget {
  final String displayQrSvg;
  final String pin;
  final VoidCallback onCopyPin;

  const _PersonalCardPanel({
    required this.displayQrSvg,
    required this.pin,
    required this.onCopyPin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: _kCardBg,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Personal Card',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kAccentGreen.withOpacity(0.12),
                  border: Border.all(color: _kAccentGreen.withOpacity(0.4)),
                ),
                child: const Icon(Icons.bolt, color: _kAccentGreen, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(child: _QrWithCorners(svg: displayQrSvg)),
          const SizedBox(height: 20),
          Center(child: _ContactIdentityPill()),
          const SizedBox(height: 24),
          const Text(
            'MANUAL ENTRY PIN',
            style: TextStyle(
              color: _kMutedText,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          _PinRow(pin: pin, onCopy: onCopyPin),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 16),
          _HintText(),
        ],
      ),
    );
  }
}

/// QR code on a white tile with glowing green corner brackets, matching the
/// scanner-style framing in the design.
class _QrWithCorners extends StatelessWidget {
  final String svg;

  const _QrWithCorners({required this.svg});

  @override
  Widget build(BuildContext context) {
    const double tile = 220;
    return SizedBox(
      width: tile + 12,
      height: tile + 12,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Center(
            child: Container(
              width: tile,
              height: tile,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _kAccentGreen.withOpacity(0.35),
                    blurRadius: 28,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: SvgPicture.string(svg, fit: BoxFit.contain),
            ),
          ),
          const Positioned(top: 0, left: 0, child: _CornerBracket(corner: _Corner.topLeft)),
          const Positioned(
            bottom: 0,
            right: 0,
            child: _CornerBracket(corner: _Corner.bottomRight),
          ),
        ],
      ),
    );
  }
}

enum _Corner { topLeft, bottomRight }

class _CornerBracket extends StatelessWidget {
  final _Corner corner;

  const _CornerBracket({required this.corner});

  @override
  Widget build(BuildContext context) {
    final isTopLeft = corner == _Corner.topLeft;
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        border: Border(
          top: isTopLeft
              ? const BorderSide(color: _kAccentGreen, width: 2.5)
              : BorderSide.none,
          left: isTopLeft
              ? const BorderSide(color: _kAccentGreen, width: 2.5)
              : BorderSide.none,
          bottom: !isTopLeft
              ? const BorderSide(color: _kAccentGreen, width: 2.5)
              : BorderSide.none,
          right: !isTopLeft
              ? const BorderSide(color: _kAccentGreen, width: 2.5)
              : BorderSide.none,
        ),
      ),
    );
  }
}

/// The "CONTACT IDENTITY" pill badge under the QR code.
class _ContactIdentityPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _kAccentGreen.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _kAccentGreen.withOpacity(0.5)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_outlined, color: _kAccentGreen, size: 15),
          SizedBox(width: 6),
          Text(
            'CONTACT IDENTITY',
            style: TextStyle(
              color: _kAccentGreen,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// The dark pill showing the formatted manual PIN with a copy affordance.
class _PinRow extends StatelessWidget {
  final String pin;
  final VoidCallback onCopy;

  const _PinRow({required this.pin, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: _kPinBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: SelectableText(
              pin,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          InkWell(
            onTap: onCopy,
            borderRadius: BorderRadius.circular(8),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.copy_rounded, color: _kMutedText, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shield icon + explanatory copy with the "secure, end-to-end encrypted"
/// phrase highlighted in green.
class _HintText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.verified_user_outlined, color: _kAccentGreen, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: const TextSpan(
              style: TextStyle(color: _kMutedText, fontSize: 13, height: 1.4),
              children: [
                TextSpan(text: 'Show this code or share your PIN with a friend to establish a '),
                TextSpan(
                  text: 'secure, end-to-end encrypted',
                  style: TextStyle(color: _kAccentGreen),
                ),
                TextSpan(text: ' connection.'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The outlined "Share QR" pill button below the card. Disabled (null
/// [onPressed]) until the in-memory share QR is ready; shows a spinner
/// while the image is being rasterized and handed to the share sheet.
class _ShareQrButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isBusy;

  const _ShareQrButton({required this.onPressed, this.isBusy = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: isBusy ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: _kCardBg,
          side: const BorderSide(color: Colors.white24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        ),
        icon: isBusy
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : const Icon(Icons.ios_share, color: Colors.white, size: 18),
        label: Text(
          isBusy ? 'Preparing…' : 'Share QR',
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final Object error;

  const _ErrorView({required this.error});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: _kAccentGreen, size: 32),
          const SizedBox(height: 12),
          const Text(
            'Could not share contact. Please retry.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _kMutedText, fontSize: 12),
          ),
        ],
      ),
    );
  }
}