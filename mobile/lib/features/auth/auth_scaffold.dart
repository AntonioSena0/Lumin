import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_assets.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/core/theme/lumin_spacing.dart';
import 'package:mobile/shared/widgets/lumin_button.dart';

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.footer,
    required this.children,
    required this.onAction,
    required this.onFooter,
    this.footerAction,
    this.onGoogle,
  });

  final String title;
  final String subtitle;
  final String action;

  /// Texto do rodapé. Se [footerAction] for informado, [footer] aparece em
  /// branco e [footerAction] em azul/itálico (ex.: "Cadastre-se").
  final String footer;
  final String? footerAction;
  final List<Widget> children;
  final VoidCallback onAction;
  final VoidCallback onFooter;
  final VoidCallback? onGoogle;

  @override
  Widget build(BuildContext context) {
    // Logo proporcional à largura da tela (~55%), entre 190 e 260 px.
    final logoSize =
        (MediaQuery.of(context).size.width * 0.55).clamp(190.0, 260.0);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: LuminSpacing.page,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: ClipOval(
                            child: Image.asset(
                              LuminAssets.logo,
                              width: logoSize,
                              height: logoSize,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: LuminColors.text,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 22),
                        ...children,
                        const SizedBox(height: 20),
                        Center(
                          child: SizedBox(
                            width: 243,
                            child: LuminButton(
                              label: action,
                              onPressed: onAction,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: LuminColors.panelLight,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text(
                                'ou continue com',
                                style: TextStyle(
                                  color: LuminColors.muted,
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: LuminColors.panelLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SocialButton(label: 'G', onTap: onGoogle),
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(height: 12),
                        Center(
                          child: TextButton(
                            onPressed: onFooter,
                            child: footerAction == null
                                ? Text(
                                    footer,
                                    style: const TextStyle(fontSize: 12),
                                  )
                                : Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: '$footer ',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        TextSpan(
                                          text: footerAction,
                                          style: const TextStyle(
                                            color: LuminColors.blue,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                          ),
                        ),
                      ],
                    ),
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

class SocialButton extends StatelessWidget {
  const SocialButton({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isGoogle = label == 'G';
    return Semantics(
      button: true,
      label: isGoogle ? 'Entrar com o Google' : label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 108,
          height: 42,
          decoration: BoxDecoration(
            color: isGoogle ? const Color(0xFFE6F4FF) : LuminColors.text,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: isGoogle
                ? const _GoogleG()
                : Text(
                    label,
                    style: const TextStyle(
                      color: LuminColors.background,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// "G" do Google com as quatro cores oficiais.
class _GoogleG extends StatelessWidget {
  const _GoogleG();

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF4285F4);
    const green = Color(0xFF34A853);
    const yellow = Color(0xFFFBBC05);
    const red = Color(0xFFEA4335);
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (rect) => const SweepGradient(
        colors: [blue, blue, green, green, yellow, yellow, red, red, blue, blue],
        stops: [0.0, 0.12, 0.13, 0.37, 0.38, 0.57, 0.58, 0.88, 0.89, 1.0],
      ).createShader(rect),
      child: const Text(
        'G',
        style: TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}