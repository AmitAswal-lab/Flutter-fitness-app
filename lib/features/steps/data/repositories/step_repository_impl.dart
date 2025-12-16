import 'package:fitness_app/features/steps/data/datasources/pedometer_datasource.dart';
import 'package:fitness_app/features/steps/data/datasources/step_local_datasource.dart';
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

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Future<StepRecord> getDailySteps() async {
    final savedSteps = await stepLocalDatasource.getLastSavedSteps();

    if (savedSteps != null && _isToday(savedSteps.timestamp)) {
      return savedSteps;
    }

    return StepRecord(steps: 0, timestamp: DateTime.now());
  }

  @override
  Stream<StepRecord> getStepStream() async* {
    StepRecord currentDailyCount = await getDailySteps();
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

      yield updatedRecord;
    }
  }

  @override
  Future<List<StepRecord>> getWeeklySteps() async {
    final history = await stepLocalDatasource.getweeklyHistory();
    return history.map((e) => e as StepRecord).toList();
  }
}
