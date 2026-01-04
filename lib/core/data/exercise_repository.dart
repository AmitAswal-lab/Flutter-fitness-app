import 'package:fitness_app/core/data/exercise_database.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise.dart';

/// Repository for accessing exercise data
class ExerciseRepository {
  static final ExerciseRepository _instance = ExerciseRepository._internal();
  factory ExerciseRepository() => _instance;
  ExerciseRepository._internal();

  List<Exercise>? _cachedExercises;

  /// Get all exercises
  List<Exercise> getAllExercises() {
    _cachedExercises ??= _loadExercises();
    return _cachedExercises!;
  }

  /// Get exercises by category
  List<Exercise> getByCategory(String category) {
    return getAllExercises()
        .where((e) => e.category.name.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Get exercises by muscle group
  List<Exercise> getByMuscleGroup(MuscleGroup muscleGroup) {
    return getAllExercises()
        .where((e) => e.muscleGroups.contains(muscleGroup))
        .toList();
  }

  /// Search exercises by name
  List<Exercise> search(String query) {
    final lowerQuery = query.toLowerCase();
    return getAllExercises()
        .where(
          (e) =>
              e.name.toLowerCase().contains(lowerQuery) ||
              e.description.toLowerCase().contains(lowerQuery),
        )
        .toList();
  }

  /// Get exercise by ID
  Exercise? getById(String id) {
    try {
      return getAllExercises().firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Exercise> _loadExercises() {
    return ExerciseData.exercises.map((data) {
      final categoryString = data['category'] as String;
      final category = _parseCategory(categoryString);

      final muscleGroupStrings = data['muscleGroups'] as List<dynamic>;
      final muscleGroups = muscleGroupStrings
          .map((s) => _parseMuscleGroup(s as String))
          .toList();

      return Exercise(
        id: data['id'] as String,
        name: data['name'] as String,
        description: data['description'] as String,
        category: category,
        muscleGroups: muscleGroups,
        imageUrl: data['gifUrl'] as String?,
        videoUrl: null,
        isTimeBased: data['isTimeBased'] as bool,
      );
    }).toList();
  }

  ExerciseCategory _parseCategory(String category) {
    switch (category.toLowerCase()) {
      case 'cardio':
        return ExerciseCategory.cardio;
      case 'strength':
        return ExerciseCategory.strength;
      case 'hiit':
        return ExerciseCategory.hiit;
      case 'yoga':
        return ExerciseCategory.yoga;
      case 'stretching':
        return ExerciseCategory.stretching;
      case 'calisthenics':
        return ExerciseCategory.calisthenics;
      default:
        return ExerciseCategory.strength;
    }
  }

  MuscleGroup _parseMuscleGroup(String group) {
    switch (group.toLowerCase()) {
      case 'chest':
        return MuscleGroup.chest;
      case 'back':
        return MuscleGroup.back;
      case 'shoulders':
        return MuscleGroup.shoulders;
      case 'biceps':
        return MuscleGroup.biceps;
      case 'triceps':
        return MuscleGroup.triceps;
      case 'forearms':
        return MuscleGroup.forearms;
      case 'core':
        return MuscleGroup.core;
      case 'quadriceps':
        return MuscleGroup.quadriceps;
      case 'hamstrings':
        return MuscleGroup.hamstrings;
      case 'glutes':
        return MuscleGroup.glutes;
      case 'calves':
        return MuscleGroup.calves;
      case 'fullbody':
        return MuscleGroup.fullBody;
      default:
        return MuscleGroup.fullBody;
    }
  }
}
