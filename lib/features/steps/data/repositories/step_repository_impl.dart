import 'package:fitness_app/features/steps/data/datasources/pedometer_datasource.dart';
import 'package:fitness_app/features/steps/data/datasources/step_local_datasource.dart';
import 'package:fitness_app/features/steps/data/models/step_model.dart';
import 'package:fitness_app/features/steps/domain/entities/step_record.dart';
import 'package:fitness_app/features/steps/domain/repositories/step_repository.dart';

class StepRepositoryImpl implements StepsRepository {
  final StepLocalDatasource stepLocalDatasource;
  final PedometerDataSource pedometerDatasource;

  StepRepositoryImpl({
    required this.stepLocalDatasource,
    required this.pedometerDatasource,
  });

  int _stepsAtSessionStart = 0;
  bool _isFirstEvent = true;
  String? _currentUserId;

  /// Reset session state when user changes
  void _resetSessionIfNeeded(String userId) {
    if (_currentUserId != userId) {
      _stepsAtSessionStart = 0;
      _isFirstEvent = true;
      _currentUserId = userId;
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Future<StepRecord> getDailySteps(String userId) async {
    final savedSteps = await stepLocalDatasource.getLastSavedSteps(userId);

    if (savedSteps != null && _isToday(savedSteps.timestamp)) {
      return savedSteps;
    }

    return StepRecord(steps: 0, timestamp: DateTime.now());
  }

  @override
  Stream<StepRecord> getStepStream(String userId) async* {
    // Reset session if user changed
    _resetSessionIfNeeded(userId);

    StepRecord currentDailyCount = await getDailySteps(userId);
    int initialSavedSteps = currentDailyCount.steps;

    yield currentDailyCount;

    //Listen to the raw sensor stream
    await for (final sensorEvent in pedometerDatasource.getStepStream()) {
      if (_isFirstEvent) {
        _stepsAtSessionStart = sensorEvent.steps;
        _isFirstEvent = false;
      }

      int stepsWalkedThisSession = sensorEvent.steps - _stepsAtSessionStart;

      int totalStepsToday = initialSavedSteps + stepsWalkedThisSession;

      final updatedRecord = StepRecord(
        steps: totalStepsToday,
        timestamp: DateTime.now(),
      );

      // Save the updated step count to local storage
      await stepLocalDatasource.cacheDailySteps(
        userId,
        StepModel(steps: totalStepsToday, timestamp: updatedRecord.timestamp),
      );

      yield updatedRecord;
    }
  }

  @override
  Future<List<StepRecord>> getWeeklySteps(String userId) async {
    final history = await stepLocalDatasource.getweeklyHistory(userId);
    return history.map((e) => e as StepRecord).toList();
  }
}
