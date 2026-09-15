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
import 'engine/network/api_client.dart';
import 'engine/network/chats/sse_connect.dart';
import 'engine/database/app_database.dart';
import 'engine/database/init_db.dart';
import 'engine/crypto/chat/identity_crypto.dart';
import 'engine/task_queue.dart';
import '/engine/engine.dart';
import 'state/providers.dart';
import 'engine/functions/settings/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  MainServerClient.init();
  await AppSettings.init();
  final database = await DatabaseInitializer.initialize();
  await const IdentityCrypto().ensureIdentityKey(database: database);
  final taskEngine = await TaskEngine.start(
    database: database,
    initiallyOnline: true,
  );
  taskEngine.ping();
  final taskQueue = TaskQueue(database: database, engine: taskEngine);
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        // Make the initialized database available to every Riverpod provider.
        appDatabaseProvider.overrideWithValue(database),
        taskEngineProvider.overrideWithValue(taskEngine),
      ],
      child: const MyApp(),
    ),
  );

  if (prefs.getBool('is_logged_in') ?? false) {
    unawaited(_startSseConnections(database, taskQueue));
  }
}

Future<void> _startSseConnections(
  AppDatabase database,
  TaskQueue taskQueue,
) async {
  const mainServerId = 'server_1';
  final mainServerUrl = dotenv.env['MAIN_SERVER_URL'];
  if (mainServerUrl == null || mainServerUrl.isEmpty) return;

  ApiClient.registerServer(
    serverId: mainServerId,
    baseUrl: mainServerUrl,
    onAuthFailure: () {
      unawaited(redirectToLogin());
    },
  );

  final hub = SseHub(taskQueue: taskQueue);
  final servers = await database.serversDao.getAllServers();
  final serverUrls = <String, String>{mainServerId: mainServerUrl};
  for (final server in servers) {
    if (server.serverUrl.isNotEmpty) {
      serverUrls[server.serverId] = server.serverUrl;
    }
  }

  for (final entry in serverUrls.entries) {
    if (!ApiClient.isRegistered(entry.key)) {
      ApiClient.registerServer(
        serverId: entry.key,
        baseUrl: entry.value,
        onAuthFailure: () {
          unawaited(redirectToLogin());
        },
      );
    }
    unawaited(hub.addServer(entry.key, entry.value));
  }
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
              : SplashScreen(
                  prefs: _prefs!,
                  destination: DecisionScreen(prefs: _prefs!),
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
