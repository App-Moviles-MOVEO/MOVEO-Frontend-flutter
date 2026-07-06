import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/storage/local_storage.dart';
import 'package:wheelspe_provider/features/routes/presentation/routes_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';

/// US30: umbral de reputación mínima para pasajeros de carpooling.
/// Se guarda localmente y se aplica al aceptar solicitudes.
class ReputationThresholdScreen extends ConsumerStatefulWidget {
  const ReputationThresholdScreen({super.key});

  @override
  ConsumerState<ReputationThresholdScreen> createState() =>
      _ReputationThresholdScreenState();
}

class _ReputationThresholdScreenState
    extends ConsumerState<ReputationThresholdScreen> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = ref.read(localStorageProvider).reputationThreshold;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    await ref.read(localStorageProvider).setReputationThreshold(_value);
    ref.invalidate(reputationThresholdProvider);
    if (mounted) showSuccessSnackBar(context, l10n.reputationThresholdSaved);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.reputationThreshold)),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.reputationThresholdSubtitle,
                style: AppTextStyles.bodySecondary),
            const SizedBox(height: 24),
            WheelsPeCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.warning),
                      const SizedBox(width: 8),
                      Text(
                        _value == 0
                            ? l10n.reputationThresholdOff
                            : l10n.reputationThresholdValue(
                                _value.toStringAsFixed(1)),
                        style: AppTextStyles.body,
                      ),
                    ],
                  ),
                  Slider(
                    value: _value,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    label: _value.toStringAsFixed(1),
                    onChanged: (v) => setState(() => _value = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            WheelsPeButton(label: l10n.save, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
