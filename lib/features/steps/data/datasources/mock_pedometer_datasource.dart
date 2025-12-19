import 'dart:async';

import '../models/step_model.dart';
import 'pedometer_datasource.dart';

/// Mock implementation of PedometerDataSource for simulator testing.
/// Simulates step counting by emitting fake step data.
class MockPedometerDataSource implements PedometerDataSource {
  int _currentSteps = 0;
  Timer? _timer;
  final StreamController<StepModel> _controller =
      StreamController<StepModel>.broadcast();

  @override
  Stream<StepModel> getStepStream() {
    // Start simulation if not already running
    _timer ??= Timer.periodic(const Duration(seconds: 2), (_) {
      // Simulate walking: add 3-8 steps every 2 seconds
      _currentSteps += 3 + DateTime.now().second % 6;
      _controller.add(
        StepModel(steps: _currentSteps, timestamp: DateTime.now()),
      );
    });

    // Emit initial value
    Future.delayed(const Duration(milliseconds: 500), () {
      _controller.add(
        StepModel(steps: _currentSteps, timestamp: DateTime.now()),
      );
    });

    return _controller.stream;
  }

  void dispose() {
    _timer?.cancel();
    _controller.close();
  }
}
