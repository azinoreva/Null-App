import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../widgets/app_theme.dart';
import '../widgets/buttons/send_button.dart' as send;
import '../widgets/inputs/input_field.dart';
import '../widgets/inputs/african_country_dropdown.dart';
import '../widgets/buttons/transparent_button.dart';
import '../widgets/display/icon.dart';
import '../engine/database/init_db.dart';
import '../engine/functions/auth/registerfxn.dart';
import '../engine/network/auth/register.dart';
import '../engine/network/server_error_exception.dart';
import 'modals/otp_modal.dart';
import 'chat_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String _selectedCountryCode = '+234';
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _phoneDigits =>
      _phoneController.text.trim().replaceAll(RegExp(r'\s+'), '');

  String get _fullPhoneNumber => '$_selectedCountryCode$_phoneDigits';

  Future<void> _onSignUpPressed() async {
    final messenger = ScaffoldMessenger.of(context);
    final password = _passwordController.text;

    if (_phoneDigits.isEmpty || password.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Enter your phone number and a password to continue.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final result = await UserRegistrationService().preprocess(
        phoneNumber: _fullPhoneNumber,
      );
      if (!mounted) return;

      if (result.otpSent) {
        await _showOtpModal(result.phoneNumber);
      } else {
        messenger.showSnackBar(SnackBar(content: Text(result.message)));
      }
    } on ServerErrorException catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            e.message.isEmpty
                ? 'Could not reach the registration server. Try again.'
                : e.message,
          ),
        ),
      );
    } on DioException catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not reach the registration server. Try again.'),
        ),
      );
    } on Exception catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Could not start signup. Check your connection.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _showOtpModal(String phoneNumber) async {
    final completed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => OtpComponent(
        phoneNumber: phoneNumber,
        onSubmit: (code) => _completeRegistration(dialogContext, code),
        onResend: _resendOtp,
      ),
    );

    if (completed == true) {
      await _finalizeSuccessfulSignup();
    }
  }

  Future<void> _resendOtp() async {
    await UserRegistrationService().preprocess(
      phoneNumber: _fullPhoneNumber,
    );
  }

  Future<bool> _completeRegistration(
    BuildContext dialogContext,
    String code,
  ) async {
    final messenger = ScaffoldMessenger.of(dialogContext);
    try {
      final database = await DatabaseInitializer.initialize();
      final result = await registerNewUser(
        phoneNumber: _fullPhoneNumber,
        pin: code,
        password: _passwordController.text,
        database: database,
      );

      if (result.isSuccess ||
          result.outcome == RegistrationOutcome.alreadyExists) {
        return true;
      }

      final step = result.failedStep == null ? '' : ' (${result.failedStep})';
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            result.errorMessage != null
                ? 'Signup failed$step: ${result.errorMessage}'
                : 'Signup failed. Please try again.',
          ),
        ),
      );
      return false;
    } on Exception catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not complete signup: $e')),
      );
      return false;
    }
  }

  Future<void> _finalizeSuccessfulSignup() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_signed_up', true);
    await prefs.setBool('is_logged_in', true);

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ChatScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeExtension =
        Theme.of(context).extension<AppColorScheme>() ?? AppColorScheme.dark;

    return Scaffold(
      backgroundColor: themeExtension.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWideScreen = constraints.maxWidth >= 600 ||
                MediaQuery.of(context).orientation == Orientation.landscape;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isWideScreen ? 900 : 420,
                  ),
                  child: isWideScreen
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 1,
                              child: _buildHeaderSection(
                                context,
                                themeExtension,
                                isWideScreen: true,
                              ),
                            ),
                            const SizedBox(width: 48.0),
                            Expanded(
                              flex: 1,
                              child: _buildFormSection(
                                context,
                                themeExtension,
                                isWideScreen: true,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeaderSection(
                              context,
                              themeExtension,
                              isWideScreen: false,
                            ),
                            const SizedBox(height: 32.0),
                            _buildFormSection(
                              context,
                              themeExtension,
                              isWideScreen: false,
                            ),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderSection(
    BuildContext context,
    AppColorScheme themeExtension, {
    required bool isWideScreen,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          isWideScreen ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Center(
          child: SizedBox(
            width: 140,
            height: 140,
            child: const AppLogoIcon(
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 24.0),
        Text(
          'Relay Access',
          textAlign: isWideScreen ? TextAlign.left : TextAlign.center,
          style: AppTypography.getTextStyle(
            context,
            AppTextType.title,
            color: themeExtension.textInputColor,
          ),
        ),
        const SizedBox(height: 12.0),
        Text(
          'Verify your identity to connect to the secure relay network. Or go incognito.',
          textAlign: isWideScreen ? TextAlign.left : TextAlign.center,
          style: AppTypography.getTextStyle(
            context,
            AppTextType.body,
            color: AppColors.mutedSlate,
          ),
        ),
        if (isWideScreen) ...[
          const SizedBox(height: 32.0),
          _buildTermsText(context, themeExtension),
        ],
      ],
    );
  }

  Widget _buildFormSection(
    BuildContext context,
    AppColorScheme themeExtension, {
    required bool isWideScreen,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Icon(
              Icons.phone_android,
              size: 16,
              color: AppColors.haloRing,
            ),
            const SizedBox(width: 6.0),
            Text(
              'PHONE NUMBER',
              style: AppTypography.getTextStyle(
                context,
                AppTextType.tiny,
                color: AppColors.mutedSlate,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            AfricanCountryCodeDropdown(
              value: _selectedCountryCode,
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedCountryCode = val);
                }
              },
            ),
            const SizedBox(width: 8.0),
            Expanded(
              child: CustomInputField(
                controller: _phoneController,
                hintText: '000  000  0000',
              ),
            ),
          ],
        ),
        const SizedBox(height: 20.0),
        Row(
          children: [
            const Icon(
              Icons.lock_outline,
              size: 16,
              color: AppColors.haloRing,
            ),
            const SizedBox(width: 6.0),
            Text(
              'SECURE PASSWORD',
              style: AppTypography.getTextStyle(
                context,
                AppTextType.tiny,
                color: AppColors.mutedSlate,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        CustomInputField(
          controller: _passwordController,
          hintText: '••••••••••••',
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              size: 18,
              color: AppColors.mutedSlate,
            ),
          ),
        ),
        const SizedBox(height: 28.0),
        send.SendButton(
          text: 'Sign Up',
          icon: Icons.chevron_right,
          iconPosition: send.IconPosition.right,
          isLocked: _isSubmitting,
          onPressed: _onSignUpPressed,
        ),
        const SizedBox(height: 16.0),
        TransparentButton(
          text: 'Accept an invitation instead',
          icon: Icons.verified_user_outlined,
          iconPosition: IconPosition.left,
          onPressed: () {},
        ),
        if (!isWideScreen) ...[
          const SizedBox(height: 32.0),
          Center(child: _buildTermsText(context, themeExtension)),
        ],
      ],
    );
  }

  Widget _buildTermsText(
    BuildContext context,
    AppColorScheme themeExtension,
  ) {
    final bodyStyle = AppTypography.getTextStyle(
      context,
      AppTextType.tiny,
      color: AppColors.mutedSlate,
    );

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: bodyStyle,
        children: const [
          TextSpan(text: 'By signing up, you are agreeing to our '),
          TextSpan(
            text: 'Service Terms',
            style: TextStyle(
              color: AppColors.haloRing,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}