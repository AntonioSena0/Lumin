import 'package:flutter/material.dart';
import 'package:mobile/core/i18n/i18n.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/auth/welcome_screen.dart';
import 'package:mobile/features/shell/app_shell.dart';
import 'package:mobile/main.dart';

class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  @override
  void initState() {
    super.initState();
    checkSession();
  }

  /// Aplica o idioma (configurações se logado, IP se visitante) e abre o app ou a tela de boas-vindas.
  Future<void> checkSession() async {
    final response = await luminApi.me();
    final language = response.ok
        ? (await luminApi.settings()).map['appLanguage']
        : (await luminApi.detectLanguage()).data;
    applyLanguage(language);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => response.ok ? const AppShell() : const WelcomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: LuminColors.magenta, size: 44),
            SizedBox(height: 18),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
