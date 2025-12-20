import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_session.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_template.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'active_workout_event.dart';
part 'active_workout_state.dart';

class ActiveWorkoutBloc extends Bloc<ActiveWorkoutEvent, ActiveWorkoutState> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  int _restSecondsRemaining = 0;

  ActiveWorkoutBloc() : super(ActiveWorkoutInitial()) {
    on<StartWorkout>(_onStartWorkout);
    on<NextExercise>(_onNextExercise);
    on<PreviousExercise>(_onPreviousExercise);
    on<CompleteSet>(_onCompleteSet);
    on<StartRest>(_onStartRest);
    on<SkipRest>(_onSkipRest);
    on<TimerTick>(_onTimerTick);
    on<PauseWorkout>(_onPauseWorkout);
    on<ResumeWorkout>(_onResumeWorkout);
    on<FinishWorkout>(_onFinishWorkout);
    on<AbandonWorkout>(_onAbandonWorkout);
  }

  void _onStartWorkout(StartWorkout event, Emitter<ActiveWorkoutState> emit) {
    _elapsedSeconds = 0;
    _startTimer();

    emit(
      ActiveWorkoutInProgress(
        template: event.template,
        userId: event.userId,
        currentExerciseIndex: 0,
        currentSetIndex: 0,
        completedSets: [],
        elapsedSeconds: 0,
        isResting: false,
        restSecondsRemaining: 0,
        isPaused: false,
      ),
    );
  }

  void _onNextExercise(NextExercise event, Emitter<ActiveWorkoutState> emit) {
    if (state is! ActiveWorkoutInProgress) return;
    final current = state as ActiveWorkoutInProgress;

    if (current.currentExerciseIndex < current.template.exercises.length - 1) {
      emit(
        current.copyWith(
          currentExerciseIndex: current.currentExerciseIndex + 1,
          currentSetIndex: 0,
        ),
      );
    }
  }

  void _onPreviousExercise(
    PreviousExercise event,
    Emitter<ActiveWorkoutState> emit,
  ) {
    if (state is! ActiveWorkoutInProgress) return;
    final current = state as ActiveWorkoutInProgress;

    if (current.currentExerciseIndex > 0) {
      emit(
        current.copyWith(
          currentExerciseIndex: current.currentExerciseIndex - 1,
          currentSetIndex: 0,
        ),
      );
    }
  }

  void _onCompleteSet(CompleteSet event, Emitter<ActiveWorkoutState> emit) {
    if (state is! ActiveWorkoutInProgress) return;
    final current = state as ActiveWorkoutInProgress;
    final exercise = current.template.exercises[current.currentExerciseIndex];

    final newSet = CompletedSet(
      exerciseId: exercise.exercise.id,
      setNumber: current.currentSetIndex + 1,
      weight: event.weight,
      reps: event.reps,
      durationSeconds: event.durationSeconds,
      isCompleted: true,
    );

    final updatedSets = [...current.completedSets, newSet];

    // Check if more sets remain for this exercise
    if (current.currentSetIndex + 1 < exercise.sets) {
      // Start rest period
      add(StartRest(seconds: exercise.restSeconds));
      emit(
        current.copyWith(
          currentSetIndex: current.currentSetIndex + 1,
          completedSets: updatedSets,
        ),
      );
    } else if (current.currentExerciseIndex + 1 <
        current.template.exercises.length) {
      // Move to next exercise
      emit(
        current.copyWith(
          currentExerciseIndex: current.currentExerciseIndex + 1,
          currentSetIndex: 0,
          completedSets: updatedSets,
        ),
      );
    } else {
      // Workout complete!
      add(const FinishWorkout());
    }
  }

  void _onStartRest(StartRest event, Emitter<ActiveWorkoutState> emit) {
    if (state is! ActiveWorkoutInProgress) return;
    final current = state as ActiveWorkoutInProgress;

    _restSecondsRemaining = event.seconds;
    emit(
      current.copyWith(isResting: true, restSecondsRemaining: event.seconds),
    );
  }

  void _onSkipRest(SkipRest event, Emitter<ActiveWorkoutState> emit) {
    if (state is! ActiveWorkoutInProgress) return;
    final current = state as ActiveWorkoutInProgress;

    _restSecondsRemaining = 0;
    emit(current.copyWith(isResting: false, restSecondsRemaining: 0));
  }

  void _onTimerTick(TimerTick event, Emitter<ActiveWorkoutState> emit) {
    if (state is! ActiveWorkoutInProgress) return;
    final current = state as ActiveWorkoutInProgress;

    if (current.isPaused) return;

    _elapsedSeconds++;

    if (current.isResting && _restSecondsRemaining > 0) {
      _restSecondsRemaining--;
      if (_restSecondsRemaining == 0) {
        emit(
          current.copyWith(
            elapsedSeconds: _elapsedSeconds,
            isResting: false,
            restSecondsRemaining: 0,
          ),
        );
      } else {
        emit(
          current.copyWith(
            elapsedSeconds: _elapsedSeconds,
            restSecondsRemaining: _restSecondsRemaining,
          ),
        );
      }
    } else {
      emit(current.copyWith(elapsedSeconds: _elapsedSeconds));
    }
  }

  void _onPauseWorkout(PauseWorkout event, Emitter<ActiveWorkoutState> emit) {
    if (state is! ActiveWorkoutInProgress) return;
    final current = state as ActiveWorkoutInProgress;
    emit(current.copyWith(isPaused: true));
  }

  void _onResumeWorkout(ResumeWorkout event, Emitter<ActiveWorkoutState> emit) {
    if (state is! ActiveWorkoutInProgress) return;
    final current = state as ActiveWorkoutInProgress;
    emit(current.copyWith(isPaused: false));
  }

  void _onFinishWorkout(FinishWorkout event, Emitter<ActiveWorkoutState> emit) {
    _stopTimer();
    if (state is! ActiveWorkoutInProgress) return;
    final current = state as ActiveWorkoutInProgress;

    emit(
      ActiveWorkoutCompleted(
        template: current.template,
        userId: current.userId,
        completedSets: current.completedSets,
        totalSeconds: _elapsedSeconds,
      ),
    );
  }

  void _onAbandonWorkout(
    AbandonWorkout event,
    Emitter<ActiveWorkoutState> emit,
  ) {
    _stopTimer();
    emit(ActiveWorkoutInitial());
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

  @override
  Future<void> close() {
    _stopTimer();
    return super.close();
  }
}
