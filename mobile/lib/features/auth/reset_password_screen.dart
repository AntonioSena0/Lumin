import 'package:flutter/material.dart';
import 'package:mobile/features/auth/login_screen.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_button.dart';
import 'package:mobile/shared/widgets/lumin_field.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  String? error;
  bool loading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() {
      loading = true;
      error = null;
    });
    final result = await luminApi.forgotPassword(email: emailController.text.trim());
    if (!mounted) return;
    setState(() => loading = false);
    if (result.ok) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ResetPasswordScreen(email: emailController.text.trim())),
      );
    } else {
      setState(() => error = result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BackTitle(title: 'Esqueci a senha'),
          const SizedBox(height: 16),
          LuminField(label: 'E-mail', controller: emailController, keyboardType: TextInputType.emailAddress),
          if (error != null) ...[
            const SizedBox(height: 10),
            Text(error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ],
          const SizedBox(height: 22),
          LuminButton(label: loading ? 'Enviando...' : 'Enviar código', onPressed: loading ? () {} : submit),
        ],
      ),
    );
  }
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key, required this.email});

  final String email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final codeController = TextEditingController();
  final passwordController = TextEditingController();
  String? error;
  bool loading = false;

  @override
  void dispose() {
    codeController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() {
      loading = true;
      error = null;
    });
    final result = await luminApi.resetPassword(
      email: widget.email,
      code: codeController.text.trim(),
      newPassword: passwordController.text,
    );
    if (!mounted) return;
    setState(() => loading = false);
    if (result.ok) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    } else {
      setState(() => error = result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const BackTitle(title: 'Nova senha'),
          const SizedBox(height: 16),
          LuminField(label: 'Código', controller: codeController, keyboardType: TextInputType.number),
          const SizedBox(height: 14),
          LuminField(label: 'Nova senha', controller: passwordController, obscureText: true),
          if (error != null) ...[
            const SizedBox(height: 10),
            Text(error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
          ],
          const SizedBox(height: 22),
          LuminButton(label: loading ? 'Salvando...' : 'Salvar senha', onPressed: loading ? () {} : submit),
        ],
      ),
    );
  }
}
