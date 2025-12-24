import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../models/step_model.dart';
import '../services/step_counter_service.dart';
import 'pedometer_datasource.dart';

/// PedometerDataSource implementation that uses the foreground service
/// for background step counting with accelerometer.
class ForegroundStepDataSource implements PedometerDataSource {
  final StreamController<StepModel> _controller =
      StreamController<StepModel>.broadcast();
  bool _isListening = false;

  @override
  Stream<StepModel> getStepStream() {
    if (!_isListening) {
      _startListening();
    }
    return _controller.stream;
  }

  Future<void> _startListening() async {
    _isListening = true;

    // Initialize communication port
    FlutterForegroundTask.initCommunicationPort();

    // Initialize the service settings
    StepCounterService.init();

    // Request permissions
    await StepCounterService.requestPermissions();

    // Start the foreground service
    await StepCounterService.startService();

    // Emit initial value
    final initialSteps = await StepCounterService.getStepCount();
    _controller.add(StepModel(steps: initialSteps, timestamp: DateTime.now()));

    // Listen for updates from the foreground service
    FlutterForegroundTask.addTaskDataCallback(_onReceiveTaskData);
  }

  void _onReceiveTaskData(Object data) {
    if (data is Map && data.containsKey('steps')) {
      final steps = data['steps'] as int;
      _controller.add(StepModel(steps: steps, timestamp: DateTime.now()));
    }
  }

  void dispose() {
    FlutterForegroundTask.removeTaskDataCallback(_onReceiveTaskData);
    _controller.close();
  }
}
