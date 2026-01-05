import 'package:fitness_app/core/services/database_service.dart';

/// Model for a completed workout record
class WorkoutHistoryRecord {
  final int? id;
  final String? workoutId;
  final String workoutName;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int durationSeconds;
  final int exercisesCompleted;
  final int totalExercises;
  final int caloriesBurned;
  final bool isCustomWorkout;

  WorkoutHistoryRecord({
    this.id,
    this.workoutId,
    required this.workoutName,
    required this.startedAt,
    this.completedAt,
    required this.durationSeconds,
    required this.exercisesCompleted,
    required this.totalExercises,
    required this.caloriesBurned,
    this.isCustomWorkout = false,
  });

  bool get isCompleted => completedAt != null;

  double get completionPercentage =>
      totalExercises > 0 ? (exercisesCompleted / totalExercises * 100) : 0;

  Map<String, dynamic> toMap() => {
    'workout_id': workoutId,
    'workout_name': workoutName,
    'started_at': startedAt.toIso8601String(),
    'completed_at': completedAt?.toIso8601String(),
    'duration_seconds': durationSeconds,
    'exercises_completed': exercisesCompleted,
    'total_exercises': totalExercises,
    'calories_burned': caloriesBurned,
  };

  factory WorkoutHistoryRecord.fromMap(Map<String, dynamic> map) =>
      WorkoutHistoryRecord(
        id: map['id'] as int?,
        workoutId: map['workout_id'] as String?,
        workoutName: map['workout_name'] as String,
        startedAt: DateTime.parse(map['started_at'] as String),
        completedAt: map['completed_at'] != null
            ? DateTime.parse(map['completed_at'] as String)
            : null,
        durationSeconds: map['duration_seconds'] as int? ?? 0,
        exercisesCompleted: map['exercises_completed'] as int? ?? 0,
        totalExercises: map['total_exercises'] as int? ?? 0,
        caloriesBurned: map['calories_burned'] as int? ?? 0,
      );
}

/// Service to manage workout history
class WorkoutHistoryService {
  static final WorkoutHistoryService _instance =
      WorkoutHistoryService._internal();
  factory WorkoutHistoryService() => _instance;
  WorkoutHistoryService._internal();

  final DatabaseService _dbService = DatabaseService();

  /// Log a completed workout
  Future<void> logWorkout(WorkoutHistoryRecord record) async {
    final db = await _dbService.database;
    await db.insert('workout_history', record.toMap());
  }

  /// Get all workout history records
  Future<List<WorkoutHistoryRecord>> getAllHistory() async {
    final db = await _dbService.database;

    final records = await db.query(
      'workout_history',
      orderBy: 'started_at DESC',
    );

    return records.map((m) => WorkoutHistoryRecord.fromMap(m)).toList();
  }

  /// Get history for a specific date range
  Future<List<WorkoutHistoryRecord>> getHistoryInRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _dbService.database;

    final records = await db.query(
      'workout_history',
      where: 'started_at >= ? AND started_at <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'started_at DESC',
    );

    return records.map((m) => WorkoutHistoryRecord.fromMap(m)).toList();
  }

  /// Get history for today
  Future<List<WorkoutHistoryRecord>> getTodayHistory() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return getHistoryInRange(startOfDay, endOfDay);
  }

  /// Get history for this week
  Future<List<WorkoutHistoryRecord>> getThisWeekHistory() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    return getHistoryInRange(startOfWeekDay, now);
  }

  /// Get history for this month
  Future<List<WorkoutHistoryRecord>> getThisMonthHistory() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return getHistoryInRange(startOfMonth, now);
  }

  /// Get workout stats summary
  Future<WorkoutStats> getStats() async {
    final db = await _dbService.database;

    // Total workouts
    final totalResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM workout_history',
    );
    final totalWorkouts = totalResult.first['count'] as int? ?? 0;

    // Completed workouts
    final completedResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM workout_history WHERE completed_at IS NOT NULL',
    );
    final completedWorkouts = completedResult.first['count'] as int? ?? 0;

    // Total duration
    final durationResult = await db.rawQuery(
      'SELECT SUM(duration_seconds) as total FROM workout_history',
    );
    final totalDurationSeconds = durationResult.first['total'] as int? ?? 0;

    // Total calories
    final caloriesResult = await db.rawQuery(
      'SELECT SUM(calories_burned) as total FROM workout_history',
    );
    final totalCalories = caloriesResult.first['total'] as int? ?? 0;

    // This week count
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );
    final weekResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM workout_history WHERE started_at >= ?',
      [startOfWeekDay.toIso8601String()],
    );
    final thisWeekWorkouts = weekResult.first['count'] as int? ?? 0;

    return WorkoutStats(
      totalWorkouts: totalWorkouts,
      completedWorkouts: completedWorkouts,
      totalDurationMinutes: (totalDurationSeconds / 60).round(),
      totalCaloriesBurned: totalCalories,
      thisWeekWorkouts: thisWeekWorkouts,
    );
  }

  /// Delete a history record
  Future<void> deleteRecord(int id) async {
    final db = await _dbService.database;
    await db.delete('workout_history', where: 'id = ?', whereArgs: [id]);
  }

  /// Clear all history
  Future<void> clearAllHistory() async {
    final db = await _dbService.database;
    await db.delete('workout_history');
  }
}

/// Summary stats for workouts
class WorkoutStats {
  final int totalWorkouts;
  final int completedWorkouts;
  final int totalDurationMinutes;
  final int totalCaloriesBurned;
  final int thisWeekWorkouts;

  WorkoutStats({
    required this.totalWorkouts,
    required this.completedWorkouts,
    required this.totalDurationMinutes,
    required this.totalCaloriesBurned,
    required this.thisWeekWorkouts,
  });

  int get averageDurationMinutes =>
      totalWorkouts > 0 ? (totalDurationMinutes / totalWorkouts).round() : 0;
}
