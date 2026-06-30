import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/services/notification_service.dart';
import 'package:wheelspe_provider/core/utils/date_formatter.dart';
import 'package:wheelspe_provider/features/fleet/presentation/fleet_providers.dart';
import 'package:wheelspe_provider/features/fleet/presentation/reservations_screen.dart';
import 'package:wheelspe_provider/features/home/presentation/dashboard_widgets/balance_card.dart';
import 'package:wheelspe_provider/features/notifications/presentation/notifications_providers.dart';
import 'package:wheelspe_provider/features/routes/data/route_model.dart';
import 'package:wheelspe_provider/features/routes/presentation/routes_providers.dart';
import 'package:wheelspe_provider/features/routes/presentation/routes_screen.dart';
import 'package:wheelspe_provider/features/transactions/presentation/transactions_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/providers/user_provider.dart';
import 'package:wheelspe_provider/shared/widgets/avatar_widget.dart';
import 'package:wheelspe_provider/shared/widgets/shimmer_card.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';

/// Dashboard del proveedor: saludo, KYC, resumen financiero,
/// reservas pendientes, rutas de hoy y accesos rápidos.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Timer? _pollTimer;
  Set<String> _knownPendingIds = {};
  bool _baselineLoaded = false;

  @override
  void initState() {
    super.initState();
    // Simula push: polling cada 30s buscando nuevas reservas PENDING.
    _pollTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      ref.invalidate(pendingReservationsProvider);
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final userAsync = ref.watch(currentUserProvider);
    final summaryAsync = ref.watch(walletSummaryProvider);
    final pendingAsync = ref.watch(pendingReservationsProvider);
    final routesAsync = ref.watch(myRoutesProvider);

    ref.listen(pendingReservationsProvider, (previous, next) {
      final reservations = next.value;
      if (reservations == null) return;
      final ids = reservations.map((r) => r.id).toSet();
      if (_baselineLoaded &&
          ids.difference(_knownPendingIds).isNotEmpty) {
        ref.read(notificationServiceProvider).showNewReservation(
              title: l10n.newReservationNotificationTitle,
              body: l10n.newReservationNotificationBody,
            );
      }
      _knownPendingIds = ids;
      _baselineLoaded = true;
    });

    return Scaffold(
      appBar: AppBar(
        title: userAsync.when(
          loading: () => Text(l10n.appName),
          error: (e, _) => Text(l10n.appName),
          data: (user) =>
              Text(l10n.homeGreeting(user.fullName.split(' ').first)),
        ),
        actions: [
          Semantics(
            label: 'Mensajes',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.forum_outlined),
              onPressed: () => context.push('/chat'),
            ),
          ),
          Consumer(
            builder: (context, ref, _) {
              final unread = ref.watch(unreadCountProvider).value ?? 0;
              return Semantics(
                label: 'Notificaciones',
                button: true,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_none),
                      onPressed: () => context.push('/notifications'),
                    ),
                    if (unread > 0)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            unread > 9 ? '9+' : '$unread',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: userAsync.value == null
                ? const SizedBox.shrink()
                : Semantics(
                    label: l10n.profileTitle,
                    button: true,
                    child: GestureDetector(
                      onTap: () => context.go('/profile'),
                      child: AvatarWidget(
                        imageUrl: userAsync.value!.avatarUrl,
                        name: userAsync.value!.fullName,
                        radius: 18,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(currentUserProvider);
          ref.invalidate(walletSummaryProvider);
          ref.invalidate(pendingReservationsProvider);
          ref.invalidate(myRoutesProvider);
        },
        child: ListView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.all(16),
          children: [
            // Badge de identidad verificada
            if (userAsync.value?.isVerified ?? false) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.verified_user,
                      size: 18,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.kycVerified,
                      style: AppTextStyles.bodySecondary.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Resumen financiero
            summaryAsync.when(
              loading: () => const ShimmerCard(height: 260),
              error: (e, _) => const SizedBox.shrink(),
              data: (summary) => BalanceCard(summary: summary),
            ),
            const SizedBox(height: 24),

            // Reservas pendientes
            Text(l10n.pendingReservations, style: AppTextStyles.title),
            const SizedBox(height: 12),
            pendingAsync.when(
              loading: () => const ShimmerCard(height: 170),
              error: (e, _) => const SizedBox.shrink(),
              data: (reservations) => reservations.isEmpty
                  ? WheelsPeCard(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.event_available_outlined,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.noReservations,
                              style: AppTextStyles.bodySecondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox(
                      height: 215,
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: reservations.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, i) => SizedBox(
                          width: 320,
                          child: ReservationCard(
                            reservation: reservations[i],
                            showActions: true,
                          ),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 24),

            // Rutas activas hoy
            Text(l10n.todayRoutes, style: AppTextStyles.title),
            const SizedBox(height: 12),
            routesAsync.when(
              loading: () => const ShimmerCard(height: 120),
              error: (e, _) => const SizedBox.shrink(),
              data: (routes) {
                final today = routes
                    .where(
                      (r) =>
                          DateFormatter.isToday(r.departureDateTime) &&
                          (r.status == RouteStatus.scheduled ||
                              r.status == RouteStatus.inProgress),
                    )
                    .toList();
                if (today.isEmpty) {
                  return WheelsPeCard(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.route_outlined,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.routesEmpty,
                            style: AppTextStyles.bodySecondary,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final route in today)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: RouteCard(route: route),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Accesos rápidos
            Text(l10n.quickActions, style: AppTextStyles.title),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.7,
              children: [
                _QuickAction(
                  icon: Icons.directions_car_outlined,
                  label: l10n.publishVehicle,
                  onTap: () => context.push('/fleet/add'),
                ),
                _QuickAction(
                  icon: Icons.add_road_outlined,
                  label: l10n.publishRoute,
                  onTap: () => context.push('/routes/add'),
                ),
                _QuickAction(
                  icon: Icons.account_balance_wallet_outlined,
                  label: l10n.viewEarnings,
                  onTap: () => context.push('/transactions'),
                ),
                _QuickAction(
                  icon: Icons.report_outlined,
                  label: l10n.reportIncident,
                  onTap: () => context.push('/incidents/report'),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return WheelsPeCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      semanticsLabel: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.accent, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: AppTextStyles.bodySecondary.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
