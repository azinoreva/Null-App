// lib/services/connection_identity_service.dart
import 'dart:math';

import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../engine/database/app_database.dart';
import '../../engine/functions/people/sendmycontact.dart';
import '../../engine/task_queue.dart';

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
    final part2 = List.generate(6, (_) => alnum[random.nextInt(alnum.length)]).join();
    return '$part1-$part2';
  }
}

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

  @override
  void initState() {
    super.initState();
    _exchange = sendMyContact(
      database: widget.database,
      taskQueue: widget.taskQueue,
      mainServerId: widget.mainServerId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: FutureBuilder<SendMyContactResult>(
          future: _exchange,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox(
                height: 280,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return _ErrorView(error: snapshot.error!);
            }

            final result = snapshot.data!;
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Share contact',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SvgPicture.string(
                    ConnectionIdentityService.qrSvgForPayload(
                      result.displayQRSVG,
                    ),
                    width: 220,
                    height: 220,
                  ),
                  const SizedBox(height: 12),
                  SelectableText(
                    result.manualCode,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scan this QR or enter the contact key manually.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  SvgPicture.string(
                    ConnectionIdentityService.qrSvgForPayload(
                      result.shareQRSVG,
                      size: 180,
                    ),
                    width: 180,
                    height: 180,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Done'),
                  ),
                ],
              ),
            );
          },
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
      height: 280,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline),
          const SizedBox(height: 12),
          Text(
            'Could not share contact. Please retry.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}