import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_session.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_history_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class WorkoutHistoryPage extends StatelessWidget {
  final String userId;

  const WorkoutHistoryPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Workout History'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: BlocBuilder<WorkoutHistoryBloc, WorkoutHistoryState>(
        builder: (context, state) {
          if (state is WorkoutHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is WorkoutHistoryError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is WorkoutHistoryLoaded) {
            return _buildContent(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WorkoutHistoryLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatsCard(state.stats),
          const SizedBox(height: 24),
          const Text(
            'Recent Workouts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (state.sessions.isEmpty)
            _buildEmptyState()
          else
            ...state.sessions.map((s) => _buildHistoryCard(s)),
        ],
      ),
    );
  }

  Widget _buildStatsCard(WorkoutStats stats) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryVariant],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.fitness_center,
                value: '${stats.totalWorkouts}',
                label: 'Workouts',
              ),
              _buildStatItem(
                icon: Icons.timer,
                value: '${stats.totalMinutes}',
                label: 'Minutes',
              ),
              _buildStatItem(
                icon: Icons.repeat,
                value: '${stats.totalSets}',
                label: 'Sets',
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.white20),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.calendar_today,
                value: '${stats.thisWeekWorkouts}',
                label: 'This Week',
              ),
              _buildStatItem(
                icon: Icons.local_fire_department,
                value: '${stats.currentStreak}',
                label: 'Day Streak',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: AppColors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(Icons.history, size: 64, color: AppColors.textSecondary),
          const SizedBox(height: 16),
          const Text(
            'No workouts yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete a workout to see it here',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(WorkoutSession session) {
    final dateFormat = DateFormat('MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final duration = session.endTime != null
        ? session.endTime!.difference(session.startTime).inMinutes
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              session.template.category.icon,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.template.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${dateFormat.format(session.startTime)} at ${timeFormat.format(session.startTime)}',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(Icons.timer, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '${duration}m',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.check_circle, size: 14, color: AppColors.success),
                  const SizedBox(width: 4),
                  Text(
                    '${session.completedSets.length} sets',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
