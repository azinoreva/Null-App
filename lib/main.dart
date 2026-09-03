import 'package:flutter/material.dart';
import '/screens/splash_screen.dart';   // 👈 import your splash screen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SplashScreen(), // 👈 launch the splash screen
      debugShowCheckedModeBanner: false,
    );
  }
}