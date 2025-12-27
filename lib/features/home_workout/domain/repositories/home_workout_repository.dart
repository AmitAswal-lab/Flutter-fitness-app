import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_template.dart';
import 'package:fpdart/fpdart.dart';

abstract class HomeWorkoutRepository {
  Future<Either<Failure, WorkoutTemplate>> getFullBodyWorkout();
  Future<Either<Failure, void>> updateWorkout(WorkoutTemplate workout);
}
