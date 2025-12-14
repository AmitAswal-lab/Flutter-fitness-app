import 'package:equatable/equatable.dart';

class StepRecord extends Equatable {
  final int steps;
  final DateTime date;

  const StepRecord({required this.steps, required this.date});

  @override
  List<Object?> get props => [steps, date];
}
