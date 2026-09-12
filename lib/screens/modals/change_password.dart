import 'package:flutter/material.dart';
import '../../widgets/app_theme.dart';
import '../../widgets/buttons/send_button.dart';

enum _PasswordStrength { none, weak, medium, strong }

/// "Change Password" modal.
///
/// Decoupled from any settings/auth module, same pattern as the other
/// modals: it validates locally (match check + strength), then calls
/// [onSave] with (currentPassword, newPassword). [onSave] should return
/// `null` on success, or an error message string to show back in the
/// modal (e.g. "Current password is incorrect") if the change fails
/// server-side.
class ChangePasswordModal extends StatefulWidget {
  final Future<String?> Function(String currentPassword, String newPassword) onSave;
  final VoidCallback? onCancel;

  const ChangePasswordModal({
    super.key,
    required this.onSave,
    this.onCancel,
  });

  @override
  State<ChangePasswordModal> createState() => _ChangePasswordModalState();
}

class _ChangePasswordModalState extends State<ChangePasswordModal> {
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _newController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _newController.addListener(() => setState(() {}));
    _confirmController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  _PasswordStrength get _strength {
    final pw = _newController.text;
    if (pw.isEmpty) return _PasswordStrength.none;

    final hasLetters = RegExp(r'[A-Za-z]').hasMatch(pw);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(pw);
    final hasSymbols = RegExp(r'[^A-Za-z0-9]').hasMatch(pw);
    final isLongEnough = pw.length >= 8;

    if (isLongEnough && hasLetters && hasNumbers && hasSymbols) {
      return _PasswordStrength.strong;
    }
    if (isLongEnough && hasLetters && hasNumbers) {
      return _PasswordStrength.strong;
    }
    if (pw.length >= 6 && (hasLetters && hasNumbers)) {
      return _PasswordStrength.medium;
    }
    return _PasswordStrength.weak;
  }

  Color _strengthColor(AppColorScheme theme) {
    switch (_strength) {
      case _PasswordStrength.none:
        return theme.border;
      case _PasswordStrength.weak:
        return AppColors.alertRed;
      case _PasswordStrength.medium:
        return const Color(0xFFE8A93A); // amber - not in AppColors, kept local to this warning state
      case _PasswordStrength.strong:
        return theme.primaryGreen;
    }
  }

  String _strengthLabel() {
    switch (_strength) {
      case _PasswordStrength.none:
        return '';
      case _PasswordStrength.weak:
        return 'Weak';
      case _PasswordStrength.medium:
        return 'Medium';
      case _PasswordStrength.strong:
        return 'Strong';
    }
  }

  double _strengthFraction() {
    switch (_strength) {
      case _PasswordStrength.none:
        return 0.0;
      case _PasswordStrength.weak:
        return 0.33;
      case _PasswordStrength.medium:
        return 0.66;
      case _PasswordStrength.strong:
        return 1.0;
    }
  }

  bool get _passwordsMismatch =>
      _confirmController.text.isNotEmpty && _newController.text != _confirmController.text;

  void _handleCancel() {
    if (widget.onCancel != null) {
      widget.onCancel!();
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _handleSave() async {
    setState(() => _errorMessage = null);

    if (_currentController.text.isEmpty || _newController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all fields.');
      return;
    }
    if (_newController.text != _confirmController.text) {
      setState(() => _errorMessage = 'New passwords do not match. Please verify and try again.');
      return;
    }
    if (_strength == _PasswordStrength.weak) {
      setState(() => _errorMessage = 'Please choose a stronger password.');
      return;
    }

    setState(() => _isSaving = true);
    final result = await widget.onSave(_currentController.text, _newController.text);
    if (!mounted) return;
    setState(() => _isSaving = false);

    if (result != null) {
      setState(() => _errorMessage = result);
      return;
    }
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: theme.background,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Change Password',
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.title,
                    color: theme.textInputColor,
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              InkWell(
                onTap: _handleCancel,
                customBorder: const CircleBorder(),
                child: Icon(Icons.close, color: AppColors.mutedSlate),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Divider(color: theme.border, height: 1.0),
          const SizedBox(height: 16.0),

          // Current password
          _FieldLabel(text: 'Current password', theme: theme),
          const SizedBox(height: 6.0),
          _PasswordField(
            theme: theme,
            controller: _currentController,
            obscure: _obscureCurrent,
            leadingIcon: Icons.lock_outline,
            onToggleObscure: () => setState(() => _obscureCurrent = !_obscureCurrent),
          ),
          const SizedBox(height: 16.0),

          // New password
          _FieldLabel(text: 'New password', theme: theme),
          const SizedBox(height: 6.0),
          _PasswordField(
            theme: theme,
            controller: _newController,
            obscure: _obscureNew,
            leadingIcon: Icons.shield_outlined,
            onToggleObscure: () => setState(() => _obscureNew = !_obscureNew),
          ),
          const SizedBox(height: 10.0),

          // Strength meter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Password strength:',
                style: AppTypography.getTextStyle(
                  context,
                  AppTextType.tiny,
                  color: AppColors.mutedSlate,
                ),
              ),
              if (_strength != _PasswordStrength.none)
                Text(
                  _strengthLabel(),
                  style: AppTypography.getTextStyle(
                    context,
                    AppTextType.tiny,
                    color: _strengthColor(theme),
                  ).copyWith(fontWeight: FontWeight.bold),
                ),
            ],
          ),
          const SizedBox(height: 6.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: LinearProgressIndicator(
              value: _strengthFraction(),
              minHeight: 4.0,
              backgroundColor: theme.border,
              color: _strengthColor(theme),
            ),
          ),
          const SizedBox(height: 6.0),
          Text(
            'Use at least 8 characters, with letters and numbers.',
            style: AppTypography.getTextStyle(
              context,
              AppTextType.tiny,
              color: AppColors.mutedSlate,
            ),
          ),
          const SizedBox(height: 16.0),

          // Confirm new password
          _FieldLabel(text: 'Confirm new password', theme: theme),
          const SizedBox(height: 6.0),
          _PasswordField(
            theme: theme,
            controller: _confirmController,
            obscure: _obscureConfirm,
            leadingIcon: Icons.lock_outline,
            onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
            hasError: _passwordsMismatch,
          ),

          // Error banner (mismatch or server-returned error)
          if (_errorMessage != null) ...[
            const SizedBox(height: 14.0),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: AppColors.alertRed.withAlpha(30),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: AppColors.alertRed.withAlpha(120)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, size: 18.0, color: AppColors.alertRed),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: AppTypography.getTextStyle(
                        context,
                        AppTextType.tiny,
                        color: AppColors.alertRed,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20.0),

          SizedBox(
            width: double.infinity,
            child: SendButton(
              text: 'Save New Password',
              isLocked: _isSaving,
              onPressed: _handleSave,
              textType: AppTextType.body,
            ),
          ),
          const SizedBox(height: 10.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _handleCancel,
              style: ButtonStyle(
                elevation: WidgetStateProperty.all(0),
                backgroundColor: WidgetStateProperty.all(theme.border),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                ),
                padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 14.0)),
              ),
              child: Text(
                'Cancel',
                style: AppTypography.getTextStyle(
                  context,
                  AppTextType.body,
                  color: AppColors.pureWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final AppColorScheme theme;

  const _FieldLabel({required this.text, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.getTextStyle(
        context,
        AppTextType.body,
        color: theme.textInputColor,
      ).copyWith(fontWeight: FontWeight.w600),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final AppColorScheme theme;
  final TextEditingController controller;
  final bool obscure;
  final IconData leadingIcon;
  final VoidCallback onToggleObscure;
  final bool hasError;

  const _PasswordField({
    required this.theme,
    required this.controller,
    required this.obscure,
    required this.leadingIcon,
    required this.onToggleObscure,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      cursorColor: theme.primaryGreen,
      style: AppTypography.getTextStyle(context, AppTextType.body, color: theme.textInputColor),
      decoration: InputDecoration(
        filled: true,
        fillColor: theme.border.withAlpha(90),
        prefixIcon: Icon(leadingIcon, size: 18.0, color: AppColors.mutedSlate),
        suffixIcon: IconButton(
          onPressed: onToggleObscure,
          icon: Icon(
            obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            size: 18.0,
            color: AppColors.mutedSlate,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: hasError ? BorderSide(color: AppColors.alertRed) : BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(color: hasError ? AppColors.alertRed : theme.primaryGreen, width: 1.5),
        ),
      ),
    );
  }
}