part of 'steps_bloc.dart';

sealed class StepsState extends Equatable {
  const StepsState();

  @override
  List<Object> get props => [];
}

final class StepsInitial extends StepsState {}

final class StepsLoading extends StepsState {}

final class StepsLoadSuccess extends StepsState {
  final StepRecord stepRecord;

  const StepsLoadSuccess({required this.stepRecord});

  @override
  List<Object> get props => [stepRecord];
}

final class StepsError extends StepsState {
  final String message;

  const StepsError(this.message);

  @override
  List<Object> get props => [message];
}
