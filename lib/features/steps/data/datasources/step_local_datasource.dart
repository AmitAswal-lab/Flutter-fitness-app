import 'dart:convert';

import 'package:fitness_app/features/steps/data/models/step_model.dart';

import 'package:shared_preferences/shared_preferences.dart';

abstract class StepLocalDatasource {
  Future<void> cacheDailySteps(StepModel step);
  Future<StepModel?> getLastSavedSteps();
  Future<List<StepModel>> getweeklyHistory();
}

class StepLocalDatasourceImpl implements StepLocalDatasource {
  final SharedPreferences sharedPreferences;
  StepLocalDatasourceImpl({required this.sharedPreferences});

  static const String cachedStepsKey = 'cached_steps_today';
  static const String historyKey = 'steps_history';

  @override
  Future<void> cacheDailySteps(StepModel stepModel) {
    return sharedPreferences.setString(
      cachedStepsKey,
      json.encode(stepModel.toJson()),
    );
  }

  @override
  Future<StepModel?> getLastSavedSteps() {
    final cachedSteps = sharedPreferences.getString(cachedStepsKey);
    if (cachedSteps != null) {
      return Future.value(StepModel.fromJson(json.decode(cachedSteps)));
    }
    return Future.value(null);
  }

  @override
  Future<List<StepModel>> getweeklyHistory() async {
    return [];
  }
}
