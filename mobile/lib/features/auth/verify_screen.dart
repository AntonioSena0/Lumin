import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/main.dart';
import 'package:mobile/shared/widgets/back_title.dart';
import 'package:mobile/shared/widgets/lumin_button.dart';
import 'package:mobile/shared/widgets/lumin_field.dart';
import 'package:mobile/shared/widgets/lumin_page.dart';

class VerifyScreen extends StatefulWidget {
  const VerifyScreen({super.key, required this.email, this.onVerified, this.title = 'Verificar e-mail'});

  final String email;
  final VoidCallback? onVerified;
  final String title;

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final codeController = TextEditingController();
  String? error;
  bool loading = false;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> confirm() async {
    setState(() {
      loading = true;
      error = null;
    });
    final result = await luminApi.verify(email: widget.email, code: codeController.text.trim());
    if (!mounted) return;
    setState(() => loading = false);
    if (result.status == 204) {
      final refresh = await luminApi.refresh();
      if (!mounted) return;
      if (refresh.ok) {
        widget.onVerified?.call();
      } else {
        setState(() => error = 'Verificado! Faça login novamente.');
      }
    } else if (result.status == 429) {
      setState(() => error = 'Muitas tentativas. Aguarde antes de tentar de novo.');
    } else {
      setState(() => error = result.error);
    }
  }

  Future<void> resend() async {
    final result = await luminApi.resend(email: widget.email);
    if (!mounted) return;
    setState(() {
      error = result.status == 429 ? 'Aguarde antes de reenviar.' : null;
    });
    if (mounted && result.ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código reenviado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LuminPage(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BackTitle(title: widget.title),
          const SizedBox(height: 16),
          Text(
            'Enviamos um código de 6 dígitos para ${widget.email}.',
            style: const TextStyle(color: LuminColors.muted, height: 1.4),
          ),
          const SizedBox(height: 18),
          LuminField(label: 'Código', controller: codeController, keyboardType: TextInputType.number),
          if (error != null) ...[
            const SizedBox(height: 10),
            Text(error!, style: const TextStyle(color: LuminColors.danger, fontSize: 12)),
          ],
          const SizedBox(height: 22),
          LuminButton(label: loading ? 'Verificando...' : 'Confirmar', onPressed: loading ? () {} : confirm),
          const SizedBox(height: 12),
          Center(
            child: TextButton(onPressed: resend, child: const Text('Reenviar código')),
          ),
        ],
      ),
    );
  }
}
