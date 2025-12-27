part of 'home_workout_bloc.dart';

abstract class HomeWorkoutEvent extends Equatable {
  const HomeWorkoutEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeWorkout extends HomeWorkoutEvent {}

class ReorderExercises extends HomeWorkoutEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderExercises(this.oldIndex, this.newIndex);

  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class UpdateExerciseReps extends HomeWorkoutEvent {
  final int exerciseIndex;
  final int newReps;

  const UpdateExerciseReps(this.exerciseIndex, this.newReps);

  @override
  List<Object?> get props => [exerciseIndex, newReps];
}

class UpdateExerciseDuration extends HomeWorkoutEvent {
  final int exerciseIndex;
  final int newDurationSeconds;

  const UpdateExerciseDuration(this.exerciseIndex, this.newDurationSeconds);

  @override
  List<Object?> get props => [exerciseIndex, newDurationSeconds];
}

class SaveHomeWorkout extends HomeWorkoutEvent {}
