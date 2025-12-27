import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/features/home_workout/presentation/bloc/active_home_workout_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActiveHomeWorkoutPage extends StatelessWidget {
  const ActiveHomeWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActiveHomeWorkoutBloc, ActiveHomeWorkoutState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: _getBackgroundColor(state.phase),
          appBar: _buildAppBar(context, state),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Color _getBackgroundColor(WorkoutPhase phase) {
    switch (phase) {
      case WorkoutPhase.preparation:
        return AppColors.background;
      case WorkoutPhase.exercise:
        return AppColors.background;
      case WorkoutPhase.rest:
        return AppColors.restScreen;
      case WorkoutPhase.complete:
        return AppColors.successLight;
    }
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ActiveHomeWorkoutState state,
  ) {
    final isRestPhase = state.phase == WorkoutPhase.rest;
    final iconColor = isRestPhase ? AppColors.white : AppColors.textPrimary;

    // Calculate elapsed time
    final elapsed = state.startTime != null
        ? DateTime.now().difference(state.startTime!)
        : Duration.zero;
    final elapsedStr =
        '${elapsed.inMinutes.toString().padLeft(2, '0')}:${(elapsed.inSeconds % 60).toString().padLeft(2, '0')}';

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.close, color: iconColor),
        onPressed: () => _showExitDialog(context),
      ),
      title: state.workout != null && state.phase != WorkoutPhase.complete
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  elapsedStr,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${state.currentExerciseIndex + 1}/${state.totalExercises}',
                  style: TextStyle(
                    color: iconColor.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            )
          : null,
      centerTitle: true,
      actions: [
        if (state.phase != WorkoutPhase.complete)
          IconButton(
            icon: Icon(
              state.isPaused ? Icons.play_arrow : Icons.pause,
              color: iconColor,
            ),
            onPressed: () {
              if (state.isPaused) {
                context.read<ActiveHomeWorkoutBloc>().add(
                  const ResumeWorkout(),
                );
              } else {
                context.read<ActiveHomeWorkoutBloc>().add(const PauseWorkout());
              }
            },
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, ActiveHomeWorkoutState state) {
    switch (state.phase) {
      case WorkoutPhase.preparation:
        return _buildPreparationPhase(context, state);
      case WorkoutPhase.exercise:
        return _buildExercisePhase(context, state);
      case WorkoutPhase.rest:
        return _buildRestPhase(context, state);
      case WorkoutPhase.complete:
        return _buildCompletePhase(context, state);
    }
  }

  Widget _buildPreparationPhase(
    BuildContext context,
    ActiveHomeWorkoutState state,
  ) {
    final exercise = state.currentExercise;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(),
            // Exercise preview
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Ready to go text
            const Text(
              'READY TO GO!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 16),
            // Exercise name
            Text(
              exercise?.exercise.name.toUpperCase() ?? 'EXERCISE',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            // Countdown timer
            _buildCircularTimer(state.timeRemaining, 15, AppColors.primary),
            const SizedBox(height: 24),
            // Skip button
            GestureDetector(
              onTap: () {
                context.read<ActiveHomeWorkoutBloc>().add(
                  const SkipPreparation(),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.chipBackground,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Skip',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisePhase(
    BuildContext context,
    ActiveHomeWorkoutState state,
  ) {
    final exercise = state.currentExercise;
    if (exercise == null) return const SizedBox.shrink();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(),
            // Exercise preview
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: AppColors.primary.withValues(alpha: 0.5),
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Exercise name
            Text(
              exercise.exercise.name.toUpperCase(),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            // Show timer OR reps based on exercise type
            if (state.isTimeBased)
              _buildCircularTimer(
                state.timeRemaining,
                exercise.durationSeconds,
                AppColors.primary,
              )
            else
              _buildRepsDisplay(exercise.reps),
            const Spacer(),
            // Controls
            if (state.isRepBased) _buildRepBasedControls(context, state),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildRepsDisplay(int reps) {
    return Column(
      children: [
        Text(
          '×$reps',
          style: const TextStyle(
            fontSize: 64,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.chipBackground,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reps',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              SizedBox(width: 4),
              Icon(Icons.swap_vert, size: 16, color: AppColors.textSecondary),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRepBasedControls(
    BuildContext context,
    ActiveHomeWorkoutState state,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Previous button
        IconButton(
          onPressed: () {
            context.read<ActiveHomeWorkoutBloc>().add(const PreviousExercise());
          },
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.skip_previous, size: 28),
          ),
        ),
        const SizedBox(width: 16),
        // Complete button (checkmark)
        GestureDetector(
          onTap: () {
            context.read<ActiveHomeWorkoutBloc>().add(const CompleteExercise());
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.check, size: 40, color: AppColors.white),
          ),
        ),
        const SizedBox(width: 16),
        // Next button
        IconButton(
          onPressed: () {
            context.read<ActiveHomeWorkoutBloc>().add(const CompleteExercise());
          },
          icon: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.chipBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.skip_next, size: 28),
          ),
        ),
      ],
    );
  }

  Widget _buildRestPhase(BuildContext context, ActiveHomeWorkoutState state) {
    final nextIndex = state.currentExerciseIndex + 1;
    final nextExercise = nextIndex < state.totalExercises
        ? state.workout!.exercises[nextIndex]
        : null;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(),
            // Next exercise preview
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(
                  Icons.fitness_center,
                  size: 80,
                  color: AppColors.white70,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Next exercise info
            Text(
              'NEXT ${nextIndex + 1}/${state.totalExercises}',
              style: const TextStyle(fontSize: 14, color: AppColors.white70),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  nextExercise?.exercise.name.toUpperCase() ?? 'NEXT EXERCISE',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(width: 8),
                if (nextExercise != null && nextExercise.reps > 0)
                  Text(
                    'x ${nextExercise.reps}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppColors.white,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            // REST label
            const Text(
              'REST',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Timer display
            Text(
              _formatTime(state.timeRemaining),
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 32),
            // Rest controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Add time button
                GestureDetector(
                  onTap: () {
                    context.read<ActiveHomeWorkoutBloc>().add(
                      const AddRestTime(seconds: 15),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.restScreenDark,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      '+15s',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Skip button
                GestureDetector(
                  onTap: () {
                    context.read<ActiveHomeWorkoutBloc>().add(const SkipRest());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.restScreen,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletePhase(
    BuildContext context,
    ActiveHomeWorkoutState state,
  ) {
    final duration = state.startTime != null
        ? DateTime.now().difference(state.startTime!)
        : Duration.zero;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration, size: 80, color: AppColors.success),
            const SizedBox(height: 24),
            const Text(
              'Workout Complete!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 32),
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  'Duration',
                  '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
                ),
                _buildStatItem('Exercises', '${state.totalExercises}'),
              ],
            ),
            const SizedBox(height: 48),
            // Done button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Done',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildCircularTimer(int remaining, int total, Color color) {
    final progress = total > 0 ? remaining / total : 0.0;

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          Text(
            '$remaining',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Exit Workout?'),
        content: const Text('Your progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}
