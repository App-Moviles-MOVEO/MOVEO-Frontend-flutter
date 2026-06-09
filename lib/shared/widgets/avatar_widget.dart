import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';

/// Avatar circular con imagen cacheada o iniciales como fallback.
class AvatarWidget extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double radius;
  final bool showVerifiedBadge;

  const AvatarWidget({
    super.key,
    this.imageUrl,
    required this.name,
    this.radius = 24,
    this.showVerifiedBadge = false,
  });

  String get _initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryDark,
      foregroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
          ? CachedNetworkImageProvider(imageUrl!)
          : null,
      child: Text(
        _initials,
        style: AppTextStyles.body.copyWith(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return Semantics(
      label: 'Foto de perfil de $name',
      image: true,
      child: showVerifiedBadge
          ? Stack(
              clipBehavior: Clip.none,
              children: [
                avatar,
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified,
                      size: radius * 0.65,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            )
          : avatar,
    );
  }
}
