import 'package:fitness_app/features/steps/domain/entities/step_record.dart';
import 'package:fitness_app/features/steps/domain/repositories/step_repository.dart';

class GetDailySteps {
  final StepsRepository repository;
  const GetDailySteps(this.repository);

  Future<StepRecord> call() {
    return repository.getDailySteps();
  }
}
