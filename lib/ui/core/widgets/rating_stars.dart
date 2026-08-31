import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Fila de 5 estrellas. En modo lectura acepta una valoración fraccional
/// (p. ej. 4.5 para una media); en modo interactivo (`onRate` no nulo) cada
/// estrella es un objetivo de toque completo (1..5).
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.rating,
    this.size = 18,
    this.color,
    this.onRate,
  });

  final double rating;
  final double size;
  final Color? color;
  final ValueChanged<int>? onRate;

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? AppColors.brand500;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final fill = (rating - index).clamp(0.0, 1.0);
        final star = _Star(fill: fill, size: size, color: starColor);
        if (onRate == null) return star;
        return GestureDetector(
          key: ValueKey('rating-star-${index + 1}'),
          behavior: HitTestBehavior.opaque,
          onTap: () => onRate!(index + 1),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: star,
          ),
        );
      }),
    );
  }
}

class _Star extends StatelessWidget {
  const _Star({required this.fill, required this.size, required this.color});

  final double fill;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Icon(Icons.star_rounded, size: size, color: color.withValues(alpha: 0.25)),
          ClipRect(
            clipper: _FractionClipper(fill),
            child: Icon(Icons.star_rounded, size: size, color: color),
          ),
        ],
      ),
    );
  }
}

class _FractionClipper extends CustomClipper<Rect> {
  _FractionClipper(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) =>
      Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(covariant _FractionClipper oldClipper) =>
      oldClipper.fraction != fraction;
}
