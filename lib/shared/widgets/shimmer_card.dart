import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';

/// Placeholder con efecto shimmer para listas y cards en carga.
class ShimmerCard extends StatelessWidget {
  final double height;
  final double? width;
  final BorderRadiusGeometry borderRadius;

  const ShimmerCard({
    super.key,
    this.height = 120,
    this.width,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceElevated,
      highlightColor: AppColors.divider,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

/// Lista vertical de shimmer cards para estados de carga.
class ShimmerList extends StatelessWidget {
  final int count;
  final double itemHeight;

  const ShimmerList({super.key, this.count = 4, this.itemHeight = 120});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => ShimmerCard(height: itemHeight),
    );
  }
}
