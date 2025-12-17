part of 'steps_bloc.dart';

sealed class StepsState extends Equatable {
  const StepsState();
  
  @override
  List<Object> get props => [];
}

final class StepsInitial extends StepsState {}
