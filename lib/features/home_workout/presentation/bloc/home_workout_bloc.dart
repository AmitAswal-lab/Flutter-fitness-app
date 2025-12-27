import 'package:equatable/equatable.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_template.dart';
import 'package:fitness_app/features/home_workout/domain/repositories/home_workout_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_workout_event.dart';
part 'home_workout_state.dart';

class HomeWorkoutBloc extends Bloc<HomeWorkoutEvent, HomeWorkoutState> {
  final HomeWorkoutRepository repository;

  HomeWorkoutBloc({required this.repository})
    : super(const HomeWorkoutState()) {
    on<LoadHomeWorkout>(_onLoadHomeWorkout);
    on<ReorderExercises>(_onReorderExercises);
    on<UpdateExerciseReps>(_onUpdateExerciseReps);
    on<UpdateExerciseDuration>(_onUpdateExerciseDuration);
    on<SaveHomeWorkout>(_onSaveHomeWorkout);
  }

  Future<void> _onLoadHomeWorkout(
    LoadHomeWorkout event,
    Emitter<HomeWorkoutState> emit,
  ) async {
    emit(state.copyWith(status: HomeWorkoutStatus.loading));

    final result = await repository.getFullBodyWorkout();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HomeWorkoutStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (workout) => emit(
        state.copyWith(
          status: HomeWorkoutStatus.loaded,
          workout: workout,
          hasUnsavedChanges: false,
        ),
      ),
    );
  }

  void _onReorderExercises(
    ReorderExercises event,
    Emitter<HomeWorkoutState> emit,
  ) {
    if (state.workout == null) return;

    final currentExercises = List<WorkoutExercise>.from(
      state.workout!.exercises,
    );
    if (event.oldIndex < event.newIndex) {
      // Adjust because removing the item shifts subsequent indices
      // But ReorderableListView usually handles the drag index logic.
      // Standard boilerplate:
      // if (oldIndex < newIndex) { newIndex -= 1; }
      // Checks should happen in UI but Bloc receives raw indices usually.
      // Let's assume standard flutter logic:
    }

    // Actually the logic `if (oldIndex < newIndex) newIndex -= 1;` is for the List.insert method *after* removeAt.
    // Let's just do it carefully.

    var newIndex = event.newIndex;
    if (event.oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = currentExercises.removeAt(event.oldIndex);
    currentExercises.insert(newIndex, item);

    final updatedWorkout = WorkoutTemplate(
      id: state.workout!.id,
      name: state.workout!.name,
      description: state.workout!.description,
      category: state.workout!.category,
      difficulty: state.workout!.difficulty,
      estimatedMinutes: state.workout!.estimatedMinutes,
      exercises: currentExercises,
      imageUrl: state.workout!.imageUrl,
      isCustom: true,
    );

    emit(state.copyWith(workout: updatedWorkout, hasUnsavedChanges: true));
  }

  void _onUpdateExerciseReps(
    UpdateExerciseReps event,
    Emitter<HomeWorkoutState> emit,
  ) {
    if (state.workout == null) return;

    final currentExercises = List<WorkoutExercise>.from(
      state.workout!.exercises,
    );
    final targetExercise = currentExercises[event.exerciseIndex];

    final updatedExercise = WorkoutExercise(
      exercise: targetExercise.exercise,
      sets: targetExercise.sets,
      reps: event.newReps,
      durationSeconds: targetExercise.durationSeconds,
      restSeconds: targetExercise.restSeconds,
    );

    currentExercises[event.exerciseIndex] = updatedExercise;

    final updatedWorkout = WorkoutTemplate(
      id: state.workout!.id,
      name: state.workout!.name,
      description: state.workout!.description,
      category: state.workout!.category,
      difficulty: state.workout!.difficulty,
      estimatedMinutes: state.workout!.estimatedMinutes,
      exercises: currentExercises,
      imageUrl: state.workout!.imageUrl,
      isCustom: true,
    );

    emit(state.copyWith(workout: updatedWorkout, hasUnsavedChanges: true));
  }

  void _onUpdateExerciseDuration(
    UpdateExerciseDuration event,
    Emitter<HomeWorkoutState> emit,
  ) {
    if (state.workout == null) return;

    final currentExercises = List<WorkoutExercise>.from(
      state.workout!.exercises,
    );
    final targetExercise = currentExercises[event.exerciseIndex];

    final updatedExercise = WorkoutExercise(
      exercise: targetExercise.exercise,
      sets: targetExercise.sets,
      reps: targetExercise.reps,
      durationSeconds: event.newDurationSeconds,
      restSeconds: targetExercise.restSeconds,
    );

    currentExercises[event.exerciseIndex] = updatedExercise;

    final updatedWorkout = WorkoutTemplate(
      id: state.workout!.id,
      name: state.workout!.name,
      description: state.workout!.description,
      category: state.workout!.category,
      difficulty: state.workout!.difficulty,
      estimatedMinutes: state.workout!.estimatedMinutes,
      exercises: currentExercises,
      imageUrl: state.workout!.imageUrl,
      isCustom: true,
    );

    emit(state.copyWith(workout: updatedWorkout, hasUnsavedChanges: true));
  }

  Future<void> _onSaveHomeWorkout(
    SaveHomeWorkout event,
    Emitter<HomeWorkoutState> emit,
  ) async {
    if (state.workout == null) return;

    emit(state.copyWith(status: HomeWorkoutStatus.saving));

    final result = await repository.updateWorkout(state.workout!);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HomeWorkoutStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(
        state.copyWith(
          status: HomeWorkoutStatus.saved,
          hasUnsavedChanges: false,
        ),
      ),
    );
  }
}
