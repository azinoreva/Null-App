import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../widgets/app_theme.dart';
import '../../engine/media_handling/connection_scan_service.dart';

enum _ScanMode { liveScanner, importImage }

/// "Add Connection" screen - the reverse of ConnectionSetupScreen: instead
/// of generating a QR/PIN, this one reads one in, via three paths (live
/// camera, an imported image, or manually typing the 9-character PIN).
///
/// Whichever path succeeds, the result funnels through
/// `ConnectionScanService.extractCodeFromPayload` and then out through
/// [onConnectionScanned] - left blank/undefined here on purpose, since
/// what actually happens with a scanned code (validating it, sending it
/// to a server, etc.) is up to you to write later.
class AddConnectionScreen extends StatefulWidget {
  final Future<void> Function(String code, {required bool isManualPin})
  onConnectionScanned;
  final VoidCallback? onBack;
  final VoidCallback? onShareContact;

  const AddConnectionScreen({
    super.key,
    required this.onConnectionScanned,
    this.onBack,
    this.onShareContact,
  });

  @override
  State<AddConnectionScreen> createState() => _AddConnectionScreenState();
}

class _AddConnectionScreenState extends State<AddConnectionScreen> {
  bool get _supportsLiveScanner =>
      defaultTargetPlatform != TargetPlatform.windows;

  _ScanMode get _initialMode =>
      _supportsLiveScanner ? _ScanMode.liveScanner : _ScanMode.importImage;

  late _ScanMode _mode;
  MobileScannerController? _cameraController;
  final TextEditingController _pinController = TextEditingController();
  bool _hasHandledScan = false;
  bool _isProcessingImage = false;

  @override
  void initState() {
    super.initState();
    _mode = _initialMode;
    if (_supportsLiveScanner) {
      _cameraController = MobileScannerController();
    }
    _pinController.addListener(_handlePinChanged);
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _pinController.removeListener(_handlePinChanged);
    _pinController.dispose();
    super.dispose();
  }

  void _setMode(_ScanMode mode) {
    if (mode == _ScanMode.liveScanner && !_supportsLiveScanner) return;
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      if (mode == _ScanMode.liveScanner) {
        _cameraController = MobileScannerController();
      } else {
        _cameraController?.dispose();
        _cameraController = null;
      }
    });
  }

  void _handleBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _handleShareContact() {
    widget.onShareContact?.call();
  }

  void _handleDetect(BarcodeCapture capture) {
    if (_hasHandledScan) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final raw = barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) return;
    _hasHandledScan = true;
    _finishWithRawValue(raw, isManualPin: false);
  }

  // ---- Stub: plug in a real picker later (image_picker / file_picker) ----
  Future<String?> _pickImageFromGallery() async {
    // TODO: use image_picker (or file_picker) to let the user choose an
    // image, and return its path.
    return null;
  }
  // -------------------------------------------------------------------------

  Future<void> _handleImportImage() async {
    if (_isProcessingImage) return;
    final path = await _pickImageFromGallery();
    if (path == null) return;

    setState(() => _isProcessingImage = true);
    final result = await scanImageFile(path);
    if (!mounted) return;
    setState(() => _isProcessingImage = false);

    if (result != null) {
      _finishWithRawValue(result, isManualPin: false);
    } else {
      // TODO: show a "couldn't find a QR code in that image" message.
    }
  }

  void _handlePinChanged() {
    final rawChars = _pinController.text.replaceAll('-', '');
    if (rawChars.length >= 9 && !_hasHandledScan) {
      _hasHandledScan = true;
      _finishWithRawValue(_pinController.text, isManualPin: true);
    }
  }

  Future<void> _finishWithRawValue(
    String raw, {
    required bool isManualPin,
  }) async {
    await widget.onConnectionScanned(raw, isManualPin: isManualPin);
    // Reset so the screen can be reused for another scan if it isn't
    // popped by the caller.
    if (mounted) {
      setState(() => _hasHandledScan = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;

    return Container(
      color: theme.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 12.0, 16.0, 12.0),
              child: Row(
                children: [
                  InkWell(
                    onTap: _handleBack,
                    child: Icon(Icons.arrow_back, color: theme.primaryGreen),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'Add Connection',
                      style: AppTypography.getTextStyle(
                        context,
                        AppTextType.title,
                        color: theme.textInputColor,
                      ).copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  InkWell(
                    onTap: _handleShareContact,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.ios_share,
                          size: 22.0,
                          color: theme.primaryGreen,
                        ),
                        Text(
                          'share',
                          style: AppTypography.getTextStyle(
                            context,
                            AppTextType.tiny,
                            color: theme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: theme.border, height: 1.0),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Viewfinder
                    Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.6,
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Container(color: theme.border.withAlpha(60)),
                                if (_mode == _ScanMode.liveScanner &&
                                    _cameraController != null)
                                  MobileScanner(
                                    controller: _cameraController!,
                                    onDetect: _handleDetect,
                                  )
                                else
                                  Center(
                                    child: _isProcessingImage
                                        ? CircularProgressIndicator(
                                            color: theme.primaryGreen,
                                          )
                                        : InkWell(
                                            onTap: _handleImportImage,
                                            child: Icon(
                                              Icons.photo_camera_outlined,
                                              size: 48.0,
                                              color: AppColors.mutedSlate
                                                  .withAlpha(150),
                                            ),
                                          ),
                                  ),
                                const _ScannerBrackets(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    Center(
                      child: Text(
                        'ALIGN QR CODE WITHIN BRACKETS',
                        style:
                            AppTypography.getTextStyle(
                              context,
                              AppTextType.tiny,
                              color: AppColors.mutedSlate,
                            ).copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16.0),

                    if (_supportsLiveScanner)
                      Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: theme.border.withAlpha(70),
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _ModeTab(
                                theme: theme,
                                icon: Icons.camera_alt_outlined,
                                label: 'Live Scanner',
                                isActive: _mode == _ScanMode.liveScanner,
                                onTap: () => _setMode(_ScanMode.liveScanner),
                              ),
                            ),
                            Expanded(
                              child: _ModeTab(
                                theme: theme,
                                icon: Icons.image_outlined,
                                label: 'Import Image',
                                isActive: _mode == _ScanMode.importImage,
                                onTap: () => _setMode(_ScanMode.importImage),
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24.0),

                    // Manual PIN entry
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'CONNECT VIA PIN',
                          style:
                              AppTypography.getTextStyle(
                                context,
                                AppTextType.tiny,
                                color: theme.textInputColor,
                              ).copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                        ),
                        Text(
                          '10-Character Alphanumeric',
                          style: AppTypography.getTextStyle(
                            context,
                            AppTextType.tiny,
                            color: theme.primaryGreen,
                          ).copyWith(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10.0),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      decoration: BoxDecoration(
                        color: theme.border.withAlpha(70),
                        borderRadius: BorderRadius.circular(14.0),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 34.0,
                            height: 34.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: theme.primaryGreen.withAlpha(35),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.vpn_key_outlined,
                              size: 16.0,
                              color: theme.primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: TextField(
                              controller: _pinController,
                              inputFormatters: [_PinInputFormatter()],
                              textCapitalization: TextCapitalization.characters,
                              cursorColor: theme.primaryGreen,
                              style:
                                  AppTypography.getTextStyle(
                                    context,
                                    AppTextType.body,
                                    color: theme.textInputColor,
                                  ).copyWith(
                                    letterSpacing: 2.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    Text(
                      "Don't have a QR code? Ask your contact to share their "
                      'Connect PIN found on their home screen.',
                      textAlign: TextAlign.center,
                      style: AppTypography.getTextStyle(
                        context,
                        AppTextType.tiny,
                        color: AppColors.mutedSlate,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final AppColorScheme theme;
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModeTab({
    required this.theme,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: isActive
              ? theme.primaryGreen.withAlpha(35)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10.0),
          border: isActive ? Border.all(color: theme.primaryGreen) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16.0,
              color: isActive ? theme.primaryGreen : AppColors.mutedSlate,
            ),
            const SizedBox(width: 6.0),
            Text(
              label,
              style: AppTypography.getTextStyle(
                context,
                AppTextType.tiny,
                color: isActive ? theme.primaryGreen : AppColors.mutedSlate,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

/// Decorative corner brackets + center scan line drawn over the
/// viewfinder, regardless of whether it's showing the live camera or the
/// import-image placeholder.
class _ScannerBrackets extends StatelessWidget {
  const _ScannerBrackets();

  @override
  Widget build(BuildContext context) {
    const color = AppColors.activeGreen;
    const length = 28.0;
    const thickness = 3.0;
    const inset = 16.0;

    Widget corner({required bool top, required bool left}) {
      return Positioned(
        top: top ? inset : null,
        bottom: top ? null : inset,
        left: left ? inset : null,
        right: left ? null : inset,
        child: SizedBox(
          width: length,
          height: length,
          child: CustomPaint(
            painter: _CornerPainter(
              top: top,
              left: left,
              color: color,
              thickness: thickness,
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        corner(top: true, left: true),
        corner(top: true, left: false),
        corner(top: false, left: true),
        corner(top: false, left: false),
        Center(
          child: Container(height: thickness, color: color.withAlpha(150)),
        ),
      ],
    );
  }
}

class _CornerPainter extends CustomPainter {
  final bool top;
  final bool left;
  final Color color;
  final double thickness;

  _CornerPainter({
    required this.top,
    required this.left,
    required this.color,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final y = top ? 0.0 : size.height;
    final x = left ? 0.0 : size.width;
    final vDir = top ? 1.0 : -1.0;
    final hDir = left ? 1.0 : -1.0;

    path.moveTo(x, y + size.height * vDir * 0.6);
    path.lineTo(x, y);
    path.lineTo(x + size.width * hDir * 0.6, y);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CornerPainter oldDelegate) => false;
}

/// Uppercases input, strips non-alphanumeric characters, caps it at 9
/// characters, and auto-inserts a "-" after the 4th character so the key
/// reads as "XXXX-YYYYY" (the dash is part of the key).
class _PinInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.toUpperCase().replaceAll(
      RegExp(r'[^A-Z0-9]'),
      '',
    );
    final capped = raw.length > 9 ? raw.substring(0, 9) : raw;

    final buffer = StringBuffer();
    for (var i = 0; i < capped.length; i++) {
      if (i == 4) buffer.write('-');
      buffer.write(capped[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
