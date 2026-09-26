import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class OnboardingDotIndicator extends StatelessWidget {
  final int currentIndex;
  final int length;

  const OnboardingDotIndicator({
    super.key,
    required this.currentIndex,
    required this.length,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        length,
        (index) => Container(
          width: index == currentIndex ? 8 : 6,
          height: index == currentIndex ? 8 : 6,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: index == currentIndex
                ? AppColors.primary
                : AppColors.inactiveDot,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}