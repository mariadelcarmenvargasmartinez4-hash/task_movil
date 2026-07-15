import 'package:flutter/material.dart';
import 'config/theme/app_theme.dart';
import 'Presentation/screens/home_screen.dart';

void main() {
  runApp(const HomeTaskApp());
}

class HomeTaskApp extends StatelessWidget {
  const HomeTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HomeTask Smart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
