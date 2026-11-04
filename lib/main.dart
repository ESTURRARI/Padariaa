import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() => runApp(const PadariaApp());

class PadariaApp extends StatelessWidget {
  const PadariaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Pão Quente',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.brown, useMaterial3: true),
        home: const HomeScreen(),
      );
}