import 'package:equatable/equatable.dart';

/// Represents an exercise that can be performed in a workout
class Exercise extends Equatable {
  final String id;
  final String name;
  final String description;
  final ExerciseCategory category;
  final List<MuscleGroup> muscleGroups;
  final String? imageUrl;
  final String? videoUrl;
  final bool isTimeBased; // true = duration, false = reps

  const Exercise({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.muscleGroups,
    this.imageUrl,
    this.videoUrl,
    this.isTimeBased = false,
  });

  @override
  List<Object?> get props => [id, name, category, muscleGroups, isTimeBased];
}

enum ExerciseCategory { strength, cardio, hiit, yoga, stretching, calisthenics }

enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  forearms,
  core,
  quadriceps,
  hamstrings,
  glutes,
  calves,
  fullBody,
}

extension ExerciseCategoryExtension on ExerciseCategory {
  String get displayName {
    switch (this) {
      case ExerciseCategory.strength:
        return 'Strength';
      case ExerciseCategory.cardio:
        return 'Cardio';
      case ExerciseCategory.hiit:
        return 'HIIT';
      case ExerciseCategory.yoga:
        return 'Yoga';
      case ExerciseCategory.stretching:
        return 'Stretching';
      case ExerciseCategory.calisthenics:
        return 'Calisthenics';
    }
  }

  String get icon {
    switch (this) {
      case ExerciseCategory.strength:
        return '🏋️';
      case ExerciseCategory.cardio:
        return '🏃';
      case ExerciseCategory.hiit:
        return '⚡';
      case ExerciseCategory.yoga:
        return '🧘';
      case ExerciseCategory.stretching:
        return '🤸';
      case ExerciseCategory.calisthenics:
        return '💪';
    }
  }
}

extension MuscleGroupExtension on MuscleGroup {
  String get displayName {
    switch (this) {
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.shoulders:
        return 'Shoulders';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.forearms:
        return 'Forearms';
      case MuscleGroup.core:
        return 'Core';
      case MuscleGroup.quadriceps:
        return 'Quadriceps';
      case MuscleGroup.hamstrings:
        return 'Hamstrings';
      case MuscleGroup.glutes:
        return 'Glutes';
      case MuscleGroup.calves:
        return 'Calves';
      case MuscleGroup.fullBody:
        return 'Full Body';
    }
  }
}
