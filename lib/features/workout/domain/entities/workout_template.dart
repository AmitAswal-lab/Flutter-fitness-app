import 'package:equatable/equatable.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise.dart';

class WorkoutTemplate extends Equatable {
  final String id;
  final String name;
  final String description;
  final ExerciseCategory category;
  final WorkoutDifficulty difficulty;
  final int estimatedMinutes;
  final List<WorkoutExercise> exercises;
  final String? imageUrl;
  final bool isCustom;

  const WorkoutTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.exercises,
    this.imageUrl,
    this.isCustom = false,
  });

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets);

  @override
  List<Object?> get props => [id, name, category, difficulty, exercises];
}

/// An exercise within a workout template with sets/reps configuration
class WorkoutExercise extends Equatable {
  final Exercise exercise;
  final int sets;
  final int reps; // For rep-based exercises
  final int durationSeconds; // For time-based exercises
  final int restSeconds;

  const WorkoutExercise({
    required this.exercise,
    required this.sets,
    this.reps = 0,
    this.durationSeconds = 0,
    this.restSeconds = 60,
  });

  @override
  List<Object?> get props => [exercise, sets, reps, durationSeconds];
}

enum WorkoutDifficulty { beginner, intermediate, advanced }

extension WorkoutDifficultyExtension on WorkoutDifficulty {
  String get displayName {
    switch (this) {
      case WorkoutDifficulty.beginner:
        return 'Beginner';
      case WorkoutDifficulty.intermediate:
        return 'Intermediate';
      case WorkoutDifficulty.advanced:
        return 'Advanced';
    }
  }

  String get icon {
    switch (this) {
      case WorkoutDifficulty.beginner:
        return '🌱';
      case WorkoutDifficulty.intermediate:
        return '🌿';
      case WorkoutDifficulty.advanced:
        return '🌳';
    }
  }
}
