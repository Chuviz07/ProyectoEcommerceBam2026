import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'onboarding_dot_indicator.dart';

// Pantalla inicial con carrusel, contenido y boton next.
class OnboardingIntroPage extends StatefulWidget {
  final VoidCallback onNext;

  const OnboardingIntroPage({
    super.key,
    required this.onNext,
  });

  @override
  State<OnboardingIntroPage> createState() => _OnboardingIntroPageState();
}

class _OnboardingIntroPageState extends State<OnboardingIntroPage> {
  final PageController _pageController = PageController();

  int _currentIndex = 0;

  final List<String> _images = [
    'assets/images/onboarding_1.jpg',
    'assets/images/onboarding_2.jpg',
    'assets/images/onboarding_3.jpeg',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: Container(
            width: double.infinity,
            color: AppColors.lightBlue,
            child: PageView.builder(
              controller: _pageController,
              itemCount: _images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Image.asset(
                    _images[index],
                    fit: BoxFit.contain,
                  ),
                );
              },
            ),
          ),
        ),

        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OnboardingDotIndicator(
                  currentIndex: _currentIndex,
                  length: _images.length,
                ),

                const SizedBox(height: 28),

                const Text(
                  'Create a prototype in just\na few minutes',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Enjoy these pre-made components and worry only\nabout creating the best product ever.',
                  style: TextStyle(
                    color: AppColors.textGray,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: widget.onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                    child: const Text(
                      'Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}