import 'package:equatable/equatable.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_template.dart';
import 'package:fitness_app/features/workout/domain/repositories/workout_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'workout_event.dart';
part 'workout_state.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final WorkoutRepository repository;

  WorkoutBloc({required this.repository}) : super(WorkoutInitial()) {
    on<LoadWorkouts>(_onLoadWorkouts);
    on<FilterByCategory>(_onFilterByCategory);
  }

  Future<void> _onLoadWorkouts(
    LoadWorkouts event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(WorkoutLoading());
    try {
      final workouts = await repository.getWorkoutTemplates();
      emit(WorkoutLoaded(workouts: workouts, selectedCategory: null));
    } catch (e) {
      emit(WorkoutError(message: e.toString()));
    }
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<WorkoutState> emit,
  ) async {
    emit(WorkoutLoading());
    try {
      List<WorkoutTemplate> workouts;
      if (event.category == null) {
        workouts = await repository.getWorkoutTemplates();
      } else {
        workouts = await repository.getWorkoutsByCategory(event.category!);
      }
      emit(WorkoutLoaded(workouts: workouts, selectedCategory: event.category));
    } catch (e) {
      emit(WorkoutError(message: e.toString()));
    }
  }
}
