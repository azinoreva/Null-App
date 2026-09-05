import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../widgets/buttons/send_button.dart' as send;
import '../widgets/inputs/input_field.dart';
import '../widgets/inputs/dropdown_input.dart';
import '../widgets/buttons/transparent_button.dart';
import '../widgets/display/icon.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String _selectedCountryCode = '+1';
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
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
            SizedBox(
              width: 85,
              child: CustomDropdownField<String>(
                value: _selectedCountryCode,
                items: const [
                  DropdownMenuItem(value: '+1', child: Text('+1')),
                  DropdownMenuItem(value: '+44', child: Text('+44')),
                  DropdownMenuItem(value: '+234', child: Text('+234')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedCountryCode = val);
                  }
                },
              ),
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
          obscureText: true,
        ),
        const SizedBox(height: 28.0),
        send.SendButton(
          text: 'Sign Up',
          icon: Icons.chevron_right,
          iconPosition: send.IconPosition.right,
          onPressed: () {},
        ),
        const SizedBox(height: 16.0),
        TransparentButton(
          text: 'Accept an invitation from a NULL user instead',
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