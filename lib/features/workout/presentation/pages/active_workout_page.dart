import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_session.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_template.dart';
import 'package:fitness_app/features/workout/domain/repositories/workout_repository.dart';
import 'package:fitness_app/features/workout/presentation/bloc/active_workout_bloc.dart';
import 'package:fitness_app/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class ActiveWorkoutPage extends StatelessWidget {
  final WorkoutTemplate workout;
  final String userId;

  const ActiveWorkoutPage({
    super.key,
    required this.workout,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ActiveWorkoutBloc()
            ..add(StartWorkout(template: workout, userId: userId)),
      child: const _ActiveWorkoutView(),
    );
  }
}

class _ActiveWorkoutView extends StatelessWidget {
  const _ActiveWorkoutView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActiveWorkoutBloc, ActiveWorkoutState>(
      listener: (context, state) {
        if (state is ActiveWorkoutCompleted) {
          _showCompletionDialog(context, state);
        }
      },
      builder: (context, state) {
        if (state is ActiveWorkoutInProgress) {
          return _buildWorkoutScreen(context, state);
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildWorkoutScreen(
    BuildContext context,
    ActiveWorkoutInProgress state,
  ) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitDialog(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: state.isResting
              ? AppColors.restScreen
              : AppColors.primary,
          foregroundColor: AppColors.white,
          title: Text(
            state.isResting ? 'Rest' : state.currentExercise.exercise.name,
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showExitDialog(context),
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Text(
                  state.formattedTime,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: state.isResting
            ? _buildRestScreen(context, state)
            : _buildExerciseScreen(context, state),
      ),
    );
  }

  Widget _buildRestScreen(BuildContext context, ActiveWorkoutInProgress state) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.restScreen, AppColors.restScreenDark],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timer, color: AppColors.white, size: 80),
            const SizedBox(height: 32),
            const Text(
              'Rest Time',
              style: TextStyle(color: AppColors.white70, fontSize: 24),
            ),
            const SizedBox(height: 16),
            Text(
              state.formattedRestTime,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 80,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ActiveWorkoutBloc>().add(const SkipRest());
              },
              icon: const Icon(Icons.skip_next),
              label: const Text('Skip Rest'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.white,
                foregroundColor: AppColors.restScreen,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Next: ${_getNextExerciseName(state)}',
              style: const TextStyle(color: AppColors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  String _getNextExerciseName(ActiveWorkoutInProgress state) {
    if (state.currentSetIndex + 1 < state.currentExercise.sets) {
      return '${state.currentExercise.exercise.name} - Set ${state.currentSetIndex + 2}';
    } else if (state.currentExerciseIndex + 1 < state.totalExercises) {
      return state
          .template
          .exercises[state.currentExerciseIndex + 1]
          .exercise
          .name;
    }
    return 'Finish!';
  }

  Widget _buildExerciseScreen(
    BuildContext context,
    ActiveWorkoutInProgress state,
  ) {
    final exercise = state.currentExercise;

    return Column(
      children: [
        // Progress indicator
        LinearProgressIndicator(
          value: (state.currentExerciseIndex + 1) / state.totalExercises,
          backgroundColor: AppColors.chipBackground,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Exercise info card
                _buildExerciseCard(exercise),
                const SizedBox(height: 24),

                // Set counter
                _buildSetCounter(state),
                const SizedBox(height: 24),

                // Exercise details
                _buildExerciseDetails(exercise),
                const SizedBox(height: 32),

                // Pause/Resume button
                if (state.isPaused)
                  _buildPausedOverlay(context)
                else
                  _buildControls(context, state),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(WorkoutExercise exercise) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryVariant],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            exercise.exercise.category.icon,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            exercise.exercise.name,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            exercise.exercise.description,
            style: const TextStyle(color: AppColors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSetCounter(ActiveWorkoutInProgress state) {
    final exercise = state.currentExercise;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(exercise.sets, (index) {
        final isCompleted = index < state.currentSetIndex;
        final isCurrent = index == state.currentSetIndex;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.success
                : isCurrent
                ? AppColors.primary
                : AppColors.chipBackground,
            shape: BoxShape.circle,
            border: isCurrent
                ? Border.all(color: AppColors.primary, width: 3)
                : null,
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: AppColors.white, size: 20)
                : Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isCurrent
                          ? AppColors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      }),
    );
  }

  Widget _buildExerciseDetails(WorkoutExercise exercise) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDetailItem(
            icon: Icons.repeat,
            value: '${exercise.sets}',
            label: 'Sets',
          ),
          Container(width: 1, height: 40, color: AppColors.chipBackground),
          _buildDetailItem(
            icon: exercise.exercise.isTimeBased
                ? Icons.timer
                : Icons.fitness_center,
            value: exercise.exercise.isTimeBased
                ? '${exercise.durationSeconds}s'
                : '${exercise.reps}',
            label: exercise.exercise.isTimeBased ? 'Duration' : 'Reps',
          ),
          Container(width: 1, height: 40, color: AppColors.chipBackground),
          _buildDetailItem(
            icon: Icons.hourglass_empty,
            value: '${exercise.restSeconds}s',
            label: 'Rest',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, ActiveWorkoutInProgress state) {
    return Column(
      children: [
        // Complete set button
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              context.read<ActiveWorkoutBloc>().add(
                CompleteSet(
                  reps: state.currentExercise.reps,
                  durationSeconds: state.currentExercise.durationSeconds,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check, size: 28),
                SizedBox(width: 12),
                Text(
                  'Complete Set',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Navigation row
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: state.currentExerciseIndex > 0
                    ? () => context.read<ActiveWorkoutBloc>().add(
                        const PreviousExercise(),
                      )
                    : null,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Previous'),
              ),
            ),
            IconButton(
              onPressed: () {
                context.read<ActiveWorkoutBloc>().add(const PauseWorkout());
              },
              icon: const Icon(Icons.pause_circle_outline),
              iconSize: 40,
              color: AppColors.textSecondary,
            ),
            Expanded(
              child: TextButton.icon(
                onPressed: state.currentExerciseIndex < state.totalExercises - 1
                    ? () => context.read<ActiveWorkoutBloc>().add(
                        const NextExercise(),
                      )
                    : null,
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Skip'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPausedOverlay(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.chipBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.pause_circle,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              const Text(
                'Workout Paused',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<ActiveWorkoutBloc>().add(const ResumeWorkout());
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Resume'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('End Workout?'),
        content: const Text(
          'Your progress will be lost. Are you sure you want to exit?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ActiveWorkoutBloc>().add(const AbandonWorkout());
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog(
    BuildContext context,
    ActiveWorkoutCompleted state,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.amber, size: 32),
            SizedBox(width: 12),
            Text('Workout Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Great job finishing ${state.template.name}!'),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.timer, size: 20),
                const SizedBox(width: 8),
                Text('Duration: ${state.formattedTime}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 20,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                Text('Sets completed: ${state.completedSets.length}'),
              ],
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              // Save the completed workout to history
              final repository = sl<WorkoutRepository>();
              final session = WorkoutSession(
                id: const Uuid().v4(),
                userId: state.userId,
                template: state.template,
                startTime: DateTime.now().subtract(
                  Duration(seconds: state.totalSeconds),
                ),
                endTime: DateTime.now(),
                completedSets: state.completedSets,
                status: WorkoutSessionStatus.completed,
              );
              await repository.completeWorkout(session);

              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
