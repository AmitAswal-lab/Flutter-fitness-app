part of 'workout_bloc.dart';

abstract class WorkoutEvent extends Equatable {
  const WorkoutEvent();

  @override
  List<Object?> get props => [];
}

class LoadWorkouts extends WorkoutEvent {
  const LoadWorkouts();
}

class FilterByCategory extends WorkoutEvent {
  final ExerciseCategory? category;

  const FilterByCategory({this.category});

  @override
  List<Object?> get props => [category];
}
