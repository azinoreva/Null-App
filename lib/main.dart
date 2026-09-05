import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';   // your splash screen
import 'screens/chat_screen.dart';     // placeholder
import 'screens/signup_screen.dart';   // placeholder
import 'screens/login_screen.dart';    // placeholder
import 'widgets/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SharedPreferences? _prefs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    final bool isLaunched = _prefs!.getBool('is_launched') ?? false;

    return MaterialApp(
      title: 'Null App',
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.darkGreen,
          brightness: Brightness.dark,
        ),
        extensions: const [AppColorScheme.dark],
      ),
      debugShowCheckedModeBanner: false,
      home: isLaunched
          ? DecisionScreen(prefs: _prefs!)      // skip splash
          : SplashScreen(
              prefs: _prefs!,
              destination: DecisionScreen(prefs: _prefs!),
            ),
    );
  }
}

// ---------- Decision Screen (after splash) ----------
class DecisionScreen extends StatelessWidget {
  final SharedPreferences prefs;

  const DecisionScreen({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    final bool hasSignedUp = prefs.getBool('has_signed_up') ?? false;

    if (isLoggedIn) {
      return const ChatScreen();
    } else if (!hasSignedUp) {
      return const SignupScreen();
    } else {
      return const LoginScreen();
    }
  }
}