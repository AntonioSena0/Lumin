import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/features/auth/welcome_screen.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_button.dart';
import 'package:mobile/shared/widgets/lumin_field.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  String email = '';
  bool codeSent = false;
  bool loading = true;
  bool sending = false;
  String? error;
  String? notice;

  @override
  void initState() {
    super.initState();
    requestCode();
  }

  @override
  void dispose() {
    codeController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> requestCode() async {
    setState(() {
      loading = true;
      error = null;
    });
    final me = await luminApi.me();
    if (!mounted) return;
    final address = '${me.map['email'] ?? ''}';
    final response = await luminApi.requestPasswordChange();
    if (!mounted) return;
    setState(() {
      loading = false;
      if (response.ok) {
        email = address;
        codeSent = true;
        notice = 'Enviamos um código de 6 dígitos para $address.';
      } else {
        error = response.error;
      }
    });
  }

  Future<void> confirm() async {
    if (passwordController.text != confirmController.text) {
      setState(() => error = 'As senhas não conferem.');
      return;
    }
    if (passwordController.text.length < 8) {
      setState(() => error = 'A senha precisa ter ao menos 8 caracteres.');
      return;
    }
    if (codeController.text.trim().length != 6) {
      setState(() => error = 'Informe o código de 6 dígitos.');
      return;
    }

    setState(() {
      sending = true;
      error = null;
      notice = null;
    });

    final response = await luminApi.confirmPasswordChange(
      email: email,
      code: codeController.text.trim(),
      newPassword: passwordController.text,
    );

    if (!mounted) return;
    setState(() => sending = false);

    if (response.ok) {
      setState(() {
        codeSent = false;
        notice = 'Senha alterada. Entre novamente com a nova senha.';
      });
      await luminApi.logout();
      if (!mounted) return;
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      });
      return;
    }

    setState(() => error = response.error);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const LuminPage(child: Center(child: CircularProgressIndicator()));
    }

    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BackTitle(title: 'Alterar senha'),
          const SizedBox(height: 16),
          Text(
            codeSent
                ? 'Confirme com o código enviado para $email.'
                : 'Não foi possível enviar o código agora.',
            style: const TextStyle(color: LuminColors.muted, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 18),
          if (notice != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.greenAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                notice!,
                style: const TextStyle(color: Colors.greenAccent, fontSize: 12),
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (error != null) ...[
            Text(error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
            const SizedBox(height: 14),
          ],
          LuminField(
            label: 'Código de verificação',
            controller: codeController,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 14),
          LuminField(
            label: 'Nova senha',
            controller: passwordController,
            obscureText: true,
            icon: Icons.visibility_off,
          ),
          const SizedBox(height: 14),
          LuminField(
            label: 'Confirmar nova senha',
            controller: confirmController,
            obscureText: true,
            icon: Icons.visibility_off,
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: sending ? () {} : requestCode,
              child: const Text('Reenviar código'),
            ),
          ),
          const SizedBox(height: 10),
          LuminButton(
            label: sending ? 'Alterando...' : 'Alterar senha',
            onPressed: sending || !codeSent ? () {} : confirm,
          ),
        ],
      ),
    );
  }
}
