import '../entities/step_record.dart';

abstract class StepsRepository {
  Stream<StepRecord> getStepStream(String userId);

  Future<StepRecord> getDailySteps(String userId);

  Future<List<StepRecord>> getWeeklySteps(String userId);
}
