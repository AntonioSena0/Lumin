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

          const SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 21, top: 12),
                child: WelcomeBrand(),
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
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Center(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      child: const Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Já possui conta? ',
                              style: TextStyle(color: Colors.white),
                            ),
                            TextSpan(
                              text: 'Faça o Login',
                              style: TextStyle(
                                color: LuminColors.blue,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
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

class WelcomeBrand extends StatelessWidget {
  const WelcomeBrand({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      label: 'Lumin',
      child: ExcludeSemantics(
        child: Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: 'Lu',
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: 'min',
                style: TextStyle(
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [Color(0xFF9B3DF0), Color(0xFFD62BE0)],
                    ).createShader(const Rect.fromLTWH(0, 0, 40, 24)),
                ),
              ),
            ],
          ),
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            height: 1.5,
          ),
        ),
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