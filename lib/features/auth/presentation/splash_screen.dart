import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/features/auth/data/auth_models.dart';
import 'package:wheelspe_provider/features/auth/presentation/auth_providers.dart';

/// Splash con fade-in del logo. Decide la ruta inicial según
/// token en secure storage y estado del KYC.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void initState() {
    super.initState();
    _decideNextRoute();
  }

  Future<void> _decideNextRoute() async {
    // Deja respirar a la animación del logo.
    final wait = Future<void>.delayed(const Duration(milliseconds: 1400));

    final repository = ref.read(authRepositoryProvider);
    final token = await repository.getStoredToken();

    String next;
    if (token == null || token.isEmpty) {
      next = '/onboarding';
    } else {
      try {
        final kyc = await repository.getKycStatus();
        next = kyc.status == KycStatus.verified ? '/home' : '/auth/kyc';
      } catch (_) {
        // Token inválido o backend caído: vuelve al login.
        next = '/auth/login';
      }
    }

    await wait;
    if (mounted) context.go(next);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _controller,
            curve: Curves.easeIn,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.accent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: AppColors.primaryGlow,
                ),
                child: const Icon(
                  Icons.directions_car_filled,
                  size: 52,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'WheelsPe',
                style: AppTextStyles.displayMedium.copyWith(fontSize: 34),
              ),
              const SizedBox(height: 6),
              const Text('Proveedor', style: AppTextStyles.subtitle),
            ],
          ),
        ),
      ),
    );
  }
}
