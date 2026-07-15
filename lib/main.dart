import 'package:flutter/material.dart';
import 'config/theme/app_theme.dart';
import 'config/router/app_router.dart';

void main() {
  runApp(const HomeTaskApp());
}

class HomeTaskApp extends StatelessWidget {
  const HomeTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HomeTask Smart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}
