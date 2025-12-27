part of 'active_home_workout_bloc.dart';

enum WorkoutPhase { preparation, exercise, rest, complete }

class ActiveHomeWorkoutState extends Equatable {
  final WorkoutTemplate? workout;
  final WorkoutPhase phase;
  final int currentExerciseIndex;
  final int timeRemaining; // Seconds remaining in current phase
  final bool isPaused;
  final DateTime? startTime;
  final int totalRestTaken; // Track total rest time for summary

  const ActiveHomeWorkoutState({
    this.workout,
    this.phase = WorkoutPhase.preparation,
    this.currentExerciseIndex = 0,
    this.timeRemaining = 15,
    this.isPaused = false,
    this.startTime,
    this.totalRestTaken = 0,
  });

  /// Current exercise being performed
  WorkoutExercise? get currentExercise {
    if (workout == null || currentExerciseIndex >= workout!.exercises.length) {
      return null;
    }
    return workout!.exercises[currentExerciseIndex];
  }

  /// Check if current exercise is time-based
  bool get isTimeBased =>
      currentExercise?.durationSeconds != null &&
      currentExercise!.durationSeconds > 0;

  /// Check if current exercise is rep-based
  bool get isRepBased =>
      currentExercise?.reps != null && currentExercise!.reps > 0;

  /// Progress through workout (0.0 to 1.0)
  double get progress {
    if (workout == null || workout!.exercises.isEmpty) return 0.0;
    return currentExerciseIndex / workout!.exercises.length;
  }

  /// Total exercises in workout
  int get totalExercises => workout?.exercises.length ?? 0;

  /// Check if this is the last exercise
  bool get isLastExercise => currentExerciseIndex >= totalExercises - 1;

  ActiveHomeWorkoutState copyWith({
    WorkoutTemplate? workout,
    WorkoutPhase? phase,
    int? currentExerciseIndex,
    int? timeRemaining,
    bool? isPaused,
    DateTime? startTime,
    int? totalRestTaken,
  }) {
    return ActiveHomeWorkoutState(
      workout: workout ?? this.workout,
      phase: phase ?? this.phase,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isPaused: isPaused ?? this.isPaused,
      startTime: startTime ?? this.startTime,
      totalRestTaken: totalRestTaken ?? this.totalRestTaken,
    );
  }

  @override
  List<Object?> get props => [
    workout,
    phase,
    currentExerciseIndex,
    timeRemaining,
    isPaused,
    startTime,
    totalRestTaken,
  ];
}
