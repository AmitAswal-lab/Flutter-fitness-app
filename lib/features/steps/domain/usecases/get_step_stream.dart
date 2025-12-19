import 'package:fitness_app/features/steps/domain/entities/step_record.dart';
import 'package:fitness_app/features/steps/domain/repositories/step_repository.dart';

class GetStepStream {
  final StepsRepository repository;

  GetStepStream(this.repository);

  Stream<StepRecord> call(String userId) {
    return repository.getStepStream(userId);
  }
}
