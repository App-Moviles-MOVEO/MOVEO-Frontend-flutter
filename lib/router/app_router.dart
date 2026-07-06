import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheelspe_provider/core/network/dio_client.dart';
import 'package:wheelspe_provider/features/auth/presentation/forgot_password_screen.dart';
import 'package:wheelspe_provider/features/auth/presentation/kyc_screen.dart';
import 'package:wheelspe_provider/features/auth/presentation/login_screen.dart';
import 'package:wheelspe_provider/features/auth/presentation/onboarding_screen.dart';
import 'package:wheelspe_provider/features/auth/presentation/register_screen.dart';
import 'package:wheelspe_provider/features/auth/presentation/splash_screen.dart';
import 'package:wheelspe_provider/features/chat/presentation/chat_screen.dart';
import 'package:wheelspe_provider/features/chat/presentation/conversations_screen.dart';
import 'package:wheelspe_provider/features/notifications/presentation/notifications_screen.dart';
import 'package:wheelspe_provider/features/fleet/presentation/add_vehicle_screen.dart';
import 'package:wheelspe_provider/features/fleet/presentation/checklist_screen.dart';
import 'package:wheelspe_provider/features/fleet/presentation/edit_vehicle_screen.dart';
import 'package:wheelspe_provider/features/fleet/presentation/fleet_screen.dart';
import 'package:wheelspe_provider/features/fleet/presentation/reservation_detail_screen.dart';
import 'package:wheelspe_provider/features/fleet/presentation/reservations_screen.dart';
import 'package:wheelspe_provider/features/fleet/presentation/vehicle_detail_screen.dart';
import 'package:wheelspe_provider/features/home/presentation/home_screen.dart';
import 'package:wheelspe_provider/features/incidents/presentation/report_incident_screen.dart';
import 'package:wheelspe_provider/features/profile/presentation/badges_screen.dart';
import 'package:wheelspe_provider/features/profile/presentation/change_password_screen.dart';
import 'package:wheelspe_provider/features/profile/presentation/delete_account_screen.dart';
import 'package:wheelspe_provider/features/profile/presentation/edit_profile_screen.dart';
import 'package:wheelspe_provider/features/profile/presentation/kyc_status_screen.dart';
import 'package:wheelspe_provider/features/profile/presentation/payout_methods_screen.dart';
import 'package:wheelspe_provider/features/profile/presentation/profile_screen.dart';
import 'package:wheelspe_provider/features/profile/presentation/reputation_threshold_screen.dart';
import 'package:wheelspe_provider/features/promotions/presentation/apply_coupon_screen.dart';
import 'package:wheelspe_provider/features/promotions/presentation/promo_form_screen.dart';
import 'package:wheelspe_provider/features/promotions/presentation/promotions_screen.dart';
import 'package:wheelspe_provider/features/routes/presentation/add_route_screen.dart';
import 'package:wheelspe_provider/features/routes/presentation/passengers_screen.dart';
import 'package:wheelspe_provider/features/routes/presentation/route_detail_screen.dart';
import 'package:wheelspe_provider/features/routes/presentation/routes_screen.dart';
import 'package:wheelspe_provider/features/transactions/presentation/transaction_detail_screen.dart';
import 'package:wheelspe_provider/features/transactions/presentation/transactions_screen.dart';
import 'package:wheelspe_provider/router/main_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: session,
    redirect: (context, state) {
      // 401 definitivo: la sesión expiró → volver a login.
      final onAuthFlow = state.matchedLocation.startsWith('/auth') ||
          state.matchedLocation == '/blank' ||
          state.matchedLocation == '/splash' ||
          state.matchedLocation == '/onboarding';
      if (session.expired && !onAuthFlow) return '/auth/login';
      return null;
    },
    routes: [
      // Vista en blanco inicial (pantalla blanca vacía).
      GoRoute(
        path: '/blank',
        builder: (context, state) =>
            const Scaffold(backgroundColor: Colors.white),
      ),
      // Flujo inicial sin autenticación
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/auth/kyc',
        builder: (context, state) => const KycScreen(),
      ),

      // Shell principal con bottom navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/fleet',
                builder: (context, state) => const FleetScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/routes',
                builder: (context, state) => const RoutesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Pantallas secundarias (push sobre la nav, navigator raíz).
      // Las rutas literales van antes que las de parámetro (:id).
      GoRoute(
        path: '/fleet/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddVehicleScreen(),
      ),
      GoRoute(
        path: '/fleet/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            VehicleDetailScreen(vehicleId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'edit',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) =>
                EditVehicleScreen(vehicleId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'checklist',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => ChecklistScreen(
              vehicleId: state.pathParameters['id']!,
              tipo: state.uri.queryParameters['tipo'] ?? 'PRE',
              reservationId: state.uri.queryParameters['reservationId'],
            ),
          ),
          GoRoute(
            path: 'reservations',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => VehicleReservationsScreen(
              vehicleId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/reservations/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ReservationDetailScreen(
          reservationId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/routes/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddRouteScreen(),
      ),
      GoRoute(
        path: '/routes/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            RouteDetailScreen(routeId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            path: 'passengers',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) =>
                PassengersScreen(routeId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: '/transactions',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TransactionsScreen(),
        routes: [
          GoRoute(
            path: ':id',
            parentNavigatorKey: _rootNavigatorKey,
            builder: (context, state) => TransactionDetailScreen(
              transactionId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/incidents/report',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ReportIncidentScreen(
          reservationId: state.uri.queryParameters['reservationId'],
          routeId: state.uri.queryParameters['routeId'],
        ),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/chat',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ConversationsScreen(),
      ),
      GoRoute(
        path: '/chat/:otherUserId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ChatScreen(
          otherUserId: state.pathParameters['otherUserId']!,
          otherUserName: state.uri.queryParameters['name'] ?? 'Chat',
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/profile/kyc',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const KycStatusScreen(),
      ),
      GoRoute(
        path: '/profile/badges',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BadgesScreen(),
      ),
      GoRoute(
        path: '/profile/change-password',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/profile/payout-methods',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PayoutMethodsScreen(),
      ),
      GoRoute(
        path: '/profile/reputation-threshold',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ReputationThresholdScreen(),
      ),
      GoRoute(
        path: '/profile/delete-account',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DeleteAccountScreen(),
      ),
      // Promociones y cupones (US34/US27/US29). Literales antes de :id.
      GoRoute(
        path: '/promotions/new',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PromoFormScreen(),
      ),
      GoRoute(
        path: '/promotions/apply',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ApplyCouponScreen(),
      ),
      GoRoute(
        path: '/promotions',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PromotionsScreen(),
      ),
    ],
  );
});
