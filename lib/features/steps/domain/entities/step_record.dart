import 'package:equatable/equatable.dart';

class StepRecord extends Equatable {
  final int steps;
  final DateTime timestamp;

  const StepRecord({required this.steps, required this.timestamp});

  @override
  List<Object?> get props => [steps, timestamp];
}
