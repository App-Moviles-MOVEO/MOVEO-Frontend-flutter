import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/utils/currency_formatter.dart';
import 'package:wheelspe_provider/core/utils/date_formatter.dart';
import 'package:wheelspe_provider/features/routes/data/route_model.dart';
import 'package:wheelspe_provider/features/routes/presentation/routes_providers.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/empty_state.dart';
import 'package:wheelspe_provider/shared/widgets/error_state.dart';
import 'package:wheelspe_provider/shared/widgets/shimmer_card.dart';
import 'package:wheelspe_provider/shared/widgets/status_badge.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_card.dart';

class RoutesScreen extends ConsumerWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final routesAsync = ref.watch(myRoutesProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.routesTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.tabUpcoming),
              Tab(text: l10n.tabInProgress),
              Tab(text: l10n.tabHistory),
            ],
          ),
        ),
        floatingActionButton: Semantics(
          label: l10n.publishRoute,
          button: true,
          child: FloatingActionButton(
            onPressed: () => context.push('/routes/add'),
            child: const Icon(Icons.add),
          ),
        ),
        body: routesAsync.when(
          loading: () => const ShimmerList(),
          error: (e, _) => ErrorState(
            onRetry: () => ref.invalidate(myRoutesProvider),
          ),
          data: (routes) {
            final upcoming = routes
                .where((r) => r.status == RouteStatus.scheduled)
                .toList();
            final inProgress = routes
                .where((r) => r.status == RouteStatus.inProgress)
                .toList();
            final history = routes
                .where((r) =>
                    r.status == RouteStatus.completed ||
                    r.status == RouteStatus.cancelled)
                .toList();
            return TabBarView(
              children: [
                _RouteList(routes: upcoming),
                _RouteList(routes: inProgress),
                _RouteList(routes: history),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _RouteList extends ConsumerWidget {
  final List<RouteModel> routes;

  const _RouteList({required this.routes});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    if (routes.isEmpty) {
      return EmptyState(
        icon: Icons.route_outlined,
        title: l10n.routesEmpty,
        message: l10n.routesEmptyBody,
      );
    }
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myRoutesProvider),
      child: ListView.separated(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.all(16),
        itemCount: routes.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) => RouteCard(route: routes[i]),
      ),
    );
  }
}

/// Card de ruta reutilizable (también la usa el dashboard).
class RouteCard extends StatelessWidget {
  final RouteModel route;

  const RouteCard({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final statusLabel = switch (route.status) {
      RouteStatus.scheduled => l10n.statusScheduled,
      RouteStatus.inProgress => l10n.statusInProgress,
      RouteStatus.completed => l10n.statusCompleted,
      RouteStatus.cancelled => l10n.statusCancelled,
    };
    final occupancy = route.availableSeats == 0
        ? 0.0
        : route.confirmedSeats / route.availableSeats;

    return WheelsPeCard(
      glow: route.status == RouteStatus.inProgress,
      onTap: () => context.push('/routes/${route.id}'),
      semanticsLabel:
          '${route.origin} a ${route.destination}, $statusLabel',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        route.origin,
                        style: AppTextStyles.body,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: AppColors.accent,
                      ),
                    ),
                    Flexible(
                      child: Text(
                        route.destination,
                        style: AppTextStyles.body,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge.fromStatus(route.status.apiValue, statusLabel),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.schedule,
                size: 15,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                DateFormatter.fullDateTime(route.departureDateTime, locale),
                style: AppTextStyles.bodySecondary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.seatsOccupied(
                        route.confirmedSeats,
                        route.availableSeats,
                      ),
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: occupancy,
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                CurrencyFormatter.format(route.pricePerSeat),
                style: AppTextStyles.title,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
