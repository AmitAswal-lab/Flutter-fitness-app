import 'package:fitness_app/features/profile/domain/entities/user_profile.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_template.dart';

class WorkoutAdapterService {
  /// Adapts a workout template to the user's fitness level and attributes.
  /// Returns a new WorkoutTemplate with modified sets/reps/rest.
  WorkoutTemplate adaptWorkout(WorkoutTemplate workout, UserProfile profile) {
    if (profile.fitnessLevel == null) {
      return workout; // No adaptation possible without fitness level
    }

    // 1. Calculate Difficulty Modifier (User Level vs Workout Difficulty)
    final double scalingFactor = _calculateScalingFactor(
      profile.fitnessLevel!,
      workout.difficulty,
    );

    // 2. Apply scaling to each exercise
    final List<WorkoutExercise> adaptedExercises = workout.exercises.map((e) {
      return _adaptExercise(e, scalingFactor, profile);
    }).toList();

    return _copyWithExercises(workout, adaptedExercises);
  }

  /// Calculates a multiplier for reps/sets based on mismatch between user level and workout difficulty
  double _calculateScalingFactor(
    FitnessLevel userLevel,
    WorkoutDifficulty workoutDifficulty,
  ) {
    // Score: Beginner=1, Intermediate=2, Advanced=3
    int userScore = _fitnessLevelScore(userLevel);
    int workoutScore = _workoutDifficultyScore(workoutDifficulty);

    int diff = userScore - workoutScore;

    if (diff == 0) return 1.0; // Perfect match
    if (diff > 0) {
      // User is more advanced than workout -> Scale UP
      // +1 diff (e.g. Int user doing Beg workout) -> +20%
      // +2 diff (e.g. Adv user doing Beg workout) -> +50%
      return 1.0 + (diff * 0.25);
    } else {
      // User is less advanced than workout -> Scale DOWN
      // -1 diff (e.g. Beg user doing Int workout) -> -20%
      // -2 diff (e.g. Beg user doing Adv workout) -> -40%
      return 1.0 + (diff * 0.20);
    }
  }

  WorkoutExercise _adaptExercise(
    WorkoutExercise exercise,
    double scalingFactor,
    UserProfile profile,
  ) {
    // Apply base scaling
    int newSets = exercise.sets;
    int newReps = (exercise.reps * scalingFactor).round();
    int newDuration = (exercise.durationSeconds * scalingFactor).round();

    // Bodyweight adjustments
    // If user is heavy (>90kg) and it's a bodyweight exercise, reduce reps slightly
    // to keep relative intensity manageable, unless they are Advanced.
    if (_isBodyweight(exercise.exercise) &&
        (profile.weightKg ?? 0) > 90 &&
        profile.fitnessLevel != FitnessLevel.advanced) {
      newReps = (newReps * 0.85).round(); // 15% reduction for heavy bodyweight
    }

    // Ensure minimums
    if (newSets < 1) newSets = 1;
    if (newReps > 0 && newReps < 5) newReps = 5; // Min 5 reps
    if (newDuration > 0 && newDuration < 20) newDuration = 20; // Min 20s

    return WorkoutExercise(
      exercise: exercise.exercise,
      sets: newSets,
      reps: newReps,
      durationSeconds: newDuration,
      restSeconds: _adaptRestTime(
        exercise.restSeconds,
        profile.fitnessLevel!,
        exercise.sets,
      ),
    );
  }

  int _adaptRestTime(int baseRest, FitnessLevel level, int sets) {
    switch (level) {
      case FitnessLevel.beginner:
        return (baseRest * 1.2).round(); // +20% rest
      case FitnessLevel.intermediate:
        return baseRest;
      case FitnessLevel.advanced:
        return (baseRest * 0.8).round(); // -20% rest
    }
  }

  bool _isBodyweight(Exercise exercise) {
    // Naively assume strength/calisthenics/HIIT are bodyweight relevant for now
    // Ideally Exercise entity would have an isBodyweight flag
    return exercise.category == ExerciseCategory.calisthenics ||
        exercise.category == ExerciseCategory.hiit ||
        exercise.muscleGroups.contains(MuscleGroup.fullBody);
  }

  int _fitnessLevelScore(FitnessLevel level) {
    switch (level) {
      case FitnessLevel.beginner:
        return 1;
      case FitnessLevel.intermediate:
        return 2;
      case FitnessLevel.advanced:
        return 3;
    }
  }

  int _workoutDifficultyScore(WorkoutDifficulty difficulty) {
    switch (difficulty) {
      case WorkoutDifficulty.beginner:
        return 1;
      case WorkoutDifficulty.intermediate:
        return 2;
      case WorkoutDifficulty.advanced:
        return 3;
    }
  }

  // Helper to copy WorkoutTemplate since it's immutable and doesn't have copyWith
  WorkoutTemplate _copyWithExercises(
    WorkoutTemplate original,
    List<WorkoutExercise> newExercises,
  ) {
    return WorkoutTemplate(
      id: original.id,
      name: original.name,
      description: original.description,
      category: original.category,
      difficulty: original.difficulty,
      estimatedMinutes: original.estimatedMinutes, // Could update this too
      exercises: newExercises,
      imageUrl: original.imageUrl,
      isCustom: original.isCustom,
    );
  }
}
