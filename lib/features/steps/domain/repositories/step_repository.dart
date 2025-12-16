import '../entities/step_record.dart';

abstract class StepsRepository {
  Stream<StepRecord> getStepStream();

  Future<StepRecord> getDailySteps();

  Future<List<StepRecord>> getWeeklySteps();
}
