import 'package:fitness_app/features/workout/data/models/exercise_model.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_template.dart';

class WorkoutTemplateModel extends WorkoutTemplate {
  const WorkoutTemplateModel({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    required super.difficulty,
    required super.estimatedMinutes,
    required super.exercises,
    super.imageUrl,
    super.isCustom,
  });

  factory WorkoutTemplateModel.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplateModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: ExerciseCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ExerciseCategory.strength,
      ),
      difficulty: WorkoutDifficulty.values.firstWhere(
        (d) => d.name == json['difficulty'],
        orElse: () => WorkoutDifficulty.beginner,
      ),
      estimatedMinutes: json['estimatedMinutes'] as int,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => WorkoutExerciseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      imageUrl: json['imageUrl'] as String?,
      isCustom: json['isCustom'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'difficulty': difficulty.name,
      'estimatedMinutes': estimatedMinutes,
      'exercises': exercises
          .map((e) => WorkoutExerciseModel.fromEntity(e).toJson())
          .toList(),
      'imageUrl': imageUrl,
      'isCustom': isCustom,
    };
  }

  factory WorkoutTemplateModel.fromEntity(WorkoutTemplate entity) {
    return WorkoutTemplateModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      category: entity.category,
      difficulty: entity.difficulty,
      estimatedMinutes: entity.estimatedMinutes,
      exercises: entity.exercises,
      imageUrl: entity.imageUrl,
      isCustom: entity.isCustom,
    );
  }
}

class WorkoutExerciseModel extends WorkoutExercise {
  const WorkoutExerciseModel({
    required super.exercise,
    required super.sets,
    super.reps,
    super.durationSeconds,
    super.restSeconds,
  });

  factory WorkoutExerciseModel.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseModel(
      exercise: ExerciseModel.fromJson(
        json['exercise'] as Map<String, dynamic>,
      ),
      sets: json['sets'] as int,
      reps: json['reps'] as int? ?? 0,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      restSeconds: json['restSeconds'] as int? ?? 60,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'exercise': ExerciseModel.fromEntity(exercise).toJson(),
      'sets': sets,
      'reps': reps,
      'durationSeconds': durationSeconds,
      'restSeconds': restSeconds,
    };
  }

  factory WorkoutExerciseModel.fromEntity(WorkoutExercise entity) {
    return WorkoutExerciseModel(
      exercise: entity.exercise,
      sets: entity.sets,
      reps: entity.reps,
      durationSeconds: entity.durationSeconds,
      restSeconds: entity.restSeconds,
    );
  }
}
