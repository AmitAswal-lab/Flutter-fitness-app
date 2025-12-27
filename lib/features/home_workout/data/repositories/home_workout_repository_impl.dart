import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_template.dart';
import 'package:fitness_app/features/home_workout/domain/repositories/home_workout_repository.dart';
import 'package:fpdart/fpdart.dart';

class HomeWorkoutRepositoryImpl implements HomeWorkoutRepository {
  // Mock in-memory storage for now
  WorkoutTemplate _currentWorkout = WorkoutTemplate(
    id: 'full_body_home',
    name: 'Full Body Workout',
    description: 'A comprehensive full body workout you can do at home.',
    category: ExerciseCategory.strength,
    difficulty: WorkoutDifficulty.beginner,
    estimatedMinutes: 20,
    exercises: [
      WorkoutExercise(
        exercise: Exercise(
          id: 'ex_crunches',
          name: 'Abdominal Crunches',
          description:
              'Lie on your back and lift your shoulders off the floor.',
          category: ExerciseCategory.strength,
          muscleGroups: [MuscleGroup.core],
          imageUrl: 'assets/exercises/crunches.png',
        ),
        sets: 3,
        reps: 10,
      ),
      WorkoutExercise(
        exercise: Exercise(
          id: 'ex_russian_twist',
          name: 'Russian Twist',
          description:
              'Sit on the floor and twist your torso from side to side.',
          category: ExerciseCategory.strength,
          muscleGroups: [MuscleGroup.core],
          imageUrl: 'assets/exercises/russian_twist.png',
        ),
        sets: 3,
        reps: 12,
      ),
      WorkoutExercise(
        exercise: Exercise(
          id: 'ex_mountain_climber',
          name: 'Mountain Climber',
          description:
              'Start in a plank and bring your knees to your chest alternately.',
          category: ExerciseCategory.hiit,
          muscleGroups: [MuscleGroup.core, MuscleGroup.fullBody],
          imageUrl: 'assets/exercises/mountain_climber.png',
        ),
        sets: 3,
        reps: 15,
      ),
      WorkoutExercise(
        exercise: Exercise(
          id: 'ex_heel_touch',
          name: 'Heel Touch',
          description: 'Lie on your back and touch your heels alternately.',
          category: ExerciseCategory.strength,
          muscleGroups: [MuscleGroup.core],
          imageUrl: 'assets/exercises/heel_touch.png',
        ),
        sets: 3,
        reps: 16,
      ),
      WorkoutExercise(
        exercise: Exercise(
          id: 'ex_leg_raises',
          name: 'Leg Raises',
          description:
              'Lie on your back and raise your legs until they are vertical.',
          category: ExerciseCategory.strength,
          muscleGroups: [MuscleGroup.core, MuscleGroup.glutes],
          imageUrl: 'assets/exercises/leg_raises.png',
        ),
        sets: 3,
        reps: 12,
      ),
      WorkoutExercise(
        exercise: Exercise(
          id: 'ex_plank',
          name: 'Plank',
          description:
              'Hold a push-up position with your weight on your forearms.',
          category: ExerciseCategory.strength,
          muscleGroups: [MuscleGroup.core],
          isTimeBased: true,
          imageUrl: 'assets/exercises/plank.png',
        ),
        sets: 3,
        durationSeconds: 30,
      ),
    ],
  );

  @override
  Future<Either<Failure, WorkoutTemplate>> getFullBodyWorkout() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return Right(_currentWorkout);
  }

  @override
  Future<Either<Failure, void>> updateWorkout(WorkoutTemplate workout) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    _currentWorkout = workout;
    return const Right(null);
  }
}
