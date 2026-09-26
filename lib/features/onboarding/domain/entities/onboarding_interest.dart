class OnboardingInterest {
  final String title;
  final bool selected;

  const OnboardingInterest({
    required this.title,
    this.selected = false,
  });

  OnboardingInterest copyWith({
    String? title,
    bool? selected,
  }) {
    return OnboardingInterest(
      title: title ?? this.title,
      selected: selected ?? this.selected,
    );
  }
}