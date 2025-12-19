import 'package:fitness_app/features/steps/domain/entities/step_record.dart';
import 'package:fitness_app/features/steps/domain/repositories/step_repository.dart';

class GetWeeklySteps {
  final StepsRepository repository;
  const GetWeeklySteps(this.repository);

  Future<List<StepRecord>> call(String userId) {
    return repository.getWeeklySteps(userId);
  }
}
