part of 'onboarding_bloc.dart';

sealed class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object> get props => [];
}

class GenderChanged extends OnboardingEvent {
  final String gender;
  const GenderChanged(this.gender);

  @override
  List<Object> get props => [gender];
}

class MainGoalChanged extends OnboardingEvent {
  final MainGoal goal;
  const MainGoalChanged(this.goal);

  @override
  List<Object> get props => [goal];
}

class ActivityLevelChanged extends OnboardingEvent {
  final ActivityLevel level;
  const ActivityLevelChanged(this.level);

  @override
  List<Object> get props => [level];
}

class WeeklyGoalChanged extends OnboardingEvent {
  final int days;
  const WeeklyGoalChanged(this.days);

  @override
  List<Object> get props => [days];
}

class WeightChanged extends OnboardingEvent {
  final double weight;
  const WeightChanged(this.weight);

  @override
  List<Object> get props => [weight];
}

class HeightChanged extends OnboardingEvent {
  final double height;
  const HeightChanged(this.height);

  @override
  List<Object> get props => [height];
}

class WeightUnitChanged extends OnboardingEvent {
  final bool isKg; // true = kg, false = lbs
  const WeightUnitChanged(this.isKg);

  @override
  List<Object> get props => [isKg];
}

class HeightUnitChanged extends OnboardingEvent {
  final bool isCm; // true = cm, false = ft
  const HeightUnitChanged(this.isCm);

  @override
  List<Object> get props => [isCm];
}

class SubmitOnboarding extends OnboardingEvent {
  const SubmitOnboarding();
}
