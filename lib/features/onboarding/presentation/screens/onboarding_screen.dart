import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_intro_page.dart';
import '../widgets/onboarding_interests_page.dart';

// import 'package:flutter_ejercicio1/features/ecommerce/presentation/screens/ecommerce_home_screen.dart';
import 'package:flutter_ejercicio1/features/auth/presentation/screens/login_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  static const name = 'onboarding-screen';

  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  void _nextPage() {
    final currentPage = ref.read(onboardingPageProvider);

    // Si estamos en la última página del onboarding,
    // navegamos hacia la pantalla principal de ecommerce.
    if (currentPage == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // builder: (_) => const EcommerceHomeScreen(),
          builder: (_) => const LoginScreen(),
        ),
      );
      return;
    }

    // Si todavía no estamos en la última página,
    // avanzamos a la siguiente página del PageView.
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(onboardingPageProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            ref.read(onboardingPageProvider.notifier).state = index;
          },
          children: [
            OnboardingIntroPage(
              onNext: _nextPage,
            ),
            OnboardingInterestsPage(
              onNext: _nextPage,
            ),
          ],
        ),
      ),
    );
  }
}