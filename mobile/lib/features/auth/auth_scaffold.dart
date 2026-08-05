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
  });

  final String title;
  final String subtitle;
  final String action;
  final String footer;
  final List<Widget> children;
  final VoidCallback onAction;
  final VoidCallback onFooter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                    width: 118,
                    height: 118,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(color: LuminColors.muted)),
              const SizedBox(height: 22),
              ...children,
              const SizedBox(height: 24),
              LuminButton(label: action, onPressed: onAction),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Container(height: 1, color: LuminColors.panelLight),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'ou continue com',
                      style: TextStyle(color: LuminColors.muted, fontSize: 12),
                    ),
                  ),
                  Expanded(
                    child: Container(height: 1, color: LuminColors.panelLight),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Row(
                children: [
                  Expanded(child: SocialButton(label: 'G')),
                  SizedBox(width: 10),
                  Expanded(child: SocialButton(label: 'X')),
                  SizedBox(width: 10),
                  Expanded(child: SocialButton(label: 'f')),
                ],
              ),
              const Spacer(),
              Center(
                child: TextButton(
                  onPressed: onFooter,
                  child: Text(footer, style: const TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  const SocialButton({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: LuminColors.text,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: LuminColors.background,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
