import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';

/// Fila para subir un documento (KYC, propiedad del vehículo):
/// miniatura o placeholder, etiqueta y check al completar.
class DocumentSlot extends StatelessWidget {
  final String label;
  final XFile? file;
  final VoidCallback onTap;

  const DocumentSlot({
    super.key,
    required this.label,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
              child: file == null
                  ? Container(
                      width: 88,
                      height: 60,
                      color: AppColors.surface,
                      child: const Icon(
                        Icons.add_a_photo_outlined,
                        color: AppColors.textSecondary,
                      ),
                    )
                  : Image.file(
                      File(file!.path),
                      width: 88,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(label, style: AppTextStyles.body)),
            Icon(
              file == null ? Icons.chevron_right : Icons.check_circle,
              color: file == null
                  ? AppColors.textSecondary
                  : AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}
