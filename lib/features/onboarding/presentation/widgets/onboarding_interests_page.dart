import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/onboarding_provider.dart';
import 'interest_option_tile.dart';

class OnboardingInterestsPage extends ConsumerWidget {
  final VoidCallback onNext;

  const OnboardingInterestsPage({
    super.key,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interests = ref.watch(onboardingInterestsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 36, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: 0.5,
              minHeight: 6,
              backgroundColor: const Color(0xFFE6E8EF),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 36),

          const Text(
            'Personalise your\nexperience',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 25,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            'Choose your interests.',
            style: TextStyle(
              color: AppColors.textGray,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 32),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: interests.length,
              itemBuilder: (context, index) {
                final item = interests[index];

                return InterestOptionTile(
                  title: item.title,
                  selected: item.selected,
                  onTap: () {
                    ref
                        .read(onboardingInterestsProvider.notifier)
                        .toggleInterest(index);
                  },
                );
              },
            ),
          ),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onNext,
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
    );
  }
}