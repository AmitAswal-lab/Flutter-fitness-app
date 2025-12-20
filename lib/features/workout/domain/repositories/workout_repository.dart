import 'package:fitness_app/features/workout/domain/entities/workout_session.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_template.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise.dart';

abstract class WorkoutRepository {
  /// Get all available workout templates
  Future<List<WorkoutTemplate>> getWorkoutTemplates();

  /// Get workout templates by category
  Future<List<WorkoutTemplate>> getWorkoutsByCategory(
    ExerciseCategory category,
  );

  /// Get a specific workout template by ID
  Future<WorkoutTemplate?> getWorkoutById(String id);

  /// Get all exercises
  Future<List<Exercise>> getAllExercises();

  /// Save a custom workout template
  Future<void> saveCustomWorkout(WorkoutTemplate workout);

  /// Start a new workout session
  Future<WorkoutSession> startWorkout(String odId, WorkoutTemplate template);

  /// Update an ongoing workout session
  Future<void> updateWorkoutSession(WorkoutSession session);

  /// Complete a workout session
  Future<void> completeWorkout(WorkoutSession session);

  /// Get workout history for a user
  Future<List<WorkoutSession>> getWorkoutHistory(String odId);

  /// Get workout sessions for a specific date range
  Future<List<WorkoutSession>> getWorkoutsByDateRange(
    String odId,
    DateTime start,
    DateTime end,
  );
}
