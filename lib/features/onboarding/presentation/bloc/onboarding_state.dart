part of 'onboarding_bloc.dart';

enum OnboardingStatus { initial, submitting, success, failure }

class OnboardingState extends Equatable {
  final String? gender;
  final MainGoal? mainGoal;
  final ActivityLevel? activityLevel;
  final int weeklyTrainingDays;

  final double weight;
  final double height;

  final bool isKg; // Unit selection
  final bool isCm; // Unit selection

  final OnboardingStatus status;
  final String? errorMessage;

  const OnboardingState({
    this.gender,
    this.mainGoal,
    this.activityLevel,
    this.weeklyTrainingDays = 3,
    this.weight = 70.0, // Default 70kg / ~154lbs
    this.height = 170.0, // Default 170cm / ~5'7"
    this.isKg = true,
    this.isCm = true,
    this.status = OnboardingStatus.initial,
    this.errorMessage,
  });

  OnboardingState copyWith({
    String? gender,
    MainGoal? mainGoal,
    ActivityLevel? activityLevel,
    int? weeklyTrainingDays,
    double? weight,
    double? height,
    bool? isKg,
    bool? isCm,
    OnboardingStatus? status,
    String? errorMessage,
  }) {
    return OnboardingState(
      gender: gender ?? this.gender,
      mainGoal: mainGoal ?? this.mainGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      weeklyTrainingDays: weeklyTrainingDays ?? this.weeklyTrainingDays,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      isKg: isKg ?? this.isKg,
      isCm: isCm ?? this.isCm,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    gender,
    mainGoal,
    activityLevel,
    weeklyTrainingDays,
    weight,
    height,
    isKg,
    isCm,
    status,
    errorMessage,
  ];
}
