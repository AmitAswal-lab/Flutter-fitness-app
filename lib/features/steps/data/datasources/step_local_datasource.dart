import 'dart:convert';

import 'package:fitness_app/features/steps/data/models/step_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

abstract class StepLocalDatasource {
  Future<void> cacheDailySteps(String userId, StepModel step);
  Future<StepModel?> getLastSavedSteps(String userId);
  Future<List<StepModel>> getweeklyHistory(String userId);
}

class StepLocalDatasourceImpl implements StepLocalDatasource {
  final SharedPreferences sharedPreferences;
  StepLocalDatasourceImpl({required this.sharedPreferences});

  String _cachedStepsKey(String userId) => 'cached_steps_$userId';
  String _historyKey(String userId) => 'steps_history_$userId';

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
  Future<List<StepModel>> getweeklyHistory(String userId) async {
    return [];
  }
}
