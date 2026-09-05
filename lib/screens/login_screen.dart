import 'package:flutter/material.dart';
import '../widgets/app_theme.dart';
import '../widgets/display/icon.dart';
import '../widgets/inputs/input_field.dart';
import '../widgets/buttons/send_button.dart';
import '../widgets/buttons/square_button.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
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
            children: const [
              TextSpan(text: 'Welcome '),
              TextSpan(
                text: 'Azibaba',
                style: TextStyle(
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
          obscureText: true,
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
          onPressed: () {
            // Handle Login
          },
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