part of 'steps_bloc.dart';

sealed class StepsEvent extends Equatable {
  const StepsEvent();

  @override
  List<Object> get props => [];
}

class WatchStepsSpeed extends StepsEvent {
  final String userId;
  const WatchStepsSpeed({required this.userId});

  @override
  List<Object> get props => [userId];
}

/// Event to refresh step count from saved data (e.g., on app resume)
class RefreshSteps extends StepsEvent {
  final String userId;
  const RefreshSteps({required this.userId});

  @override
  List<Object> get props => [userId];
}
