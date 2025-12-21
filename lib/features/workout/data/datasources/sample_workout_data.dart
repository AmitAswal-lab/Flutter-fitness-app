import 'package:fitness_app/features/workout/domain/entities/exercise.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_template.dart';

/// Sample exercises for the workout library
class SampleWorkoutData {
  static final List<Exercise> exercises = [
    // Chest exercises
    const Exercise(
      id: 'push_ups',
      name: 'Push-Ups',
      description:
          'Classic bodyweight exercise targeting chest, shoulders, and triceps.',
      category: ExerciseCategory.calisthenics,
      muscleGroups: [
        MuscleGroup.chest,
        MuscleGroup.shoulders,
        MuscleGroup.triceps,
      ],
    ),
    const Exercise(
      id: 'bench_press',
      name: 'Bench Press',
      description: 'Compound exercise for chest development using a barbell.',
      category: ExerciseCategory.strength,
      muscleGroups: [
        MuscleGroup.chest,
        MuscleGroup.shoulders,
        MuscleGroup.triceps,
      ],
    ),
    const Exercise(
      id: 'dumbbell_fly',
      name: 'Dumbbell Fly',
      description: 'Isolation exercise for chest using dumbbells.',
      category: ExerciseCategory.strength,
      muscleGroups: [MuscleGroup.chest],
    ),

    // Back exercises
    const Exercise(
      id: 'pull_ups',
      name: 'Pull-Ups',
      description: 'Bodyweight exercise for back and biceps.',
      category: ExerciseCategory.calisthenics,
      muscleGroups: [MuscleGroup.back, MuscleGroup.biceps],
    ),
    const Exercise(
      id: 'bent_over_row',
      name: 'Bent Over Row',
      description: 'Compound back exercise with barbell or dumbbells.',
      category: ExerciseCategory.strength,
      muscleGroups: [MuscleGroup.back, MuscleGroup.biceps],
    ),
    const Exercise(
      id: 'lat_pulldown',
      name: 'Lat Pulldown',
      description: 'Cable machine exercise targeting the lats.',
      category: ExerciseCategory.strength,
      muscleGroups: [MuscleGroup.back],
    ),

    // Leg exercises
    const Exercise(
      id: 'squats',
      name: 'Squats',
      description: 'Fundamental compound leg exercise.',
      category: ExerciseCategory.strength,
      muscleGroups: [
        MuscleGroup.quadriceps,
        MuscleGroup.glutes,
        MuscleGroup.hamstrings,
      ],
    ),
    const Exercise(
      id: 'lunges',
      name: 'Lunges',
      description: 'Unilateral leg exercise for balance and strength.',
      category: ExerciseCategory.strength,
      muscleGroups: [MuscleGroup.quadriceps, MuscleGroup.glutes],
    ),
    const Exercise(
      id: 'deadlift',
      name: 'Deadlift',
      description: 'Compound exercise for posterior chain.',
      category: ExerciseCategory.strength,
      muscleGroups: [
        MuscleGroup.back,
        MuscleGroup.hamstrings,
        MuscleGroup.glutes,
      ],
    ),

    // Core exercises
    const Exercise(
      id: 'plank',
      name: 'Plank',
      description: 'Isometric core exercise.',
      category: ExerciseCategory.calisthenics,
      muscleGroups: [MuscleGroup.core],
      isTimeBased: true,
    ),
    const Exercise(
      id: 'crunches',
      name: 'Crunches',
      description: 'Basic abdominal exercise.',
      category: ExerciseCategory.calisthenics,
      muscleGroups: [MuscleGroup.core],
    ),
    const Exercise(
      id: 'russian_twist',
      name: 'Russian Twist',
      description: 'Rotational core exercise.',
      category: ExerciseCategory.calisthenics,
      muscleGroups: [MuscleGroup.core],
    ),

    // Cardio exercises
    const Exercise(
      id: 'jumping_jacks',
      name: 'Jumping Jacks',
      description: 'Full body cardio exercise.',
      category: ExerciseCategory.cardio,
      muscleGroups: [MuscleGroup.fullBody],
      isTimeBased: true,
    ),
    const Exercise(
      id: 'burpees',
      name: 'Burpees',
      description: 'High-intensity full body exercise.',
      category: ExerciseCategory.hiit,
      muscleGroups: [MuscleGroup.fullBody],
    ),
    const Exercise(
      id: 'mountain_climbers',
      name: 'Mountain Climbers',
      description: 'Cardio exercise targeting core and legs.',
      category: ExerciseCategory.hiit,
      muscleGroups: [MuscleGroup.core, MuscleGroup.quadriceps],
      isTimeBased: true,
    ),

    // Shoulder exercises
    const Exercise(
      id: 'shoulder_press',
      name: 'Shoulder Press',
      description: 'Overhead pressing movement for shoulders.',
      category: ExerciseCategory.strength,
      muscleGroups: [MuscleGroup.shoulders, MuscleGroup.triceps],
    ),
    const Exercise(
      id: 'lateral_raise',
      name: 'Lateral Raise',
      description: 'Isolation exercise for lateral deltoids.',
      category: ExerciseCategory.strength,
      muscleGroups: [MuscleGroup.shoulders],
    ),

    // Arm exercises
    const Exercise(
      id: 'bicep_curl',
      name: 'Bicep Curl',
      description: 'Isolation exercise for biceps.',
      category: ExerciseCategory.strength,
      muscleGroups: [MuscleGroup.biceps],
    ),
    const Exercise(
      id: 'tricep_dips',
      name: 'Tricep Dips',
      description: 'Bodyweight exercise for triceps.',
      category: ExerciseCategory.calisthenics,
      muscleGroups: [MuscleGroup.triceps],
    ),
  ];

  static Exercise getExerciseById(String id) {
    return exercises.firstWhere(
      (e) => e.id == id,
      orElse: () => exercises.first,
    );
  }

  static final List<WorkoutTemplate> workoutTemplates = [
    // Beginner Full Body
    WorkoutTemplate(
      id: 'beginner_full_body',
      name: 'Beginner Full Body',
      description: 'A great starting workout covering all major muscle groups.',
      category: ExerciseCategory.strength,
      difficulty: WorkoutDifficulty.beginner,
      estimatedMinutes: 30,
      exercises: [
        WorkoutExercise(exercise: getExerciseById('squats'), sets: 3, reps: 12),
        WorkoutExercise(
          exercise: getExerciseById('push_ups'),
          sets: 3,
          reps: 10,
        ),
        WorkoutExercise(
          exercise: getExerciseById('bent_over_row'),
          sets: 3,
          reps: 12,
        ),
        WorkoutExercise(
          exercise: getExerciseById('plank'),
          sets: 3,
          durationSeconds: 30,
        ),
      ],
    ),

    // Upper Body Strength
    WorkoutTemplate(
      id: 'upper_body_strength',
      name: 'Upper Body Strength',
      description: 'Focus on chest, back, shoulders, and arms.',
      category: ExerciseCategory.strength,
      difficulty: WorkoutDifficulty.intermediate,
      estimatedMinutes: 45,
      exercises: [
        WorkoutExercise(
          exercise: getExerciseById('bench_press'),
          sets: 3,
          reps: 8,
        ),
        WorkoutExercise(
          exercise: getExerciseById('bent_over_row'),
          sets: 3,
          reps: 10,
        ),
        WorkoutExercise(
          exercise: getExerciseById('shoulder_press'),
          sets: 3,
          reps: 10,
        ),
        WorkoutExercise(
          exercise: getExerciseById('bicep_curl'),
          sets: 3,
          reps: 12,
        ),
        WorkoutExercise(
          exercise: getExerciseById('tricep_dips'),
          sets: 3,
          reps: 12,
        ),
      ],
    ),

    // Lower Body Power
    WorkoutTemplate(
      id: 'lower_body_power',
      name: 'Lower Body Power',
      description: 'Build strong legs and glutes.',
      category: ExerciseCategory.strength,
      difficulty: WorkoutDifficulty.intermediate,
      estimatedMinutes: 40,
      exercises: [
        WorkoutExercise(exercise: getExerciseById('squats'), sets: 4, reps: 10),
        WorkoutExercise(
          exercise: getExerciseById('deadlift'),
          sets: 4,
          reps: 8,
        ),
        WorkoutExercise(exercise: getExerciseById('lunges'), sets: 3, reps: 12),
      ],
    ),

    // HIIT Cardio Blast
    WorkoutTemplate(
      id: 'hiit_cardio',
      name: 'HIIT Cardio Blast',
      description: 'High intensity interval training for fat burn.',
      category: ExerciseCategory.hiit,
      difficulty: WorkoutDifficulty.advanced,
      estimatedMinutes: 20,
      exercises: [
        WorkoutExercise(
          exercise: getExerciseById('burpees'),
          sets: 3,
          reps: 15,
          restSeconds: 30,
        ),
        WorkoutExercise(
          exercise: getExerciseById('mountain_climbers'),
          sets: 3,
          durationSeconds: 45,
          restSeconds: 15,
        ),
        WorkoutExercise(
          exercise: getExerciseById('jumping_jacks'),
          sets: 3,
          durationSeconds: 60,
          restSeconds: 15,
        ),
      ],
    ),

    // Core Crusher
    WorkoutTemplate(
      id: 'core_crusher',
      name: 'Core Crusher',
      description: 'Intense core workout for a strong midsection.',
      category: ExerciseCategory.calisthenics,
      difficulty: WorkoutDifficulty.intermediate,
      estimatedMinutes: 20,
      exercises: [
        WorkoutExercise(
          exercise: getExerciseById('plank'),
          sets: 3,
          durationSeconds: 60,
        ),
        WorkoutExercise(
          exercise: getExerciseById('crunches'),
          sets: 3,
          reps: 20,
        ),
        WorkoutExercise(
          exercise: getExerciseById('russian_twist'),
          sets: 3,
          reps: 20,
        ),
        WorkoutExercise(
          exercise: getExerciseById('mountain_climbers'),
          sets: 3,
          durationSeconds: 30,
        ),
      ],
    ),

    // Quick Morning Routine
    WorkoutTemplate(
      id: 'quick_morning',
      name: 'Quick Morning Routine',
      description: 'Energize your day with this quick full-body workout.',
      category: ExerciseCategory.calisthenics,
      difficulty: WorkoutDifficulty.beginner,
      estimatedMinutes: 15,
      exercises: [
        WorkoutExercise(
          exercise: getExerciseById('jumping_jacks'),
          sets: 2,
          durationSeconds: 60,
        ),
        WorkoutExercise(
          exercise: getExerciseById('push_ups'),
          sets: 2,
          reps: 10,
        ),
        WorkoutExercise(exercise: getExerciseById('squats'), sets: 2, reps: 15),
        WorkoutExercise(
          exercise: getExerciseById('plank'),
          sets: 2,
          durationSeconds: 30,
        ),
      ],
    ),
  ];
}
