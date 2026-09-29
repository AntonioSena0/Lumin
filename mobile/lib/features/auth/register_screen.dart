import 'package:flutter/material.dart';
import 'package:mobile/features/auth/auth_scaffold.dart';
import 'package:mobile/features/auth/google_auth.dart';
import 'package:mobile/features/auth/verify_screen.dart';
import 'package:mobile/features/level_test/level_test_screen.dart';
import 'package:mobile/features/shell/app_shell.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/lumin_field.dart';

class RegisterData {
  String name = '';
  String email = '';
  String password = '';
  int? nativeLanguage;
  int? chosenLanguage;
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final data = RegisterData();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  int step = 0;
  List<Map<String, dynamic>> languages = [];
  String? error;
  bool loading = false;
  bool loadingGoogle = false;

  @override
  void initState() {
    super.initState();
    loadLanguages();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> loadLanguages() async {
    final result = await luminApi.languages();
    if (!mounted) return;
    setState(() {
      languages = result.list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    });
  }

  int? languageIdByCode(String code) {
    for (final lang in languages) {
      final raw = (lang['code'] ?? '').toString().toLowerCase();
      if (raw == code.toLowerCase() || raw.startsWith(code.toLowerCase())) {
        final id = lang['id'];
        if (id is int) return id;
      }
    }
    return languages.isNotEmpty ? languages.first['id'] as int? : null;
  }

  void next() {
    if (passwordController.text != confirmController.text) {
      setState(() => error = 'As senhas não conferem.');
      return;
    }
    if (nameController.text.trim().isEmpty || emailController.text.trim().isEmpty || passwordController.text.length < 8) {
      setState(() => error = 'Preencha nome, e-mail e senha (mínimo 8 caracteres).');
      return;
    }
    setState(() {
      data.name = nameController.text.trim();
      data.email = emailController.text.trim();
      data.password = passwordController.text;
      data.nativeLanguage ??= languageIdByCode('pt');
      data.chosenLanguage ??= languageIdByCode('en');
      error = null;
      step = 1;
    });
  }

  void goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const AppShell()),
      (route) => false,
    );
  }

  Future<void> signUpWithGoogle() async {
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
      setState(() => error = 'Falha no cadastro social: $e');
    } finally {
      if (mounted) setState(() => loadingGoogle = false);
    }
  }

  Future<void> submit() async {
    if (data.nativeLanguage == null || data.chosenLanguage == null) {
      setState(() => error = 'Escolha os idiomas.');
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    final result = await luminApi.register(
      name: data.name,
      email: data.email,
      password: data.password,
      nativeLanguage: data.nativeLanguage!,
      chosenLanguage: data.chosenLanguage!,
    );
    if (!mounted) return;
    setState(() => loading = false);
    if (result.status == 201) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VerifyScreen(
            email: data.email,
            onVerified: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const LevelTestScreen()),
            ),
          ),
        ),
      );
    } else if (result.status == 409) {
      setState(() => error = result.error);
    } else {
      setState(() => error = result.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: step == 0 ? 'Cadastro' : 'Idiomas',
      subtitle: step == 0 ? 'Crie sua conta e comece agora' : 'Escolha sua língua nativa e a de estudo',
      action: step == 0 ? 'Continuar' : (loading ? 'Cadastrando...' : 'Cadastrar'),
      footer: 'Já possui uma conta? Faça o login',
      onAction: step == 0 ? next : (loading ? () {} : submit),
      onFooter: () => Navigator.of(context).pop(),
      onGoogle: step == 0 && !loadingGoogle ? signUpWithGoogle : null,
      children: step == 0
          ? [
              LuminField(label: 'Nome de usuário', controller: nameController),
              const SizedBox(height: 14),
              LuminField(label: 'E-mail', controller: emailController, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 14),
              LuminField(label: 'Senha', controller: passwordController, obscureText: true, icon: Icons.visibility_off),
              const SizedBox(height: 14),
              LuminField(label: 'Confirmar senha', controller: confirmController, obscureText: true, icon: Icons.visibility_off),
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],
            ]
          : [
              LanguagePicker(
                label: 'Língua nativa',
                languages: languages,
                selectedId: data.nativeLanguage,
                onSelect: (id) => setState(() => data.nativeLanguage = id),
              ),
              const SizedBox(height: 14),
              LanguagePicker(
                label: 'Idioma de estudo',
                languages: languages,
                selectedId: data.chosenLanguage,
                onSelect: (id) => setState(() => data.chosenLanguage = id),
              ),
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
              ],
            ],
    );
  }
}

class LanguagePicker extends StatelessWidget {
  const LanguagePicker({super.key, required this.label, required this.languages, required this.selectedId, required this.onSelect});

  final String label;
  final List<Map<String, dynamic>> languages;
  final int? selectedId;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final lang in languages)
              ChoiceChip(
                label: Text((lang['name'] ?? '').toString()),
                selected: lang['id'] == selectedId,
                onSelected: (_) {
                  final id = lang['id'];
                  if (id is int) onSelect(id);
                },
              ),
          ],
        ),
      ],
    );
  }
}
