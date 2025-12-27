part of 'active_home_workout_bloc.dart';

abstract class ActiveHomeWorkoutEvent extends Equatable {
  const ActiveHomeWorkoutEvent();

  @override
  List<Object?> get props => [];
}

/// Start the workout session with preparation phase
class StartWorkout extends ActiveHomeWorkoutEvent {
  final WorkoutTemplate workout;

  const StartWorkout(this.workout);

  @override
  List<Object?> get props => [workout];
}

/// Internal timer tick event
class TimerTick extends ActiveHomeWorkoutEvent {
  const TimerTick();
}

/// User completes a rep-based exercise
class CompleteExercise extends ActiveHomeWorkoutEvent {
  const CompleteExercise();
}

/// Add time to rest period (+15s)
class AddRestTime extends ActiveHomeWorkoutEvent {
  final int seconds;

  const AddRestTime({this.seconds = 15});

  @override
  List<Object?> get props => [seconds];
}

/// Skip remaining rest time
class SkipRest extends ActiveHomeWorkoutEvent {
  const SkipRest();
}

/// Pause the workout
class PauseWorkout extends ActiveHomeWorkoutEvent {
  const PauseWorkout();
}

/// Resume the workout
class ResumeWorkout extends ActiveHomeWorkoutEvent {
  const ResumeWorkout();
}

/// Skip preparation phase
class SkipPreparation extends ActiveHomeWorkoutEvent {
  const SkipPreparation();
}

/// Go to previous exercise
class PreviousExercise extends ActiveHomeWorkoutEvent {
  const PreviousExercise();
}
