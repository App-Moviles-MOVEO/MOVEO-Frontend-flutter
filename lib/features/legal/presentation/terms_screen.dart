import 'package:flutter/material.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/features/legal/terms_content.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';

/// Términos y Condiciones de uso (US: legal). Renderiza [termsSections]
/// con el estilo de la app en una vista desplazable.
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.termsAndConditions)),
      body: const _TermsBody(),
    );
  }
}

/// Cuerpo reutilizable (también se usa en la hoja del registro).
class _TermsBody extends StatelessWidget {
  const _TermsBody();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: const [
        _TermsContentColumn(),
      ],
    );
  }
}

/// Columna con el encabezado y todas las secciones. Separada para poder
/// reutilizarla dentro de un bottom sheet desplazable.
class _TermsContentColumn extends StatelessWidget {
  const _TermsContentColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('WheelsPe · MOVEO', style: AppTextStyles.headline),
        const SizedBox(height: 4),
        Text(
          'Términos y Condiciones de Uso',
          style: AppTextStyles.subtitle,
        ),
        const SizedBox(height: 6),
        Text(
          'Última actualización: $termsLastUpdated · $termsVersion',
          style: AppTextStyles.caption,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.4),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline,
                  size: 18, color: AppColors.warning),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  termsDisclaimer,
                  style: AppTextStyles.caption,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(termsIntro, style: AppTextStyles.bodySecondary),
        const SizedBox(height: 20),
        for (final section in termsSections) ...[
          Text(section.title, style: AppTextStyles.title),
          const SizedBox(height: 8),
          for (final paragraph in section.paragraphs)
            _Paragraph(text: paragraph),
          const SizedBox(height: 18),
        ],
      ],
    );
  }
}

class _Paragraph extends StatelessWidget {
  final String text;

  const _Paragraph({required this.text});

  @override
  Widget build(BuildContext context) {
    final isBullet = text.startsWith('• ');
    return Padding(
      padding: EdgeInsets.only(bottom: 8, left: isBullet ? 8 : 0),
      child: Text(
        text,
        style: AppTextStyles.bodySecondary.copyWith(height: 1.4),
      ),
    );
  }
}

/// Muestra los Términos en una hoja inferior desplazable (para el registro).
void showTermsSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (context, scrollController) => ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        children: const [_TermsContentColumn()],
      ),
    ),
  );
}
