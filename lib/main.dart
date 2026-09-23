import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/splash_screen.dart'; // your splash screen
import 'screens/chat_screen.dart'; // placeholder
import 'screens/signup_screen.dart'; // placeholder
import 'screens/login_screen.dart'; // placeholder
import 'widgets/app_theme.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'engine/network/main_server_client.dart';
import 'engine/network/auth_failure_handler.dart';
import 'engine/network/updates/updates_cache.dart';
import 'engine/network/server_connections.dart';
import 'engine/database/init_db.dart';
import 'engine/crypto/chat/identity_crypto.dart';
import 'engine/task_queue.dart';
import '/engine/engine.dart';
import 'state/providers.dart';
import 'engine/functions/settings/settings.dart';
import 'utils/server_list.dart';

/// App-wide handle on the SSE supervisor started once the user is logged in,
/// so other code (screens, providers) can inspect connection statuses or
/// register SSE event handlers.
ServerConnectionService? appServerConnections;

/// The newest [TaskQueue] created at startup; used to (re)start the SSE
/// supervisor outside of [main] (e.g. right after a login).
TaskQueue? appTaskQueue;

/// The app's single server-list instance, shared between the SSE supervisor
/// and the settings screen so connecting/disconnecting a server stays in
/// sync with the live subscriptions.
final ServerListService appServerList = ServerListService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await MainServerClient.init();
  await AppSettings.init();
  await UpdatesCacheService.instance.init();
  final database = await DatabaseInitializer.initialize();
  await const IdentityCrypto().ensureIdentityKey(database: database);
  final taskEngine = await TaskEngine.start(
    database: database,
    initiallyOnline: true,
  );
  taskEngine.ping();
  final taskQueue = TaskQueue(database: database, engine: taskEngine);
  appTaskQueue = taskQueue;
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        // Make the initialized database available to every Riverpod provider.
        appDatabaseProvider.overrideWithValue(database),
        taskEngineProvider.overrideWithValue(taskEngine),
        serverListProvider.overrideWithValue(appServerList),
      ],
      child: const MyApp(),
    ),
  );

  if (prefs.getBool('is_logged_in') ?? false) {
    unawaited(startSseConnections());
  }
}

/// Loads the persisted server list and keeps every listed server's SSE
/// subscription connected for the lifetime of the app.
///
/// Idempotent: reuses the running [appServerConnections] supervisor when one
/// exists (e.g. a second login), and rebuilds it if it was torn down (e.g.
/// after a logout).
Future<void> startSseConnections() async {
  final taskQueue = appTaskQueue;
  if (taskQueue == null) return;
  appServerConnections ??= ServerConnectionService(
    serverList: appServerList,
    taskQueue: taskQueue,
  );
  await appServerConnections!.start();
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
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    final bool isLaunched = _prefs!.getBool('is_launched') ?? false;

    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        final bool isDark = AppSettings.instance.isDarkMode;
        return MaterialApp(
          title: 'Null App',
          navigatorKey: rootNavigatorKey,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.lightGreen,
              brightness: Brightness.light,
            ),
            extensions: const [AppColorScheme.light],
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.darkGreen,
              brightness: Brightness.dark,
            ),
            extensions: const [AppColorScheme.dark],
          ),
          debugShowCheckedModeBanner: false,
          home: isLaunched
              ? DecisionScreen(prefs: _prefs!) // skip splash
              : Theme(
                  // Splash drives its own colour transitions, so no app theme here.
                  data: ThemeData(),
                  child: SplashScreen(
                    prefs: _prefs!,
                    destination: DecisionScreen(prefs: _prefs!),
                  ),
                ),
        );
      },
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
