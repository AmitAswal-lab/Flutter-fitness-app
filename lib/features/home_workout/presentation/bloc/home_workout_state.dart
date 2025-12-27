part of 'home_workout_bloc.dart';

enum HomeWorkoutStatus { initial, loading, loaded, failure, saving, saved }

class HomeWorkoutState extends Equatable {
  final HomeWorkoutStatus status;
  final WorkoutTemplate? workout;
  final String? errorMessage;
  final bool hasUnsavedChanges;

  const HomeWorkoutState({
    this.status = HomeWorkoutStatus.initial,
    this.workout,
    this.errorMessage,
    this.hasUnsavedChanges = false,
  });

  HomeWorkoutState copyWith({
    HomeWorkoutStatus? status,
    WorkoutTemplate? workout,
    String? errorMessage,
    bool? hasUnsavedChanges,
  }) {
    return HomeWorkoutState(
      status: status ?? this.status,
      workout: workout ?? this.workout,
      errorMessage: errorMessage ?? this.errorMessage,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }

  @override
  List<Object?> get props => [status, workout, errorMessage, hasUnsavedChanges];
}
