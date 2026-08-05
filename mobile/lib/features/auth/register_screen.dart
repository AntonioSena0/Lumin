import 'package:flutter/material.dart';
import 'package:mobile/features/auth/auth_scaffold.dart';
import 'package:mobile/features/level_test/level_test_screen.dart';
import 'package:mobile/shared/widgets/lumin_field.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Cadastro',
      subtitle: 'Crie sua conta e comece agora',
      action: 'Cadastrar',
      footer: 'Já possui uma conta? Faça o login',
      onAction: () => Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LevelTestScreen()),
      ),
      onFooter: () => Navigator.of(context).pop(),
      children: const [
        LuminField(label: 'Nome de usuário'),
        SizedBox(height: 14),
        LuminField(label: 'E-mail'),
        SizedBox(height: 14),
        LuminField(
          label: 'Senha',
          obscureText: true,
          icon: Icons.visibility_off,
        ),
        SizedBox(height: 14),
        LuminField(
          label: 'Confirmar senha',
          obscureText: true,
          icon: Icons.visibility_off,
        ),
      ],
    );
  }
}
