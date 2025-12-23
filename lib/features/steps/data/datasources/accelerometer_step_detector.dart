import 'dart:async';
import 'dart:math';

import 'package:sensors_plus/sensors_plus.dart';

import '../models/step_model.dart';
import 'pedometer_datasource.dart';

/// Accelerometer-based step detector using peak detection algorithm.
/// More accurate than TYPE_STEP_COUNTER on some Android devices.
class AccelerometerStepDetector implements PedometerDataSource {
  // Algorithm parameters (tuned for walking detection)
  static const double _stepThreshold = 12.0; // Acceleration magnitude threshold
  static const int _minStepIntervalMs =
      250; // Min time between steps (250ms = 4 steps/sec max)
  static const int _maxStepIntervalMs =
      2000; // Max time between steps (0.5 steps/sec min)

  int _totalSteps = 0;
  DateTime? _lastStepTime;
  double _lastMagnitude = 0;
  bool _isPeakDetected = false;

  final StreamController<StepModel> _controller =
      StreamController<StepModel>.broadcast();
  StreamSubscription? _accelerometerSubscription;

  @override
  Stream<StepModel> getStepStream() {
    // Start listening to accelerometer if not already
    _accelerometerSubscription ??= accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 50), // 20Hz sampling
    ).listen(_processAccelerometerEvent);

    // Emit initial value
    Future.delayed(const Duration(milliseconds: 100), () {
      _controller.add(StepModel(steps: _totalSteps, timestamp: DateTime.now()));
    });

    return _controller.stream;
  }

  void _processAccelerometerEvent(AccelerometerEvent event) {
    // Calculate acceleration magnitude (removing gravity is optional)
    // Using raw magnitude works well for step detection
    final magnitude = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    // Simple peak detection algorithm
    // A step is detected when:
    // 1. Current magnitude exceeds threshold
    // 2. Previous magnitude was below threshold (rising edge)
    // 3. Enough time has passed since last step

    final now = DateTime.now();
    final timeSinceLastStep = _lastStepTime != null
        ? now.difference(_lastStepTime!).inMilliseconds
        : _maxStepIntervalMs;

    // Detect rising edge crossing threshold
    final isAboveThreshold = magnitude > _stepThreshold;
    final wasAboveThreshold = _lastMagnitude > _stepThreshold;

    if (isAboveThreshold && !wasAboveThreshold && !_isPeakDetected) {
      // Rising edge detected
      _isPeakDetected = true;
    }

    if (!isAboveThreshold && _isPeakDetected) {
      // Falling edge - peak complete
      _isPeakDetected = false;

      // Check timing constraints
      if (timeSinceLastStep >= _minStepIntervalMs) {
        // Valid step detected!
        _totalSteps++;
        _lastStepTime = now;

        _controller.add(StepModel(steps: _totalSteps, timestamp: now));
      }
    }

    _lastMagnitude = magnitude;
  }

  void dispose() {
    _accelerometerSubscription?.cancel();
    _controller.close();
  }
}
