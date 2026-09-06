import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/app_theme.dart';

class OtpComponent extends StatefulWidget {
  final String phoneNumber;

  /// Called when the user submits the 6-digit code. Return `true` to close
  /// the modal (e.g. verification succeeded); return `false` to keep it open.
  final Future<bool> Function(String code) onSubmit;

  /// Called when the user taps "Resend Code". Exceptions thrown here are
  /// caught by the modal and surfaced to the user.
  final Future<void> Function() onResend;

  const OtpComponent({
    super.key,
    this.phoneNumber = '+2349054821617',
    required this.onSubmit,
    required this.onResend,
  });

  @override
  State<OtpComponent> createState() => _OtpComponentState();
}

class _OtpComponentState extends State<OtpComponent> {
  static const int _digitCount = 6;
  static const int _expirySeconds = 120;

  final List<TextEditingController> _controllers =
      List.generate(_digitCount, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_digitCount, (_) => FocusNode());

  Timer? _timer;
  int _secondsRemaining = _expirySeconds;
  bool _isSubmitting = false;
  bool _isResending = false;

  String get _code => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = _expirySeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _secondsRemaining--);
      if (_secondsRemaining <= 0) {
        timer.cancel();
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _onDigitChanged(int index, String value) {
    if (value.length > 1) {
      _controllers[index].text = value[value.length - 1];
      _controllers[index].selection =
          TextSelection.collapsed(offset: _controllers[index].text.length);
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    } else if (value.isNotEmpty && index < _digitCount - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _handleSubmit() async {
    if (_isSubmitting || _isResending) return;

    final code = _code;
    if (code.length != _digitCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the full 6-digit code.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    bool success = false;
    try {
      success = await widget.onSubmit(code);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }

    if (success && mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _handleResend() async {
    if (_isSubmitting || _isResending) return;

    setState(() => _isResending = true);
    try {
      await widget.onResend();
      if (!mounted) return;
      _startTimer();
      for (final controller in _controllers) {
        controller.clear();
      }
      _focusNodes.first.requestFocus();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not resend the code. Check your connection.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  void _close() {
    if (mounted) Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final themeExtension =
        Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpired = _secondsRemaining <= 0;
    final allDigitsEntered = _code.length == _digitCount;

    final timerColor =
        isDark ? const Color(0xFF9095A1) : const Color(0xFF565D6D);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        decoration: BoxDecoration(
          color: themeExtension.background,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
              blurRadius: 24.0,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                onPressed: _close,
                iconSize: 20.0,
                color: timerColor,
                icon: const Icon(Icons.close),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Verify Identity',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: themeExtension.textInputColor,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Enter the 6-digit code sent to you.',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: themeExtension.textInputColor,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  widget.phoneNumber,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2EB82E), // Success green
                  ),
                ),
                const SizedBox(height: 32.0),

                // OTP Input Boxes
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_digitCount, (index) {
                    return SizedBox(
                      width: 44.0,
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        enabled: !_isSubmitting && !_isResending,
                        keyboardType: TextInputType.number,
                        textInputAction: index == _digitCount - 1
                            ? TextInputAction.done
                            : TextInputAction.next,
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 18.0,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFF2EB82E),
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Color(0xFF15C115),
                              width: 2.0,
                            ),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => _onDigitChanged(index, value),
                        onSubmitted: (_) {
                          if (index == _digitCount - 1) {
                            _handleSubmit();
                          }
                        },
                      ),
                    );
                  }),
                ),

                // Timer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16.0,
                      color: isExpired ? Colors.red : timerColor,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      isExpired
                          ? 'Code expired. Tap Resend Code.'
                          : 'Expires in ${_formatTime(_secondsRemaining)}',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: isExpired ? Colors.red : timerColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32.0),

                // Submit Button
                InkWell(
                  onTap: allDigitsEntered ? _handleSubmit : null,
                  borderRadius: BorderRadius.circular(28.0),
                  child: Container(
                    width: double.infinity,
                    height: 48.0,
                    decoration: BoxDecoration(
                      color: allDigitsEntered
                          ? const Color(0xFF15C115)
                          : AppColors.disabledGray,
                      borderRadius: BorderRadius.circular(28.0),
                      boxShadow: allDigitsEntered
                          ? [
                              BoxShadow(
                                color: const Color(0xFF15C115).withOpacity(0.3),
                                blurRadius: 12.0,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: _isSubmitting
                        ? const Center(
                            child: SizedBox(
                              width: 22.0,
                              height: 22.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Submit Verification',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Icon(
                                Icons.chevron_right,
                                color: Colors.white,
                                size: 20.0,
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Resend Button
                InkWell(
                  onTap: _isResending ? null : _handleResend,
                  borderRadius: BorderRadius.circular(28.0),
                  child: Container(
                    width: double.infinity,
                    height: 48.0,
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E2D1E)
                          : const Color(0xFFF3FEF3),
                      borderRadius: BorderRadius.circular(28.0),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isResending
                            ? const SizedBox(
                                width: 18.0,
                                height: 18.0,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.0,
                                  color: Color(0xFF2EB82E),
                                ),
                              )
                            : const Icon(
                                Icons.sync,
                                color: Color(0xFF2EB82E),
                                size: 20.0,
                              ),
                        const SizedBox(width: 8.0),
                        const Text(
                          'Resend Code',
                          style: TextStyle(
                            color: Color(0xFF2EB82E),
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}