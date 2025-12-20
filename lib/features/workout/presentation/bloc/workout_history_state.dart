part of 'workout_history_bloc.dart';

abstract class WorkoutHistoryState extends Equatable {
  const WorkoutHistoryState();

  @override
  List<Object?> get props => [];
}

class WorkoutHistoryInitial extends WorkoutHistoryState {}

class WorkoutHistoryLoading extends WorkoutHistoryState {}

class WorkoutHistoryLoaded extends WorkoutHistoryState {
  final List<WorkoutSession> sessions;
  final WorkoutStats stats;

  const WorkoutHistoryLoaded({required this.sessions, required this.stats});

  @override
  List<Object?> get props => [sessions, stats];
}

class WorkoutHistoryError extends WorkoutHistoryState {
  final String message;

  const WorkoutHistoryError({required this.message});

  @override
  List<Object?> get props => [message];
}
