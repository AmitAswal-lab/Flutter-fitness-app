import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:fitness_app/features/dashboard/presentation/pages/homepage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Homepage(),
    );
  }
}
