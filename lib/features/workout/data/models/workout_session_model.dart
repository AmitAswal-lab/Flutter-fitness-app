import 'package:fitness_app/features/workout/domain/entities/workout_session.dart';
import 'package:fitness_app/features/workout/data/models/workout_template_model.dart';

class WorkoutSessionModel extends WorkoutSession {
  const WorkoutSessionModel({
    required super.id,
    required super.userId,
    required super.template,
    required super.startTime,
    super.endTime,
    required super.completedSets,
    required super.status,
    super.notes,
  });

  factory WorkoutSessionModel.fromJson(Map<String, dynamic> json) {
    return WorkoutSessionModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      template: WorkoutTemplateModel.fromJson(
        json['template'] as Map<String, dynamic>,
      ),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      completedSets: (json['completedSets'] as List<dynamic>)
          .map((e) => CompletedSetModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      status: WorkoutSessionStatus.values.firstWhere(
        (s) => s.name == json['status'],
      ),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'template': WorkoutTemplateModel.fromEntity(template).toJson(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'completedSets': completedSets
          .map((s) => CompletedSetModel.fromEntity(s).toJson())
          .toList(),
      'status': status.name,
      'notes': notes,
    };
  }

  static WorkoutSessionModel fromEntity(WorkoutSession session) {
    return WorkoutSessionModel(
      id: session.id,
      userId: session.userId,
      template: session.template,
      startTime: session.startTime,
      endTime: session.endTime,
      completedSets: session.completedSets,
      status: session.status,
      notes: session.notes,
    );
  }
}

class CompletedSetModel extends CompletedSet {
  const CompletedSetModel({
    required super.exerciseId,
    required super.setNumber,
    super.weight,
    super.reps,
    super.durationSeconds,
    required super.isCompleted,
  });

  factory CompletedSetModel.fromJson(Map<String, dynamic> json) {
    return CompletedSetModel(
      exerciseId: json['exerciseId'] as String,
      setNumber: json['setNumber'] as int,
      weight: json['weight'] != null
          ? (json['weight'] as num).toDouble()
          : null,
      reps: json['reps'] as int?,
      durationSeconds: json['durationSeconds'] as int?,
      isCompleted: json['isCompleted'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exerciseId': exerciseId,
      'setNumber': setNumber,
      'weight': weight,
      'reps': reps,
      'durationSeconds': durationSeconds,
      'isCompleted': isCompleted,
    };
  }

  static CompletedSetModel fromEntity(CompletedSet set) {
    return CompletedSetModel(
      exerciseId: set.exerciseId,
      setNumber: set.setNumber,
      weight: set.weight,
      reps: set.reps,
      durationSeconds: set.durationSeconds,
      isCompleted: set.isCompleted,
    );
  }
}
