import 'package:flutter/material.dart';
import 'package:mobile/features/auth/auth_scaffold.dart';
import 'package:mobile/features/auth/register_screen.dart';
import 'package:mobile/features/level_test/level_test_screen.dart';
import 'package:mobile/shared/widgets/lumin_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Login',
      subtitle: 'Entre para continuar aprendendo sem limites',
      action: 'Entrar',
      footer: 'Não possui uma conta? Cadastre-se',
      onAction: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LevelTestScreen()),
      ),
      onFooter: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
      children: const [
        LuminField(label: 'E-mail'),
        SizedBox(height: 14),
        LuminField(
          label: 'Senha',
          obscureText: true,
          icon: Icons.visibility_off,
        ),
      ],
    );
  }
}
