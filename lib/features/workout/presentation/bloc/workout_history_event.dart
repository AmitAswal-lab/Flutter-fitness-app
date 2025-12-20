part of 'workout_history_bloc.dart';

abstract class WorkoutHistoryEvent extends Equatable {
  const WorkoutHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadWorkoutHistory extends WorkoutHistoryEvent {
  final String userId;

  const LoadWorkoutHistory({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class RefreshWorkoutHistory extends WorkoutHistoryEvent {
  final String userId;

  const RefreshWorkoutHistory({required this.userId});

  @override
  List<Object?> get props => [userId];
}
