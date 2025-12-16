import 'package:pedometer/pedometer.dart';
import '../models/step_model.dart';

abstract class PedometerDataSource {
  Stream<StepModel> getStepStream();
}

class PedometerDataSourceImpl implements PedometerDataSource {
  @override
  Stream<StepModel> getStepStream() {
    return Pedometer.stepCountStream.map((StepCount event) {
      return StepModel(steps: event.steps, timestamp: event.timeStamp);
    });
  }
}
