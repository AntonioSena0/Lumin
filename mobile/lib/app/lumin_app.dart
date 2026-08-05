import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/auth/welcome_screen.dart';

class LuminApp extends StatelessWidget {
  const LuminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lumin',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: LuminColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: LuminColors.magenta,
          brightness: Brightness.dark,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}
