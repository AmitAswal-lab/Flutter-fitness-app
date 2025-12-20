part of 'workout_bloc.dart';

abstract class WorkoutState extends Equatable {
  const WorkoutState();

  @override
  List<Object?> get props => [];
}

class WorkoutInitial extends WorkoutState {}

class WorkoutLoading extends WorkoutState {}

class WorkoutLoaded extends WorkoutState {
  final List<WorkoutTemplate> workouts;
  final ExerciseCategory? selectedCategory;

  const WorkoutLoaded({required this.workouts, this.selectedCategory});

  @override
  List<Object?> get props => [workouts, selectedCategory];
}

class WorkoutError extends WorkoutState {
  final String message;

  const WorkoutError({required this.message});

  @override
  List<Object?> get props => [message];
}
