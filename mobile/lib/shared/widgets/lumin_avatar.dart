import 'package:flutter/material.dart';
import 'package:mobile/core/theme/lumin_colors.dart';
import 'package:mobile/main.dart';

class LuminAvatar extends StatelessWidget {
  const LuminAvatar({
    super.key,
    required this.imgUrl,
    required this.name,
    this.radius = 26,
  });

  final String? imgUrl;
  final String name;
  final double radius;

  /// Mostra a imagem do avatar via rede ou a inicial do nome enquanto carrega ou se falhar.
  @override
  Widget build(BuildContext context) {
    final resolved = imgUrl == null || imgUrl!.isEmpty
        ? null
        : resolveAssetUrl(imgUrl!);
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    final fallback = Center(
      child: Text(
        initial,
        style: TextStyle(
          color: LuminColors.background,
          fontSize: radius * 0.85,
          fontWeight: FontWeight.w900,
        ),
      ),
    );

    return ClipOval(
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: LuminColors.text),
            if (resolved != null)
              Image.network(
                resolved,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : fallback,
                errorBuilder: (_, _, _) => fallback,
              )
            else
              fallback,
          ],
        ),
      ),
    );
  }
}
