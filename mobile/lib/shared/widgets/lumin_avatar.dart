import 'dart:typed_data';

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

  static final Map<String, Future<Uint8List?>> _imageCache = {};

  static Future<Uint8List?> _loadImage(String url) {
    return _imageCache.putIfAbsent(url, () => luminApi.assetBytes(url));
  }

  @override
  Widget build(BuildContext context) {
    final resolved = imgUrl == null || imgUrl!.isEmpty
        ? null
        : resolveAssetUrl(imgUrl!);
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();

    return ClipOval(
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: LuminColors.text),
            if (resolved != null)
              FutureBuilder(
                future: _loadImage(resolved),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                    );
                  }
                  return Center(
                    child: Text(
                      initial,
                      style: TextStyle(
                        color: LuminColors.background,
                        fontSize: radius * 0.85,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  );
                },
              )
            else
              Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    color: LuminColors.background,
                    fontSize: radius * 0.85,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
