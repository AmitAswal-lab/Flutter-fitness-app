part of 'active_workout_bloc.dart';

abstract class ActiveWorkoutState extends Equatable {
  const ActiveWorkoutState();

  @override
  List<Object?> get props => [];
}

class ActiveWorkoutInitial extends ActiveWorkoutState {}

class ActiveWorkoutInProgress extends ActiveWorkoutState {
  final WorkoutTemplate template;
  final String userId;
  final int currentExerciseIndex;
  final int currentSetIndex;
  final List<CompletedSet> completedSets;
  final int elapsedSeconds;
  final bool isResting;
  final int restSecondsRemaining;
  final bool isPaused;
  final bool pendingNextExercise;

  const ActiveWorkoutInProgress({
    required this.template,
    required this.userId,
    required this.currentExerciseIndex,
    required this.currentSetIndex,
    required this.completedSets,
    required this.elapsedSeconds,
    required this.isResting,
    required this.restSecondsRemaining,
    required this.isPaused,
    this.pendingNextExercise = false,
  });

  WorkoutExercise get currentExercise =>
      template.exercises[currentExerciseIndex];

  int get totalExercises => template.exercises.length;

  String get formattedTime {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedRestTime {
    final minutes = restSecondsRemaining ~/ 60;
    final seconds = restSecondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  ActiveWorkoutInProgress copyWith({
    int? currentExerciseIndex,
    int? currentSetIndex,
    List<CompletedSet>? completedSets,
    int? elapsedSeconds,
    bool? isResting,
    int? restSecondsRemaining,
    bool? isPaused,
    bool? pendingNextExercise,
  }) {
    return ActiveWorkoutInProgress(
      template: template,
      userId: userId,
      currentExerciseIndex: currentExerciseIndex ?? this.currentExerciseIndex,
      currentSetIndex: currentSetIndex ?? this.currentSetIndex,
      completedSets: completedSets ?? this.completedSets,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isResting: isResting ?? this.isResting,
      restSecondsRemaining: restSecondsRemaining ?? this.restSecondsRemaining,
      isPaused: isPaused ?? this.isPaused,
      pendingNextExercise: pendingNextExercise ?? this.pendingNextExercise,
    );
  }

  @override
  List<Object?> get props => [
    currentExerciseIndex,
    currentSetIndex,
    completedSets,
    elapsedSeconds,
    isResting,
    restSecondsRemaining,
    isPaused,
    pendingNextExercise,
  ];
}

class ActiveWorkoutCompleted extends ActiveWorkoutState {
  final WorkoutTemplate template;
  final String userId;
  final List<CompletedSet> completedSets;
  final int totalSeconds;

  const ActiveWorkoutCompleted({
    required this.template,
    required this.userId,
    required this.completedSets,
    required this.totalSeconds,
  });

  String get formattedTime {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [template, userId, completedSets, totalSeconds];
}
