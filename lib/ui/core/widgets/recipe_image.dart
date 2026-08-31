import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// Imagen de receta con esquinas redondeadas y un placeholder de marca
/// consistente cuando no hay `image_url` (el caso más común en los datos
/// de ejemplo del backend).
class RecipeImage extends StatelessWidget {
  const RecipeImage({
    super.key,
    required this.imageUrl,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.height,
    this.width,
  });

  final String? imageUrl;
  final BorderRadius borderRadius;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        height: height,
        width: width,
        child: url == null || url.isEmpty
            ? _placeholder(context)
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (context, _) => _placeholder(context),
                errorWidget: (context, _, _) => _placeholder(context),
              ),
      ),
    );
  }

  Widget _placeholder(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? AppColors.brand900 : AppColors.brand50,
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant_rounded,
        color: isDark ? AppColors.brand300 : AppColors.brand400,
        size: (height ?? 96) * 0.32,
      ),
    );
  }
}
