import 'package:flutter/material.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';

/// Estrellas de calificación. Si [onChanged] no es null, es interactivo.
class RatingStars extends StatelessWidget {
  final double rating;
  final double size;
  final void Function(int)? onChanged;

  const RatingStars({
    super.key,
    required this.rating,
    this.size = 18,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Calificación: ${rating.toStringAsFixed(1)} de 5 estrellas',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(5, (i) {
          final filled = rating >= i + 1;
          final half = !filled && rating > i && rating < i + 1;
          final star = Icon(
            filled
                ? Icons.star_rounded
                : half
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded,
            size: size,
            color: AppColors.warning,
          );
          if (onChanged == null) return star;
          return Semantics(
            label: '${i + 1} estrellas',
            button: true,
            child: GestureDetector(
              onTap: () => onChanged!(i + 1),
              child: star,
            ),
          );
        }),
      ),
    );
  }
}
