import 'package:fitness_app/core/services/database_service.dart';
import 'package:sqflite/sqflite.dart';

/// Model for a custom workout created by user
class CustomWorkout {
  final String id;
  final String name;
  final String description;
  final String category;
  final String difficulty;
  final List<CustomWorkoutExercise> exercises;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomWorkout({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.difficulty,
    required this.exercises,
    required this.createdAt,
    required this.updatedAt,
  });

  int get totalMinutes {
    int totalSeconds = 0;
    for (var ex in exercises) {
      if (ex.isTimeBased) {
        totalSeconds += ex.durationSeconds;
      } else {
        totalSeconds += 30; // Estimate 30s per rep-based exercise
      }
      totalSeconds += ex.restSeconds;
    }
    return (totalSeconds / 60).ceil();
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'difficulty': difficulty,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory CustomWorkout.fromMap(
    Map<String, dynamic> map,
    List<CustomWorkoutExercise> exercises,
  ) => CustomWorkout(
    id: map['id'] as String,
    name: map['name'] as String,
    description: map['description'] as String? ?? '',
    category: map['category'] as String,
    difficulty: map['difficulty'] as String,
    exercises: exercises,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
  );
}

class CustomWorkoutExercise {
  final String exerciseId;
  final String exerciseName;
  final String category;
  final bool isTimeBased;
  final int reps;
  final int durationSeconds;
  final int restSeconds;
  final int orderIndex;

  CustomWorkoutExercise({
    required this.exerciseId,
    required this.exerciseName,
    required this.category,
    required this.isTimeBased,
    required this.reps,
    required this.durationSeconds,
    required this.restSeconds,
    this.orderIndex = 0,
  });

  Map<String, dynamic> toMap(String workoutId, int index) => {
    'workout_id': workoutId,
    'exercise_id': exerciseId,
    'exercise_name': exerciseName,
    'category': category,
    'is_time_based': isTimeBased ? 1 : 0,
    'reps': reps,
    'duration_seconds': durationSeconds,
    'rest_seconds': restSeconds,
    'order_index': index,
  };

  factory CustomWorkoutExercise.fromMap(Map<String, dynamic> map) =>
      CustomWorkoutExercise(
        exerciseId: map['exercise_id'] as String,
        exerciseName: map['exercise_name'] as String,
        category: map['category'] as String? ?? 'strength',
        isTimeBased: (map['is_time_based'] as int) == 1,
        reps: map['reps'] as int? ?? 12,
        durationSeconds: map['duration_seconds'] as int? ?? 30,
        restSeconds: map['rest_seconds'] as int? ?? 15,
        orderIndex: map['order_index'] as int? ?? 0,
      );
}

/// Service to manage custom workout persistence using SQLite
class CustomWorkoutService {
  static final CustomWorkoutService _instance =
      CustomWorkoutService._internal();
  factory CustomWorkoutService() => _instance;
  CustomWorkoutService._internal();

  final DatabaseService _dbService = DatabaseService();

  /// Get all custom workouts
  Future<List<CustomWorkout>> getAllWorkouts() async {
    final db = await _dbService.database;

    // Get all workouts
    final workoutMaps = await db.query(
      'custom_workouts',
      orderBy: 'updated_at DESC',
    );

    // For each workout, get its exercises
    final workouts = <CustomWorkout>[];
    for (final workoutMap in workoutMaps) {
      final exercises = await _getExercisesForWorkout(
        workoutMap['id'] as String,
      );
      workouts.add(CustomWorkout.fromMap(workoutMap, exercises));
    }

    return workouts;
  }

  /// Get exercises for a specific workout
  Future<List<CustomWorkoutExercise>> _getExercisesForWorkout(
    String workoutId,
  ) async {
    final db = await _dbService.database;

    final exerciseMaps = await db.query(
      'custom_workout_exercises',
      where: 'workout_id = ?',
      whereArgs: [workoutId],
      orderBy: 'order_index ASC',
    );

    return exerciseMaps.map((m) => CustomWorkoutExercise.fromMap(m)).toList();
  }

  /// Save a new custom workout
  Future<void> saveWorkout(CustomWorkout workout) async {
    final db = await _dbService.database;

    // Use transaction for data integrity
    await db.transaction((txn) async {
      // Insert or replace workout
      await txn.insert(
        'custom_workouts',
        workout.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Delete existing exercises for this workout
      await txn.delete(
        'custom_workout_exercises',
        where: 'workout_id = ?',
        whereArgs: [workout.id],
      );

      // Insert new exercises
      for (int i = 0; i < workout.exercises.length; i++) {
        await txn.insert(
          'custom_workout_exercises',
          workout.exercises[i].toMap(workout.id, i),
        );
      }
    });
  }

  /// Delete a custom workout
  Future<void> deleteWorkout(String id) async {
    final db = await _dbService.database;

    // Exercises are deleted automatically due to ON DELETE CASCADE
    await db.delete('custom_workouts', where: 'id = ?', whereArgs: [id]);
  }

  /// Get a single workout by ID
  Future<CustomWorkout?> getWorkoutById(String id) async {
    final db = await _dbService.database;

    final workoutMaps = await db.query(
      'custom_workouts',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (workoutMaps.isEmpty) return null;

    final exercises = await _getExercisesForWorkout(id);
    return CustomWorkout.fromMap(workoutMaps.first, exercises);
  }

  /// Update workout timestamp
  Future<void> touchWorkout(String id) async {
    final db = await _dbService.database;

    await db.update(
      'custom_workouts',
      {'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
