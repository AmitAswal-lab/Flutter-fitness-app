import 'package:fitness_app/features/workout/domain/entities/exercise.dart';

class ExerciseModel extends Exercise {
  const ExerciseModel({
    required super.id,
    required super.name,
    required super.description,
    required super.category,
    required super.muscleGroups,
    super.imageUrl,
    super.videoUrl,
    super.isTimeBased,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: ExerciseCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ExerciseCategory.strength,
      ),
      muscleGroups: (json['muscleGroups'] as List<dynamic>)
          .map(
            (m) => MuscleGroup.values.firstWhere(
              (mg) => mg.name == m,
              orElse: () => MuscleGroup.fullBody,
            ),
          )
          .toList(),
      imageUrl: json['imageUrl'] as String?,
      videoUrl: json['videoUrl'] as String?,
      isTimeBased: json['isTimeBased'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category.name,
      'muscleGroups': muscleGroups.map((m) => m.name).toList(),
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'isTimeBased': isTimeBased,
    };
  }

  factory ExerciseModel.fromEntity(Exercise entity) {
    return ExerciseModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      category: entity.category,
      muscleGroups: entity.muscleGroups,
      imageUrl: entity.imageUrl,
      videoUrl: entity.videoUrl,
      isTimeBased: entity.isTimeBased,
    );
  }
}
