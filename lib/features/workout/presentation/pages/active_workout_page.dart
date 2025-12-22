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

class _ActiveWorkoutView extends StatefulWidget {
  const _ActiveWorkoutView();

  @override
  State<_ActiveWorkoutView> createState() => _ActiveWorkoutViewState();
}

class _ActiveWorkoutViewState extends State<_ActiveWorkoutView> {
  bool _showCelebration = false;
  int _lastCompletedSetCount = 0;

  void _triggerCelebration() {
    setState(() => _showCelebration = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _showCelebration = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ActiveWorkoutBloc, ActiveWorkoutState>(
      listener: (context, state) {
        if (state is ActiveWorkoutCompleted) {
          _showCompletionDialog(context, state);
        }
        // Trigger celebration when a set is completed
        if (state is ActiveWorkoutInProgress) {
          final currentSetCount = state.completedSets.length;
          if (currentSetCount > _lastCompletedSetCount && !state.isResting) {
            _triggerCelebration();
          }
          _lastCompletedSetCount = currentSetCount;
        }
      },
      builder: (context, state) {
        if (state is ActiveWorkoutInProgress) {
          return Stack(
            children: [
              _buildWorkoutScreen(context, state),
              if (_showCelebration) _buildCelebrationOverlay(),
            ],
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }

  Widget _buildCelebrationOverlay() {
    return AnimatedOpacity(
      opacity: _showCelebration ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 80),
                SizedBox(height: 16),
                Text(
                  'Set Complete!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
            // Timer with +/- buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    context.read<ActiveWorkoutBloc>().add(
                      const AdjustRestTime(deltaSeconds: -15),
                    );
                  },
                  icon: const Icon(Icons.remove_circle_outline),
                  color: AppColors.white,
                  iconSize: 40,
                ),
                const SizedBox(width: 16),
                Text(
                  state.formattedRestTime,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: () {
                    context.read<ActiveWorkoutBloc>().add(
                      const AdjustRestTime(deltaSeconds: 15),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  color: AppColors.white,
                  iconSize: 40,
                ),
              ],
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

    // Count completed sets for the CURRENT exercise only
    final completedSetsForExercise = state.completedSets
        .where((s) => s.exerciseId == exercise.exercise.id)
        .length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(exercise.sets, (index) {
        final isCompleted = index < completedSetsForExercise;
        final isCurrent = index == completedSetsForExercise;

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
    // Calculate current set number (1-based) for this exercise
    final exercise = state.currentExercise;
    final completedSetsForExercise = state.completedSets
        .where((s) => s.exerciseId == exercise.exercise.id)
        .length;
    final currentSetNumber = completedSetsForExercise + 1;
    final totalSets = exercise.sets;
    final isLastSet = currentSetNumber == totalSets;
    final isLastExercise =
        state.currentExerciseIndex == state.totalExercises - 1;

    // Determine button based on state
    if (!state.isDoingExercise) {
      // Show "Start Set" button
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                context.read<ActiveWorkoutBloc>().add(const StartSet());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow_rounded, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Start Set $currentSetNumber of $totalSets',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildNavigationRow(context, state),
        ],
      );
    }

    // User is doing exercise - show "Done" button
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            onPressed: () {
              context.read<ActiveWorkoutBloc>().add(
                CompleteSet(
                  reps: exercise.reps,
                  durationSeconds: exercise.durationSeconds,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isLastSet && isLastExercise ? Icons.flag : Icons.check,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  isLastSet && isLastExercise
                      ? 'Finish Workout'
                      : 'Done with Set $currentSetNumber',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Show set indicator - "Set X of Y"
        Text(
          'Set $currentSetNumber of $totalSets',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationRow(
    BuildContext context,
    ActiveWorkoutInProgress state,
  ) {
    return Row(
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
