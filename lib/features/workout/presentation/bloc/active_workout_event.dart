part of 'active_workout_bloc.dart';

abstract class ActiveWorkoutEvent extends Equatable {
  const ActiveWorkoutEvent();

  @override
  List<Object?> get props => [];
}

class StartWorkout extends ActiveWorkoutEvent {
  final WorkoutTemplate template;
  final String userId;

  const StartWorkout({required this.template, required this.userId});

  @override
  List<Object?> get props => [template, userId];
}

class NextExercise extends ActiveWorkoutEvent {
  const NextExercise();
}

class PreviousExercise extends ActiveWorkoutEvent {
  const PreviousExercise();
}

class StartSet extends ActiveWorkoutEvent {
  const StartSet();
}

class AdjustRestTime extends ActiveWorkoutEvent {
  final int deltaSeconds; // positive to add, negative to subtract

  const AdjustRestTime({required this.deltaSeconds});

  @override
  List<Object?> get props => [deltaSeconds];
}

class CompleteSet extends ActiveWorkoutEvent {
  final double? weight;
  final int? reps;
  final int? durationSeconds;

  const CompleteSet({this.weight, this.reps, this.durationSeconds});

  @override
  List<Object?> get props => [weight, reps, durationSeconds];
}

class StartRest extends ActiveWorkoutEvent {
  final int seconds;

  const StartRest({required this.seconds});

  @override
  List<Object?> get props => [seconds];
}

class SkipRest extends ActiveWorkoutEvent {
  const SkipRest();
}

class TimerTick extends ActiveWorkoutEvent {
  const TimerTick();
}

class PauseWorkout extends ActiveWorkoutEvent {
  const PauseWorkout();
}

class ResumeWorkout extends ActiveWorkoutEvent {
  const ResumeWorkout();
}

class FinishWorkout extends ActiveWorkoutEvent {
  const FinishWorkout();
}

class AbandonWorkout extends ActiveWorkoutEvent {
  const AbandonWorkout();
}
