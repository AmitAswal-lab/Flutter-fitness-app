import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fitness_app/core/services/audio_service.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_template.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'active_home_workout_event.dart';
part 'active_home_workout_state.dart';

class ActiveHomeWorkoutBloc
    extends Bloc<ActiveHomeWorkoutEvent, ActiveHomeWorkoutState> {
  Timer? _timer;
  final AudioService _audioService = AudioService();

  static const int preparationTime = 15;
  static const int defaultRestTime = 20;

  ActiveHomeWorkoutBloc() : super(const ActiveHomeWorkoutState()) {
    on<StartWorkout>(_onStartWorkout);
    on<TimerTick>(_onTimerTick);
    on<CompleteExercise>(_onCompleteExercise);
    on<AddRestTime>(_onAddRestTime);
    on<SkipRest>(_onSkipRest);
    on<PauseWorkout>(_onPauseWorkout);
    on<ResumeWorkout>(_onResumeWorkout);
    on<SkipPreparation>(_onSkipPreparation);
    on<PreviousExercise>(_onPreviousExercise);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const TimerTick());
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _onStartWorkout(
    StartWorkout event,
    Emitter<ActiveHomeWorkoutState> emit,
  ) {
    emit(
      ActiveHomeWorkoutState(
        workout: event.workout,
        phase: WorkoutPhase.preparation,
        currentExerciseIndex: 0,
        timeRemaining: preparationTime,
        startTime: DateTime.now(),
      ),
    );

    // Announce workout name during prep (not exercise name)
    _audioService.speakPreparation(event.workout.name);

    _startTimer();
  }

  void _onTimerTick(TimerTick event, Emitter<ActiveHomeWorkoutState> emit) {
    if (state.isPaused) return;

    final newTime = state.timeRemaining - 1;

    if (newTime <= 0) {
      _handlePhaseComplete(emit);
    } else {
      // Countdown beeps during rest phase
      if (state.phase == WorkoutPhase.rest && newTime <= 3 && newTime > 0) {
        _audioService.speakCountdown(newTime);
      }
      emit(state.copyWith(timeRemaining: newTime));
    }
  }

  void _handlePhaseComplete(Emitter<ActiveHomeWorkoutState> emit) {
    switch (state.phase) {
      case WorkoutPhase.preparation:
        // Move to first exercise
        _transitionToExercise(emit);
        break;

      case WorkoutPhase.exercise:
        // Time-based exercise completed, move to rest
        _transitionToRest(emit);
        break;

      case WorkoutPhase.rest:
        // Rest complete, move to next exercise
        _moveToNextExercise(emit);
        break;

      case WorkoutPhase.complete:
        _stopTimer();
        break;
    }
  }

  void _transitionToExercise(Emitter<ActiveHomeWorkoutState> emit) {
    final exercise = state.currentExercise;
    if (exercise == null) {
      emit(state.copyWith(phase: WorkoutPhase.complete));
      _stopTimer();
      return;
    }

    // Determine initial time for exercise
    final exerciseTime = exercise.durationSeconds > 0
        ? exercise.durationSeconds
        : 0; // Rep-based exercises don't have a countdown

    emit(
      state.copyWith(phase: WorkoutPhase.exercise, timeRemaining: exerciseTime),
    );

    // Announce exercise
    _audioService.speakExerciseStart(
      exerciseName: exercise.exercise.name,
      durationSeconds: exercise.durationSeconds > 0
          ? exercise.durationSeconds
          : null,
      reps: exercise.reps > 0 ? exercise.reps : null,
    );

    // If rep-based, stop the timer (user taps to complete)
    if (exercise.durationSeconds == 0) {
      _stopTimer();
    }
  }

  void _transitionToRest(Emitter<ActiveHomeWorkoutState> emit) {
    // If last exercise, go to complete
    if (state.isLastExercise) {
      emit(state.copyWith(phase: WorkoutPhase.complete));
      _audioService.speakComplete();
      _stopTimer();
      return;
    }

    emit(
      state.copyWith(phase: WorkoutPhase.rest, timeRemaining: defaultRestTime),
    );
    _startTimer();
  }

  void _moveToNextExercise(Emitter<ActiveHomeWorkoutState> emit) {
    final nextIndex = state.currentExerciseIndex + 1;

    if (nextIndex >= state.totalExercises) {
      emit(state.copyWith(phase: WorkoutPhase.complete));
      _audioService.speakComplete();
      _stopTimer();
      return;
    }

    // Go directly to next exercise (with preparation)
    final nextExercise = state.workout!.exercises[nextIndex];
    final exerciseTime = nextExercise.durationSeconds > 0
        ? nextExercise.durationSeconds
        : 0;

    emit(
      state.copyWith(
        phase: WorkoutPhase.exercise,
        currentExerciseIndex: nextIndex,
        timeRemaining: exerciseTime,
      ),
    );

    // Announce the next exercise
    _audioService.speakExerciseStart(
      exerciseName: nextExercise.exercise.name,
      durationSeconds: nextExercise.durationSeconds > 0
          ? nextExercise.durationSeconds
          : null,
      reps: nextExercise.reps > 0 ? nextExercise.reps : null,
    );

    // If rep-based, stop timer
    if (nextExercise.durationSeconds == 0) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  void _onCompleteExercise(
    CompleteExercise event,
    Emitter<ActiveHomeWorkoutState> emit,
  ) {
    if (state.phase != WorkoutPhase.exercise) return;

    // Move to rest (or complete if last exercise)
    _transitionToRest(emit);
  }

  void _onAddRestTime(AddRestTime event, Emitter<ActiveHomeWorkoutState> emit) {
    if (state.phase != WorkoutPhase.rest) return;

    emit(
      state.copyWith(
        timeRemaining: state.timeRemaining + event.seconds,
        totalRestTaken: state.totalRestTaken + event.seconds,
      ),
    );
  }

  void _onSkipRest(SkipRest event, Emitter<ActiveHomeWorkoutState> emit) {
    if (state.phase != WorkoutPhase.rest) return;

    _moveToNextExercise(emit);
  }

  void _onPauseWorkout(
    PauseWorkout event,
    Emitter<ActiveHomeWorkoutState> emit,
  ) {
    emit(state.copyWith(isPaused: true));
  }

  void _onResumeWorkout(
    ResumeWorkout event,
    Emitter<ActiveHomeWorkoutState> emit,
  ) {
    emit(state.copyWith(isPaused: false));

    // Restart timer if in a timed phase
    if (state.phase == WorkoutPhase.exercise && state.isTimeBased ||
        state.phase == WorkoutPhase.rest ||
        state.phase == WorkoutPhase.preparation) {
      _startTimer();
    }
  }

  void _onSkipPreparation(
    SkipPreparation event,
    Emitter<ActiveHomeWorkoutState> emit,
  ) {
    if (state.phase != WorkoutPhase.preparation) return;
    _transitionToExercise(emit);
  }

  void _onPreviousExercise(
    PreviousExercise event,
    Emitter<ActiveHomeWorkoutState> emit,
  ) {
    if (state.phase != WorkoutPhase.exercise) return;
    if (state.currentExerciseIndex <= 0) return;

    final prevIndex = state.currentExerciseIndex - 1;
    final prevExercise = state.workout!.exercises[prevIndex];
    final exerciseTime = prevExercise.durationSeconds > 0
        ? prevExercise.durationSeconds
        : 0;

    emit(
      state.copyWith(
        currentExerciseIndex: prevIndex,
        timeRemaining: exerciseTime,
      ),
    );

    if (prevExercise.durationSeconds == 0) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  @override
  Future<void> close() {
    _stopTimer();
    return super.close();
  }
}
