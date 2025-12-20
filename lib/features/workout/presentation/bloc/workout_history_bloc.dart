import 'package:equatable/equatable.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_session.dart';
import 'package:fitness_app/features/workout/domain/repositories/workout_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'workout_history_event.dart';
part 'workout_history_state.dart';

class WorkoutHistoryBloc
    extends Bloc<WorkoutHistoryEvent, WorkoutHistoryState> {
  final WorkoutRepository repository;

  WorkoutHistoryBloc({required this.repository})
    : super(WorkoutHistoryInitial()) {
    on<LoadWorkoutHistory>(_onLoadHistory);
    on<RefreshWorkoutHistory>(_onRefreshHistory);
  }

  Future<void> _onLoadHistory(
    LoadWorkoutHistory event,
    Emitter<WorkoutHistoryState> emit,
  ) async {
    emit(WorkoutHistoryLoading());
    try {
      final history = await repository.getWorkoutHistory(event.userId);
      final stats = _calculateStats(history);
      emit(WorkoutHistoryLoaded(sessions: history, stats: stats));
    } catch (e) {
      emit(WorkoutHistoryError(message: e.toString()));
    }
  }

  Future<void> _onRefreshHistory(
    RefreshWorkoutHistory event,
    Emitter<WorkoutHistoryState> emit,
  ) async {
    try {
      final history = await repository.getWorkoutHistory(event.userId);
      final stats = _calculateStats(history);
      emit(WorkoutHistoryLoaded(sessions: history, stats: stats));
    } catch (e) {
      emit(WorkoutHistoryError(message: e.toString()));
    }
  }

  WorkoutStats _calculateStats(List<WorkoutSession> sessions) {
    if (sessions.isEmpty) {
      return const WorkoutStats(
        totalWorkouts: 0,
        totalMinutes: 0,
        totalSets: 0,
        thisWeekWorkouts: 0,
        currentStreak: 0,
      );
    }

    int totalMinutes = 0;
    int totalSets = 0;
    int thisWeekWorkouts = 0;
    int currentStreak = 0;

    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(
      weekStart.year,
      weekStart.month,
      weekStart.day,
    );

    // Sort sessions by date (newest first)
    final sortedSessions = List<WorkoutSession>.from(sessions)
      ..sort((a, b) => b.startTime.compareTo(a.startTime));

    // Calculate totals
    for (final session in sortedSessions) {
      final duration = session.endTime != null
          ? session.endTime!.difference(session.startTime).inMinutes
          : 0;
      totalMinutes += duration;
      totalSets += session.completedSets.length;

      if (session.startTime.isAfter(weekStartDate)) {
        thisWeekWorkouts++;
      }
    }

    // Calculate streak
    if (sortedSessions.isNotEmpty) {
      DateTime? lastWorkoutDate;
      for (final session in sortedSessions) {
        final sessionDate = DateTime(
          session.startTime.year,
          session.startTime.month,
          session.startTime.day,
        );

        if (lastWorkoutDate == null) {
          final today = DateTime(now.year, now.month, now.day);
          final yesterday = today.subtract(const Duration(days: 1));
          if (sessionDate == today || sessionDate == yesterday) {
            currentStreak = 1;
            lastWorkoutDate = sessionDate;
          } else {
            break;
          }
        } else {
          final expectedDate = lastWorkoutDate.subtract(
            const Duration(days: 1),
          );
          if (sessionDate == expectedDate) {
            currentStreak++;
            lastWorkoutDate = sessionDate;
          } else {
            break;
          }
        }
      }
    }

    return WorkoutStats(
      totalWorkouts: sessions.length,
      totalMinutes: totalMinutes,
      totalSets: totalSets,
      thisWeekWorkouts: thisWeekWorkouts,
      currentStreak: currentStreak,
    );
  }
}

class WorkoutStats extends Equatable {
  final int totalWorkouts;
  final int totalMinutes;
  final int totalSets;
  final int thisWeekWorkouts;
  final int currentStreak;

  const WorkoutStats({
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.totalSets,
    required this.thisWeekWorkouts,
    required this.currentStreak,
  });

  @override
  List<Object?> get props => [
    totalWorkouts,
    totalMinutes,
    totalSets,
    thisWeekWorkouts,
    currentStreak,
  ];
}
