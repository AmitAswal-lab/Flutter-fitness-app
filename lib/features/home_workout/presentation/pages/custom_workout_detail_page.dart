import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/core/data/exercise_repository.dart';
import 'package:fitness_app/core/services/custom_workout_service.dart';
import 'package:fitness_app/features/home_workout/presentation/bloc/active_home_workout_bloc.dart';
import 'package:fitness_app/features/home_workout/presentation/pages/active_home_workout_page.dart';
import 'package:fitness_app/features/home_workout/presentation/pages/create_workout_page.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_template.dart';
import 'package:fitness_app/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Page to preview and start a custom workout
class CustomWorkoutDetailPage extends StatefulWidget {
  final CustomWorkout workout;

  const CustomWorkoutDetailPage({super.key, required this.workout});

  @override
  State<CustomWorkoutDetailPage> createState() =>
      _CustomWorkoutDetailPageState();
}

class _CustomWorkoutDetailPageState extends State<CustomWorkoutDetailPage> {
  late CustomWorkout _workout;

  @override
  void initState() {
    super.initState();
    _workout = widget.workout;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          _workout.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context, _workout != widget.workout),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.textPrimary),
            onPressed: _editWorkout,
            tooltip: 'Edit Workout',
          ),
        ],
      ),
      body: Column(
        children: [
          // Workout info header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard(
                  icon: Icons.fitness_center,
                  value: '${_workout.exercises.length}',
                  label: 'Exercises',
                ),
                _buildStatCard(
                  icon: Icons.timer,
                  value: '${_workout.totalMinutes}',
                  label: 'Minutes',
                ),
                _buildStatCard(
                  icon: Icons.speed,
                  value: _workout.difficulty,
                  label: 'Level',
                ),
              ],
            ),
          ),

          // Description
          if (_workout.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _workout.description,
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),

          const SizedBox(height: 16),

          // Exercise list header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Exercises',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${_workout.exercises.length} total',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Exercise list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _workout.exercises.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final exercise = _workout.exercises[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    exercise.exerciseName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    exercise.isTimeBased
                        ? '${exercise.durationSeconds}s'
                        : '${exercise.reps} reps',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  trailing: Text(
                    '${exercise.restSeconds}s rest',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),

          // Start button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                onPressed: () => _startWorkout(context),
                child: const Text(
                  'START WORKOUT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.success, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _editWorkout() async {
    final result = await Navigator.push<CustomWorkout>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateWorkoutPage(existingWorkout: _workout),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _workout = result;
      });
    }
  }

  void _startWorkout(BuildContext context) {
    // Convert CustomWorkout to WorkoutTemplate
    final template = _convertToTemplate();

    if (template == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Could not load workout exercises'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              sl<ActiveHomeWorkoutBloc>()..add(StartWorkout(template)),
          child: const ActiveHomeWorkoutPage(),
        ),
      ),
    );
  }

  WorkoutTemplate? _convertToTemplate() {
    final repo = ExerciseRepository();
    final workoutExercises = <WorkoutExercise>[];

    for (final customEx in _workout.exercises) {
      // Find the exercise from our database
      final exercise = repo.getById(customEx.exerciseId);

      if (exercise == null) {
        // Create a minimal exercise if not found (shouldn't happen normally)
        final fallbackExercise = Exercise(
          id: customEx.exerciseId,
          name: customEx.exerciseName,
          description: '',
          category: _parseCategory(customEx.category),
          muscleGroups: [],
          isTimeBased: customEx.isTimeBased,
        );

        workoutExercises.add(
          WorkoutExercise(
            exercise: fallbackExercise,
            sets: 1,
            reps: customEx.reps,
            durationSeconds: customEx.durationSeconds,
            restSeconds: customEx.restSeconds,
          ),
        );
      } else {
        workoutExercises.add(
          WorkoutExercise(
            exercise: exercise,
            sets: 1,
            reps: customEx.reps,
            durationSeconds: customEx.durationSeconds,
            restSeconds: customEx.restSeconds,
          ),
        );
      }
    }

    return WorkoutTemplate(
      id: _workout.id,
      name: _workout.name,
      description: _workout.description,
      category: _parseCategoryForWorkout(_workout.category),
      difficulty: _parseDifficulty(_workout.difficulty),
      estimatedMinutes: _workout.totalMinutes,
      exercises: workoutExercises,
      isCustom: true,
    );
  }

  ExerciseCategory _parseCategory(String category) {
    switch (category.toLowerCase()) {
      case 'cardio':
        return ExerciseCategory.cardio;
      case 'hiit':
        return ExerciseCategory.hiit;
      case 'yoga':
        return ExerciseCategory.yoga;
      case 'stretching':
        return ExerciseCategory.stretching;
      case 'calisthenics':
        return ExerciseCategory.calisthenics;
      default:
        return ExerciseCategory.strength;
    }
  }

  ExerciseCategory _parseCategoryForWorkout(String category) {
    switch (category.toLowerCase()) {
      case 'full body':
        return ExerciseCategory.strength;
      case 'upper body':
        return ExerciseCategory.strength;
      case 'lower body':
        return ExerciseCategory.strength;
      case 'core':
        return ExerciseCategory.strength;
      case 'cardio':
        return ExerciseCategory.cardio;
      case 'hiit':
        return ExerciseCategory.hiit;
      default:
        return ExerciseCategory.strength;
    }
  }

  WorkoutDifficulty _parseDifficulty(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'intermediate':
        return WorkoutDifficulty.intermediate;
      case 'advanced':
        return WorkoutDifficulty.advanced;
      default:
        return WorkoutDifficulty.beginner;
    }
  }
}
