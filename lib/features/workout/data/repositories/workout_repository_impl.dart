import 'dart:convert';

import 'package:fitness_app/features/workout/data/datasources/sample_workout_data.dart';
import 'package:fitness_app/features/workout/data/models/workout_session_model.dart';
import 'package:fitness_app/features/workout/data/models/workout_template_model.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_session.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_template.dart';
import 'package:fitness_app/features/workout/domain/repositories/workout_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final SharedPreferences sharedPreferences;
  static const _customWorkoutsKey = 'custom_workouts';

  WorkoutRepositoryImpl({required this.sharedPreferences});

  String _historyKey(String userId) => 'workout_history_$userId';

  @override
  Future<List<WorkoutTemplate>> getWorkoutTemplates() async {
    final sampleWorkouts = SampleWorkoutData.workoutTemplates;
    final customWorkouts = await _getCustomWorkouts();
    return [...sampleWorkouts, ...customWorkouts];
  }

  @override
  Future<List<WorkoutTemplate>> getWorkoutsByCategory(
    ExerciseCategory category,
  ) async {
    final allWorkouts = await getWorkoutTemplates();
    return allWorkouts.where((w) => w.category == category).toList();
  }

  @override
  Future<WorkoutTemplate?> getWorkoutById(String id) async {
    final allWorkouts = await getWorkoutTemplates();
    try {
      return allWorkouts.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Exercise>> getAllExercises() async {
    return SampleWorkoutData.exercises;
  }

  @override
  Future<void> saveCustomWorkout(WorkoutTemplate workout) async {
    final customWorkouts = await _getCustomWorkouts();
    customWorkouts.add(workout);
    final json = customWorkouts
        .map((w) => WorkoutTemplateModel.fromEntity(w).toJson())
        .toList();
    await sharedPreferences.setString(_customWorkoutsKey, jsonEncode(json));
  }

  Future<List<WorkoutTemplate>> _getCustomWorkouts() async {
    final jsonStr = sharedPreferences.getString(_customWorkoutsKey);
    if (jsonStr == null) return [];
    final List<dynamic> json = jsonDecode(jsonStr);
    return json
        .map((e) => WorkoutTemplateModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<WorkoutSession> startWorkout(
    String userId,
    WorkoutTemplate template,
  ) async {
    final session = WorkoutSession(
      id: const Uuid().v4(),
      userId: userId,
      template: template,
      startTime: DateTime.now(),
      status: WorkoutSessionStatus.inProgress,
    );
    return session;
  }

  @override
  Future<void> updateWorkoutSession(WorkoutSession session) async {
    // For in-progress sessions, we could save to a temporary key
    // For now, we only persist on completion
  }

  @override
  Future<void> completeWorkout(WorkoutSession session) async {
    final completedSession = session.copyWith(
      endTime: DateTime.now(),
      status: WorkoutSessionStatus.completed,
    );
    await _saveToHistory(completedSession);
  }

  Future<void> _saveToHistory(WorkoutSession session) async {
    final history = await getWorkoutHistory(session.userId);
    final updatedHistory = [session, ...history];

    final jsonList = updatedHistory
        .map((s) => WorkoutSessionModel.fromEntity(s).toJson())
        .toList();

    await sharedPreferences.setString(
      _historyKey(session.userId),
      jsonEncode(jsonList),
    );
  }

  @override
  Future<List<WorkoutSession>> getWorkoutHistory(String userId) async {
    final jsonStr = sharedPreferences.getString(_historyKey(userId));
    if (jsonStr == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonStr);
    return jsonList
        .map((e) => WorkoutSessionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<WorkoutSession>> getWorkoutsByDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final history = await getWorkoutHistory(userId);
    return history
        .where((s) => s.startTime.isAfter(start) && s.startTime.isBefore(end))
        .toList();
  }
}
