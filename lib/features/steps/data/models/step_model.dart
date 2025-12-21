import 'package:fitness_app/features/steps/domain/entities/step_record.dart';

class StepModel extends StepRecord {
  final int? lastPedometerValue;

  const StepModel({
    required super.steps,
    required super.timestamp,
    this.lastPedometerValue,
  });

  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
      steps: json['steps'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
      lastPedometerValue: json['lastPedometerValue'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'steps': steps,
      'timestamp': timestamp.toIso8601String(),
      'lastPedometerValue': lastPedometerValue,
    };
  }

  StepRecord toEntity() {
    return StepRecord(steps: steps, timestamp: timestamp);
  }
}
