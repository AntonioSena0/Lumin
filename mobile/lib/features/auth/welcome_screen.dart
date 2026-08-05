import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_assets.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/core/theme/lumin_spacing.dart';
import 'package:mobile/features/auth/login_screen.dart';
import 'package:mobile/features/auth/register_screen.dart';
import 'package:mobile/shared/widgets/lumin_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(LuminAssets.welcomePlanet, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.08),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: LuminSpacing.page,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  const WelcomeHeadline(),
                  const SizedBox(height: 30),
                  LuminButton(
                    label: 'Começar',
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                      child: const Text('Já possui conta? Faça o login'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class WelcomeHeadline extends StatelessWidget {
  const WelcomeHeadline({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explore',
          style: TextStyle(
            color: LuminColors.text,
            fontSize: 34,
            height: 0.98,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          'Aprenda',
          style: TextStyle(
            color: LuminColors.magenta,
            fontSize: 34,
            height: 0.98,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          'Conecte-se',
          style: TextStyle(
            color: LuminColors.blue,
            fontSize: 34,
            height: 0.98,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}
