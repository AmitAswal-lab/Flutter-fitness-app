import 'package:fitness_app/features/steps/domain/entities/step_record.dart';
import 'package:fitness_app/features/steps/domain/usecases/get_step_stream.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'steps_event.dart';
part 'steps_state.dart';

class StepsBloc extends Bloc<StepsEvent, StepsState> {
  final GetStepStream getStepStream;

  StepsBloc({required this.getStepStream}) : super(StepsInitial()) {
    on<WatchStepsSpeed>(_watchStepsSpeed);
    on<RefreshSteps>(_refreshSteps);
  }

  Future<void> _watchStepsSpeed(
    WatchStepsSpeed event,
    Emitter<StepsState> emit,
  ) async {
    emit(StepsLoading());
    try {
      await emit.forEach(
        getStepStream(event.userId),
        onData: (stepRecord) => StepsLoadSuccess(stepRecord: stepRecord),
        onError: (error, stackTrace) => StepsError(error.toString()),
      );
    } catch (e) {
      emit(StepsError(e.toString()));
    }
  }

  /// Refresh steps by re-fetching from the stream (picks up saved data)
  Future<void> _refreshSteps(
    RefreshSteps event,
    Emitter<StepsState> emit,
  ) async {
    // Restart the stream to pick up latest saved data
    try {
      await emit.forEach(
        getStepStream(event.userId),
        onData: (stepRecord) => StepsLoadSuccess(stepRecord: stepRecord),
        onError: (error, stackTrace) => StepsError(error.toString()),
      );
    } catch (e) {
      emit(StepsError(e.toString()));
    }
  }
}
