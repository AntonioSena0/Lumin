import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/legal_screen.dart';
import 'package:mobile/features/auth/login_screen.dart';
import 'package:mobile/features/auth/verify_screen.dart';
import 'package:mobile/features/level_test/level_test_screen.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/lumin_button.dart';
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
  static const Color _violet = Color(0xFFB03CF0);

  final data = RegisterData();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  int step = 0;
  List<Map<String, dynamic>> languages = [];
  String? error;
  bool loading = false;
  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool acceptedTerms = false;

  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()
      ..onTap = () => openLegal(LegalSection.terms);
    _privacyTap = TapGestureRecognizer()
      ..onTap = () => openLegal(LegalSection.privacy);
    loadLanguages();
  }

  void openLegal(LegalSection section) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LegalScreen(initialSection: section),
      ),
    );
  }

  @override
  void dispose() {
    _termsTap.dispose();
    _privacyTap.dispose();
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
      languages = result.list
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
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
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        passwordController.text.length < 8) {
      setState(
        () => error = 'Preencha nome, e-mail e senha (mínimo 8 caracteres).',
      );
      return;
    }
    if (!acceptedTerms) {
      setState(
        () => error =
            'Aceite os Termos de Uso e a Política de Privacidade para continuar.',
      );
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

  Future<void> submit() async {
    if (!acceptedTerms) {
      setState(
        () => error =
            'Aceite os Termos de Uso e a Política de Privacidade para se cadastrar.',
      );
      return;
    }
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
    } else {
      setState(() => error = result.error);
    }
  }

  void goBack() {
    if (step == 1) {
      setState(() {
        step = 0;
        error = null;
      });
    } else {
      Navigator.of(context).pop();
    }
  }

  void goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  List<Widget> stepOneFields() {
    return [
      LuminField(
        label: 'Nome de Usuário',
        labelAbove: true,
        labelInset: 14,
        controller: nameController,
      ),
      const SizedBox(height: 14),
      LuminField(
        label: 'E-mail',
        labelAbove: true,
        labelInset: 14,
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
      ),
      const SizedBox(height: 14),
      LuminField(
        label: 'Senha',
        labelAbove: true,
        labelInset: 14,
        controller: passwordController,
        obscureText: obscurePassword,
        icon: obscurePassword ? Icons.visibility_off : Icons.visibility,
        onIconTap: () => setState(() => obscurePassword = !obscurePassword),
      ),
      const SizedBox(height: 14),
      LuminField(
        label: 'Confirmar Senha',
        labelAbove: true,
        labelInset: 14,
        controller: confirmController,
        obscureText: obscureConfirm,
        icon: obscureConfirm ? Icons.visibility_off : Icons.visibility,
        onIconTap: () => setState(() => obscureConfirm = !obscureConfirm),
      ),
      const SizedBox(height: 18),
      InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => setState(() => acceptedTerms = !acceptedTerms),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: acceptedTerms,
                  onChanged: (v) =>
                      setState(() => acceptedTerms = v ?? false),
                  side: const BorderSide(color: _violet, width: 1.5),
                  checkColor: Colors.white,
                  fillColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? _violet
                        : const Color(0xFF2A0A4A),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    children: [
                      const TextSpan(text: 'Eu aceito os '),
                      TextSpan(
                        text: 'Termos de Uso',
                        style: const TextStyle(color: _violet),
                        recognizer: _termsTap,
                      ),
                      const TextSpan(text: ' e '),
                      TextSpan(
                        text: 'Política de Privacidade.',
                        style: const TextStyle(color: _violet),
                        recognizer: _privacyTap,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> stepTwoFields() {
    return [
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
    ];
  }

  @override
  Widget build(BuildContext context) {
    final first = step == 0;
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                        child: IconButton(
                          tooltip: 'Voltar',
                          onPressed: goBack,
                          icon: const Icon(
                            Icons.arrow_back,
                            size: 28,
                            color: LuminColors.text,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      first ? 'Cadastro' : 'Idiomas',
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      first
                                          ? 'Crie sua conta e comece agora!'
                                          : 'Escolha sua língua nativa e a de estudo',
                                      style: const TextStyle(
                                        color: LuminColors.text,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              ...(first ? stepOneFields() : stepTwoFields()),
                              if (error != null) ...[
                                const SizedBox(height: 10),
                                Text(
                                  error!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              Center(
                                child: SizedBox(
                                  width: 243,
                                  child: LuminButton(
                                    label: first
                                        ? 'Cadastrar'
                                        : (loading
                                            ? 'Cadastrando...'
                                            : 'Concluir cadastro'),
                                    onPressed:
                                        first ? next : (loading ? () {} : submit),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              const SizedBox(height: 12),
                              Center(
                                child: TextButton(
                                  onPressed: goToLogin,
                                  child: const Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Já possui uma conta? ',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
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
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class LanguagePicker extends StatelessWidget {
  const LanguagePicker({
    super.key,
    required this.label,
    required this.languages,
    required this.selectedId,
    required this.onSelect,
  });

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