import 'package:equatable/equatable.dart';
import 'package:fitness_app/features/profile/domain/entities/user_profile.dart';
import 'package:fitness_app/features/profile/domain/usecases/save_profile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final SaveProfile saveProfile;
  final String userId; // We need current user ID to save profile

  OnboardingBloc({required this.saveProfile, required this.userId})
    : super(const OnboardingState()) {
    on<GenderChanged>(_onGenderChanged);
    on<MainGoalChanged>(_onMainGoalChanged);
    on<ActivityLevelChanged>(_onActivityLevelChanged);
    on<WeeklyGoalChanged>(_onWeeklyGoalChanged);
    on<WeightChanged>(_onWeightChanged);
    on<HeightChanged>(_onHeightChanged);
    on<WeightUnitChanged>(_onWeightUnitChanged);
    on<HeightUnitChanged>(_onHeightUnitChanged);
    on<SubmitOnboarding>(_onSubmitOnboarding);
  }

  void _onGenderChanged(GenderChanged event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(gender: event.gender));
  }

  void _onMainGoalChanged(
    MainGoalChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(mainGoal: event.goal));
  }

  void _onActivityLevelChanged(
    ActivityLevelChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(activityLevel: event.level));
  }

  void _onWeeklyGoalChanged(
    WeeklyGoalChanged event,
    Emitter<OnboardingState> emit,
  ) {
    emit(state.copyWith(weeklyTrainingDays: event.days));
  }

  void _onWeightChanged(WeightChanged event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(weight: event.weight));
  }

  void _onHeightChanged(HeightChanged event, Emitter<OnboardingState> emit) {
    emit(state.copyWith(height: event.height));
  }

  void _onWeightUnitChanged(
    WeightUnitChanged event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.isKg == event.isKg) return;

    // Convert existing value
    double newWeight;
    if (event.isKg) {
      // lbs -> kg
      newWeight = state.weight * 0.453592;
    } else {
      // kg -> lbs
      newWeight = state.weight * 2.20462;
    }

    emit(state.copyWith(isKg: event.isKg, weight: newWeight));
  }

  void _onHeightUnitChanged(
    HeightUnitChanged event,
    Emitter<OnboardingState> emit,
  ) {
    if (state.isCm == event.isCm) return;

    // Convert existing value
    double newHeight;
    if (event.isCm) {
      // ft -> cm (input might be decimal feet for simplicity in state, though UI might show ft/in)
      newHeight = state.height * 30.48;
    } else {
      // cm -> ft
      newHeight = state.height / 30.48;
    }

    emit(state.copyWith(isCm: event.isCm, height: newHeight));
  }

  Future<void> _onSubmitOnboarding(
    SubmitOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(status: OnboardingStatus.submitting));

    try {
      // Normalize to metric for storage
      final double weightKg = state.isKg
          ? state.weight
          : state.weight * 0.453592;
      final double heightCm = state.isCm ? state.height : state.height * 30.48;

      final profile = UserProfile(
        userId: userId,
        gender: state.gender,
        mainGoal: state.mainGoal,
        activityLevel: state.activityLevel,
        weeklyTrainingDays: state.weeklyTrainingDays,
        weightKg: weightKg,
        heightCm: heightCm,
        // Default others
        stepGoal: 10000,
        fitnessLevel: FitnessLevel.beginner, // Could derive from activity level
      );

      final result = await saveProfile(profile);

      result.fold(
        (failure) => emit(
          state.copyWith(
            status: OnboardingStatus.failure,
            errorMessage: failure.message,
          ),
        ),
        (_) => emit(state.copyWith(status: OnboardingStatus.success)),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: OnboardingStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
