import 'package:flutter/material.dart';
import 'package:memic_io/screens/landing.dart';
import 'package:memic_io/screens/translator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Memic',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LandingScreen(),
        '/translate': (context) => Translator(),
      },
    );
  }
}
