import 'package:flutter/material.dart';
import 'package:spotfit/core/theme.dart';

class CoverImage extends StatelessWidget {
  const CoverImage({
    super.key,
    required this.url,
    this.size = 56,
    this.radius = 12,
  });

  final String? url;
  final double size;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: SizedBox(
        width: size,
        height: size,
        child: url == null
            ? const ColoredBox(
                color: SpotFitColors.surfaceHigh,
                child: Icon(Icons.graphic_eq_rounded, color: SpotFitColors.lime),
              )
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: SpotFitColors.surfaceHigh,
                  child: Icon(Icons.graphic_eq_rounded, color: SpotFitColors.lime),
                ),
              ),
      ),
    );
  }
}
