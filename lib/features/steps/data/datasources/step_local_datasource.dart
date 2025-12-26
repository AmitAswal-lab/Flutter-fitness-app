import 'dart:convert';

import 'package:fitness_app/features/steps/data/models/step_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

abstract class StepLocalDatasource {
  Future<void> cacheDailySteps(String userId, StepModel step);
  Future<StepModel?> getLastSavedSteps(String userId);
  Future<void> saveDailyTotal(String userId, DateTime date, int steps);
  Future<List<StepModel>> getweeklyHistory(String userId);
}

class StepLocalDatasourceImpl implements StepLocalDatasource {
  final SharedPreferences sharedPreferences;
  StepLocalDatasourceImpl({required this.sharedPreferences});

  String _cachedStepsKey(String userId) => 'cached_steps_$userId';
  String _historyKey(String userId) => 'steps_history_$userId';

  /// Format date as YYYY-MM-DD for consistent key
  String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  Future<void> cacheDailySteps(String userId, StepModel stepModel) {
    return sharedPreferences.setString(
      _cachedStepsKey(userId),
      json.encode(stepModel.toJson()),
    );
  }

  @override
  Future<StepModel?> getLastSavedSteps(String userId) {
    final cachedSteps = sharedPreferences.getString(_cachedStepsKey(userId));
    if (cachedSteps != null) {
      return Future.value(StepModel.fromJson(json.decode(cachedSteps)));
    }
    return Future.value(null);
  }

  @override
  Future<void> saveDailyTotal(String userId, DateTime date, int steps) async {
    final historyJson = sharedPreferences.getString(_historyKey(userId));
    Map<String, dynamic> history = {};

    if (historyJson != null) {
      history = json.decode(historyJson) as Map<String, dynamic>;
    }

    // Save/update the date's total
    history[_dateKey(date)] = steps;

    // Keep only last 14 days to prevent unbounded growth
    final cutoff = DateTime.now().subtract(const Duration(days: 14));
    history.removeWhere((key, _) {
      try {
        return DateTime.parse(key).isBefore(cutoff);
      } catch (_) {
        return true;
      }
    });

    await sharedPreferences.setString(
      _historyKey(userId),
      json.encode(history),
    );
  }

  Future<void> _syncArchivedSteps(String userId) async {
    final prevDateStr = sharedPreferences.getString('previous_day_date');
    if (prevDateStr != null) {
      final prevSteps = sharedPreferences.getInt('previous_day_steps') ?? 0;

      // Parse date
      try {
        final parts = prevDateStr.split('-');
        if (parts.length == 3) {
          final date = DateTime(
            int.parse(parts[0]),
            int.parse(parts[1]),
            int.parse(parts[2]),
          );
          await saveDailyTotal(userId, date, prevSteps);

          // Clear archive after saving
          await sharedPreferences.remove('previous_day_date');
          await sharedPreferences.remove('previous_day_steps');
        }
      } catch (e) {
        // ignore error
      }
    }
  }

  @override
  Future<List<StepModel>> getweeklyHistory(String userId) async {
    // Check for any pending archived steps from native side
    await _syncArchivedSteps(userId);

    final historyJson = sharedPreferences.getString(_historyKey(userId));
    if (historyJson == null) return [];

    final history = json.decode(historyJson) as Map<String, dynamic>;
    final now = DateTime.now();
    final result = <StepModel>[];

    // Get last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      final key = _dateKey(date);
      final steps = history[key] as int? ?? 0;
      result.add(StepModel(steps: steps, timestamp: date));
    }

    return result;
  }
}
