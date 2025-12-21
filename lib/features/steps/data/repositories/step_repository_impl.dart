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

    int savedSteps = 0;
    int? lastSavedPedometerValue;

    if (savedData != null && _isToday(savedData.timestamp)) {
      savedSteps = savedData.steps;
      lastSavedPedometerValue = savedData.lastPedometerValue;
    }

    // Yield initial saved value
    yield StepRecord(steps: savedSteps, timestamp: DateTime.now());

    bool isFirstEvent = true;
    int sessionBaseline = 0;

    // Listen to the raw sensor stream
    await for (final sensorEvent in pedometerDatasource.getStepStream()) {
      final currentPedometerValue = sensorEvent.steps;

      if (isFirstEvent) {
        isFirstEvent = false;

        // If we have a saved pedometer value from before, calculate background steps
        if (lastSavedPedometerValue != null) {
          int backgroundSteps = currentPedometerValue - lastSavedPedometerValue;

          // Sanity check: if negative (pedometer reset) or unreasonably large, ignore
          if (backgroundSteps < 0 || backgroundSteps > 50000) {
            backgroundSteps = 0;
          }

          // Add background steps to saved steps
          savedSteps += backgroundSteps;
        }

        // Set baseline for this session
        sessionBaseline = currentPedometerValue;

        // Yield the updated total (saved + background steps)
        final updatedRecord = StepRecord(
          steps: savedSteps,
          timestamp: DateTime.now(),
        );

        await stepLocalDatasource.cacheDailySteps(
          userId,
          StepModel(
            steps: savedSteps,
            timestamp: updatedRecord.timestamp,
            lastPedometerValue: currentPedometerValue,
          ),
        );

        yield updatedRecord;
        continue;
      }

      // Calculate steps walked in this active session
      int sessionSteps = currentPedometerValue - sessionBaseline;

      // Sanity check for negative values (pedometer reset mid-session)
      if (sessionSteps < 0) {
        sessionBaseline = currentPedometerValue;
        sessionSteps = 0;
      }

      // Total = saved steps + session steps
      int totalStepsToday = savedSteps + sessionSteps;

      final updatedRecord = StepRecord(
        steps: totalStepsToday,
        timestamp: DateTime.now(),
      );

      // Save with current pedometer value for future background calculation
      await stepLocalDatasource.cacheDailySteps(
        userId,
        StepModel(
          steps: totalStepsToday,
          timestamp: updatedRecord.timestamp,
          lastPedometerValue: currentPedometerValue,
        ),
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
