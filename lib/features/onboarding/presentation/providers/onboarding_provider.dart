import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/onboarding_interest.dart';

final onboardingPageProvider = StateProvider<int>((ref) => 0);

final onboardingInterestsProvider =
    StateNotifierProvider<OnboardingInterestsNotifier, List<OnboardingInterest>>(
  (ref) => OnboardingInterestsNotifier(),
);

class OnboardingInterestsNotifier extends StateNotifier<List<OnboardingInterest>> {
  OnboardingInterestsNotifier()
      : super(const [
          OnboardingInterest(title: 'User Interface', selected: true),
          OnboardingInterest(title: 'User Experience'),
          OnboardingInterest(title: 'User Research', selected: true),
          OnboardingInterest(title: 'UX Writing'),
          OnboardingInterest(title: 'User Testing'),
          OnboardingInterest(title: 'Service Design'),
          OnboardingInterest(title: 'Strategy', selected: true),
          OnboardingInterest(title: 'Design Systems', selected: true),
        ]);

  void toggleInterest(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          state[i].copyWith(selected: !state[i].selected)
        else
          state[i],
    ];
  }
}