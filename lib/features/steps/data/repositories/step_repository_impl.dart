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

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Future<StepRecord> getDailySteps(String userId) async {
    final savedSteps = await stepLocalDatasource.getLastSavedSteps(userId);

    if (savedSteps != null) {
      if (_isToday(savedSteps.timestamp)) {
        return savedSteps;
      } else {
        // Archive yesterday's steps before starting new day
        await stepLocalDatasource.saveDailyTotal(
          userId,
          savedSteps.timestamp,
          savedSteps.steps,
        );
      }
    }

    return StepRecord(steps: 0, timestamp: DateTime.now());
  }

  @override
  Stream<StepRecord> getStepStream(String userId) async* {
    // Load saved state
    final savedData = await stepLocalDatasource.getLastSavedSteps(userId);

    // Check if we need to archive yesterday's data
    if (savedData != null && !_isToday(savedData.timestamp)) {
      await stepLocalDatasource.saveDailyTotal(
        userId,
        savedData.timestamp,
        savedData.steps,
      );
    }

    // Yield initial value
    final initialSteps = savedData != null && _isToday(savedData.timestamp)
        ? savedData.steps
        : 0;
    yield StepRecord(steps: initialSteps, timestamp: DateTime.now());

    // Listen to the foreground service stream
    // The foreground service sends the TOTAL daily step count directly
    // No baseline calculation needed - just pass through the values
    await for (final sensorEvent in pedometerDatasource.getStepStream()) {
      final totalStepsToday = sensorEvent.steps;

      final updatedRecord = StepRecord(
        steps: totalStepsToday,
        timestamp: DateTime.now(),
      );

      // Cache the current total
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
