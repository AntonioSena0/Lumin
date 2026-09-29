import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_spacing.dart';

class LuminPage extends StatelessWidget {
  const LuminPage({super.key, required this.child, this.scrollable = true});

  final Widget child;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: scrollable
            ? SingleChildScrollView(padding: LuminSpacing.page, child: child)
            : Padding(padding: LuminSpacing.page, child: child),
      ),
    );
  }
}
