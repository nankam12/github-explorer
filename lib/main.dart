import 'package:flutter/material.dart';

import 'screens/search_screen.dart';

void main() {
  runApp(const GithubExplorerApp());
}

class GithubExplorerApp extends StatelessWidget {
  const GithubExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitHub Explorer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        useMaterial3: true,
        visualDensity: VisualDensity.standard,
        appBarTheme: const AppBarTheme(centerTitle: true),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.blueGrey.shade100),
          ),
        ),
      ),
      home: const SearchScreen(),
    );
  }
}
