import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_spacing.dart';

class LuminPage extends StatelessWidget {
  const LuminPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(padding: LuminSpacing.page, child: child),
      ),
    );
  }
}
