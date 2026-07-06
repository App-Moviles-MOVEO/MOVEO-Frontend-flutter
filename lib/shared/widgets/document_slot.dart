import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';

/// Fila para subir un documento (KYC, propiedad del vehículo):
/// miniatura o placeholder, etiqueta y check al completar.
class DocumentSlot extends StatelessWidget {
  final String label;

  /// Ruta local o URL del documento ya capturado, o `null` si falta.
  final String? filePath;
  final VoidCallback onTap;

  const DocumentSlot({
    super.key,
    required this.label,
    required this.filePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final path = filePath;
    return Semantics(
      label: label,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _thumbnail(path),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: AppTextStyles.body)),
            Icon(
              path == null ? Icons.chevron_right : Icons.check_circle,
              color: path == null
                  ? AppColors.textSecondary
                  : AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _thumbnail(String? path) {
    final placeholder = Container(
      width: 88,
      height: 60,
      color: AppColors.surface,
      child: Icon(
        path == null ? Icons.add_a_photo_outlined : Icons.description_outlined,
        color: AppColors.textSecondary,
      ),
    );
    if (path == null) return placeholder;
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        width: 88,
        height: 60,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => placeholder,
      );
    }
    return Image.file(
      File(path),
      width: 88,
      height: 60,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}
