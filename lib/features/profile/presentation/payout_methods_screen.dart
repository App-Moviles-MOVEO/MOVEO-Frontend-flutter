import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/storage/local_storage.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/empty_state.dart';
import 'package:wheelspe_provider/shared/widgets/snackbars.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';

/// US21: métodos de cobro guardados (Yape/Plin/banco) para reutilizar al
/// solicitar retiros. Persistidos localmente (el backend aún no los guarda).
class PayoutMethodsScreen extends ConsumerStatefulWidget {
  const PayoutMethodsScreen({super.key});

  @override
  ConsumerState<PayoutMethodsScreen> createState() =>
      _PayoutMethodsScreenState();
}

class _PayoutMethodsScreenState extends ConsumerState<PayoutMethodsScreen> {
  late List<Map<String, String>> _methods;

  @override
  void initState() {
    super.initState();
    _methods = ref.read(localStorageProvider).loadPayoutMethods();
  }

  Future<void> _persist() =>
      ref.read(localStorageProvider).savePayoutMethods(_methods);

  Future<void> _add() async {
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddPayoutSheet(),
    );
    if (result == null) return;
    setState(() => _methods = [..._methods, result]);
    await _persist();
    if (mounted) {
      showSuccessSnackBar(
        context,
        AppLocalizations.of(context).payoutMethodSaved,
      );
    }
  }

  Future<void> _remove(int index) async {
    setState(() => _methods = [..._methods]..removeAt(index));
    await _persist();
  }

  String _methodLabel(AppLocalizations l10n, String method) => switch (method) {
        'yape' => l10n.yape,
        'plin' => l10n.plin,
        _ => l10n.card,
      };

  IconData _methodIcon(String method) => switch (method) {
        'yape' => Icons.qr_code_2,
        'plin' => Icons.bolt_outlined,
        _ => Icons.account_balance_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.payoutMethods)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: Text(l10n.addPayoutMethod),
      ),
      body: _methods.isEmpty
          ? EmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: l10n.payoutMethods,
              message: l10n.noPayoutMethods,
            )
          : ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(l10n.payoutMethodsSubtitle,
                    style: AppTextStyles.bodySecondary),
                const SizedBox(height: 12),
                for (final (i, m) in _methods.indexed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: WheelsPeCard(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Icon(_methodIcon(m['method'] ?? ''),
                              color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(m['alias'] ?? '', style: AppTextStyles.body),
                                Text(
                                  '${_methodLabel(l10n, m['method'] ?? '')} · '
                                  '${m['destination'] ?? ''}',
                                  style: AppTextStyles.caption,
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.error),
                            onPressed: () => _remove(i),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class _AddPayoutSheet extends StatefulWidget {
  const _AddPayoutSheet();

  @override
  State<_AddPayoutSheet> createState() => _AddPayoutSheetState();
}

class _AddPayoutSheetState extends State<_AddPayoutSheet> {
  final _formKey = GlobalKey<FormState>();
  final _aliasController = TextEditingController();
  final _destinationController = TextEditingController();
  String _method = 'yape';

  @override
  void dispose() {
    _aliasController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, {
      'alias': _aliasController.text.trim(),
      'method': _method,
      'destination': _destinationController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.addPayoutMethod, style: AppTextStyles.title),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _aliasController,
                  decoration: InputDecoration(labelText: l10n.payoutAlias),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? l10n.requiredField : null,
                ),
                const SizedBox(height: 12),
                Text(l10n.withdrawMethod, style: AppTextStyles.subtitle),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'yape', label: Text(l10n.yape)),
                    ButtonSegment(value: 'plin', label: Text(l10n.plin)),
                    ButtonSegment(value: 'bank', label: Text(l10n.card)),
                  ],
                  selected: {_method},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) => setState(() => _method = s.first),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _destinationController,
                  decoration:
                      InputDecoration(labelText: l10n.withdrawDestination),
                  validator: (v) =>
                      (v ?? '').trim().isEmpty ? l10n.requiredField : null,
                ),
                const SizedBox(height: 20),
                WheelsPeButton(label: l10n.save, onPressed: _save),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
