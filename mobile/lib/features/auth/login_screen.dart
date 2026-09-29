import 'package:flutter/material.dart';
import 'package:mobile/features/auth/auth_scaffold.dart';
import 'package:mobile/features/auth/google_auth.dart';
import 'package:mobile/features/auth/register_screen.dart';
import 'package:mobile/features/auth/reset_password_screen.dart';
import 'package:mobile/features/auth/verify_screen.dart';
import 'package:mobile/features/shell/app_shell.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/lumin_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? error;
  bool loading = false;
  bool loadingGoogle = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AppShell()),
      (route) => false,
    );
  }

  Future<void> submit() async {
    setState(() {
      loading = true;
      error = null;
    });
    final result = await luminApi.login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );
    if (!mounted) return;
    setState(() => loading = false);
    if (result.status == 204) {
      goHome();
    } else if (result.status == 403) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerifyScreen(email: emailController.text.trim(), onVerified: goHome),
        ),
      );
    } else {
      setState(() => error = result.error);
    }
  }

  Future<void> signInWithGoogle() async {
    if (!GoogleAuthService.isConfigured) {
      setState(() => error = 'Login social ainda não configurado neste build.');
      return;
    }
    setState(() {
      loadingGoogle = true;
      error = null;
    });
    try {
      final result = await GoogleAuthService.login();
      if (!mounted) return;
      if (result.loggedIn) {
        goHome();
        return;
      }
      final pending = result.pending;
      if (pending == null) {
        setState(() => error = 'Não foi possível entrar com o Google.');
        return;
      }
      final created = await Navigator.of(context).push<bool>(
        MaterialPageRoute(builder: (_) => GoogleRegisterScreen(pending: pending)),
      );
      if (!mounted) return;
      if (created == true) {
        goHome();
      } else {
        setState(() => error = 'Cadastro com Google cancelado.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => error = 'Falha no login social: $e');
    } finally {
      if (mounted) setState(() => loadingGoogle = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Login',
      subtitle: 'Entre para continuar aprendendo sem limites',
      action: loading ? 'Entrando...' : 'Entrar',
      footer: 'Não possui uma conta? Cadastre-se',
      onAction: loading ? () {} : submit,
      onGoogle: loadingGoogle ? () {} : signInWithGoogle,
      onFooter: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      ),
      children: [
        LuminField(label: 'E-mail', controller: emailController, keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 14),
        LuminField(
          label: 'Senha',
          controller: passwordController,
          obscureText: true,
          icon: Icons.visibility_off,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
            ),
            child: const Text('Esqueci a senha?', style: TextStyle(fontSize: 12)),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 10),
          Text(error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
        ],
      ],
    );
  }
}
