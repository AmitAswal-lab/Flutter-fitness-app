import 'package:fitness_app/features/steps/domain/entities/step_record.dart';

class StepModel extends StepRecord {
  const StepModel({required super.steps, required super.timestamp});

  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
      steps: json['steps'] as int,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'steps': steps, 'timestamp': timestamp};
  }
}
