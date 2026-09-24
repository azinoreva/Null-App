import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../widgets/app_theme.dart';
import '../widgets/display/icon.dart';
import '../widgets/inputs/input_field.dart';
import '../widgets/inputs/african_country_dropdown.dart';
import '../widgets/buttons/send_button.dart';
import '../widgets/buttons/square_button.dart';
import '../engine/functions_list.dart';
import '../engine/functions/settings/settings.dart';
import '../engine/network/server_error_exception.dart';
import '../main.dart';
import 'chat_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _savedPhoneNumberKey = 'saved_phone_number';

  String _selectedCountryCode = '+234';
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _restoreSavedPhoneNumber();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String get _phoneDigits =>
      _phoneController.text.trim().replaceAll(RegExp(r'\s+'), '');

  String get _fullPhoneNumber => '$_selectedCountryCode$_phoneDigits';

  /// Pre-fills the phone field with the number used at the last login.
  Future<void> _restoreSavedPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_savedPhoneNumberKey);
    if (saved == null || saved.isEmpty) return;

    final parts = _splitPhoneNumber(saved);
    if (parts == null) return;
    if (!mounted) return;

    setState(() {
      _selectedCountryCode = parts.countryCode;
      _phoneController.text = parts.digits;
    });
  }

  /// Splits a full number (e.g. `+2340000000000`) into its country code and
  /// the remaining digits, matching against the known African codes.
  ({String countryCode, String digits})? _splitPhoneNumber(String full) {
    String? bestCode;
    for (final country in africanCountries) {
      if (full.startsWith(country.code) &&
          (bestCode == null || country.code.length > bestCode.length)) {
        bestCode = country.code;
      }
    }
    if (bestCode == null) return null;
    return (countryCode: bestCode, digits: full.substring(bestCode.length));
  }

  Future<void> _onLoginPressed() async {
    final messenger = ScaffoldMessenger.of(context);
    final password = _passwordController.text;

    if (_phoneDigits.isEmpty || password.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Enter your phone number and password to sign in.',
          ),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await FunctionsList.login(
        phoneNumber: _fullPhoneNumber,
        password: password,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_signed_up', true);
      await prefs.setBool('is_logged_in', true);
      await prefs.setString(_savedPhoneNumberKey, _fullPhoneNumber);

      unawaited(startSseConnections());

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ChatScreen()),
        (route) => false,
      );
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            status == 401
                ? 'Invalid phone number or password.'
                : 'Sign in failed (${status ?? 'network error'}). Please try again.',
          ),
        ),
      );
    } on ServerErrorException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Sign in failed: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
                  vertical: 32.0,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 420, // Maintains the narrow, centered column layout
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeaderSection(context, themeExtension),
                      const SizedBox(height: 48.0),

                      _buildFormSection(context, themeExtension),
                      const SizedBox(height: 32.0),

                      // Biometrics only show on mobile/narrow screens
                      if (!isWideScreen) ...[
                        _buildAlternativeAccessSection(context, themeExtension),
                        const SizedBox(height: 32.0),
                      ],

                      _buildSecurityBanner(context, themeExtension),
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
      BuildContext context, AppColorScheme themeExtension) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 120,
          height: 120,
          child: AppLogoIcon(fit: BoxFit.contain),
        ),
        const SizedBox(height: 24.0),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: AppTypography.getTextStyle(
              context,
              AppTextType.title,
              color: themeExtension.textInputColor,
            ).copyWith(fontSize: 28.0),
            children: [
              const TextSpan(text: 'Welcome '),
              TextSpan(
                text: AppSettings.instance.nickname.split(' - ').first.trim(),
                style: const TextStyle(
                  color: AppColors.haloRing,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection(
      BuildContext context, AppColorScheme themeExtension) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Phone Number Label
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

        // Password Label with Lock Icon
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Enter your password',
              style: AppTypography.getTextStyle(
                context,
                AppTextType.body,
                color: themeExtension.textInputColor,
              ).copyWith(fontWeight: FontWeight.w500),
            ),
            Icon(
              Icons.lock_outline,
              size: 16,
              color: AppColors.mutedSlate.withOpacity(0.5),
            ),
          ],
        ),
        const SizedBox(height: 12.0),

        // Password Input
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
        const SizedBox(height: 8.0),

        // Forgot Password Link
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () {
              // Handle forgot password
            },
            child: Text(
              'Forgot Password',
              style: AppTypography.getTextStyle(
                context,
                AppTextType.tiny,
                color: AppColors.haloRing,
              ).copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 24.0),

        // Login Button
        SendButton(
          text: 'Log In',
          icon: Icons.chevron_right,
          iconPosition: IconPosition.right,
          isLocked: _isSubmitting,
          onPressed: _isSubmitting ? null : _onLoginPressed,
        ),
      ],
    );
  }

  Widget _buildAlternativeAccessSection(
      BuildContext context, AppColorScheme themeExtension) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Divider
        Row(
          children: [
            Expanded(
              child: Divider(
                color: themeExtension.border,
                thickness: 1.0,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'ALTERNATIVE ACCESS',
                style: AppTypography.getTextStyle(
                  context,
                  AppTextType.tiny,
                  color: AppColors.mutedSlate,
                ).copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: themeExtension.border,
                thickness: 1.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24.0),

        // Biometric Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: SquareFeatureButton(
                icon: Icons.face_retouching_natural, // Closest material icon for Face ID
                title: 'Face ID',
                subtitle: 'BIOMETRIC',
                onPressed: () {
                  // Handle Face ID
                },
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: SquareFeatureButton(
                icon: Icons.fingerprint,
                title: 'Fingerprint',
                subtitle: 'TOUCH ID',
                onPressed: () {
                  // Handle Touch ID
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecurityBanner(
      BuildContext context, AppColorScheme themeExtension) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: AppColors.haloRing.withOpacity(0.05), // Faint green background
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppColors.haloRing.withOpacity(0.2), // Faint green border
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.info_outline,
            color: AppColors.haloRing,
            size: 16.0,
          ),
          const SizedBox(width: 12.0),
          Text(
            'Chats exists only on your device.',
            style: AppTypography.getTextStyle(
              context,
              AppTextType.tiny,
              color: AppColors.haloRing,
            ).copyWith(fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}