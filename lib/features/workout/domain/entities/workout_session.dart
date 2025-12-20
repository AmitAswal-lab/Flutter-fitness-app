import 'package:equatable/equatable.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_template.dart';

/// Represents a completed workout session
class WorkoutSession extends Equatable {
  final String id;
  final String userId;
  final WorkoutTemplate template;
  final DateTime startTime;
  final DateTime? endTime;
  final List<CompletedSet> completedSets;
  final WorkoutSessionStatus status;
  final String? notes;

  const WorkoutSession({
    required this.id,
    required this.userId,
    required this.template,
    required this.startTime,
    this.endTime,
    this.completedSets = const [],
    this.status = WorkoutSessionStatus.inProgress,
    this.notes,
  });

  /// Total duration in minutes
  int? get durationMinutes {
    if (endTime == null) return null;
    return endTime!.difference(startTime).inMinutes;
  }

  /// Check if workout is completed
  bool get isCompleted => status == WorkoutSessionStatus.completed;

  WorkoutSession copyWith({
    DateTime? endTime,
    List<CompletedSet>? completedSets,
    WorkoutSessionStatus? status,
    String? notes,
  }) {
    return WorkoutSession(
      id: id,
      userId: userId,
      template: template,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      completedSets: completedSets ?? this.completedSets,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [id, userId, template, startTime, status];
}

/// A single completed set within a workout session
class CompletedSet extends Equatable {
  final String exerciseId;
  final int setNumber;
  final double? weight; // in kg
  final int? reps;
  final int? durationSeconds;
  final bool isCompleted;

  const CompletedSet({
    required this.exerciseId,
    required this.setNumber,
    this.weight,
    this.reps,
    this.durationSeconds,
    this.isCompleted = false,
  });

  @override
  List<Object?> get props => [exerciseId, setNumber, weight, reps, isCompleted];
}

enum WorkoutSessionStatus { inProgress, paused, completed, abandoned }
