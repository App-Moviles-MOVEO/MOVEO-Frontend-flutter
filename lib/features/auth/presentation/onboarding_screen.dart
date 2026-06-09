import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wheelspe_provider/core/constants/app_colors.dart';
import 'package:wheelspe_provider/core/constants/app_text_styles.dart';
import 'package:wheelspe_provider/core/storage/local_storage.dart';
import 'package:wheelspe_provider/l10n/generated/app_localizations.dart';
import 'package:wheelspe_provider/shared/widgets/wheelspe_button.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(localStorageProvider).setOnboardingSeen();
    if (mounted) context.go('/auth/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final slides = [
      (Icons.attach_money, l10n.onboardingTitle1, l10n.onboardingBody1),
      (Icons.verified_user_outlined, l10n.onboardingTitle2, l10n.onboardingBody2),
      (Icons.account_balance_wallet_outlined, l10n.onboardingTitle3,
          l10n.onboardingBody3),
    ];
    final isLast = _page == slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Semantics(
                  label: l10n.onboardingSkip,
                  button: true,
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(l10n.onboardingSkip),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) {
                  final (icon, title, body) = slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primary.withValues(alpha: 0.25),
                                AppColors.accent.withValues(alpha: 0.1),
                              ],
                            ),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child:
                              Icon(icon, size: 84, color: AppColors.accent),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          title,
                          style: AppTextStyles.displayMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          body,
                          style: AppTextStyles.bodySecondary,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.divider,
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: active ? AppColors.primaryGlow : null,
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: isLast
                  ? WheelsPeButton(
                      label: l10n.onboardingStart,
                      onPressed: _finish,
                    )
                  : WheelsPeButton(
                      label: l10n.next,
                      onPressed: () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
