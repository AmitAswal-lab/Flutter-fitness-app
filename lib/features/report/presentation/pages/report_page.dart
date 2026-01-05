import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/core/services/workout_history_service.dart';
import 'package:fitness_app/features/home_workout/presentation/pages/workout_history_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Report page - workout stats and progress
class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  WorkoutStats? _stats;
  List<WorkoutHistoryRecord> _recentWorkouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final service = WorkoutHistoryService();
    final stats = await service.getStats();
    final recent = await service.getThisWeekHistory();

    if (mounted) {
      setState(() {
        _stats = stats;
        _recentWorkouts = recent;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Report',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WorkoutHistoryPage()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewCard(),
                    const SizedBox(height: 24),
                    _buildWeeklyProgress(),
                    const SizedBox(height: 24),
                    _buildRecentWorkouts(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This Week',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_stats?.thisWeekWorkouts ?? 0} Workouts',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniStat(
                '🔥',
                '${_stats?.totalCaloriesBurned ?? 0}',
                'Calories',
              ),
              _buildMiniStat(
                '⏱️',
                '${_stats?.totalDurationMinutes ?? 0}',
                'Minutes',
              ),
              _buildMiniStat('💪', '${_stats?.totalWorkouts ?? 0}', 'Total'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyProgress() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();
    final currentDayIndex = now.weekday - 1;

    // Count workouts per day this week
    final workoutsPerDay = List.filled(7, 0);
    for (final workout in _recentWorkouts) {
      final dayIndex = workout.startedAt.weekday - 1;
      workoutsPerDay[dayIndex]++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weekly Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (index) {
              final hasWorkout = workoutsPerDay[index] > 0;
              final isToday = index == currentDayIndex;
              return Column(
                children: [
                  Text(
                    days[index],
                    style: TextStyle(
                      color: isToday
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: hasWorkout
                          ? AppColors.success
                          : isToday
                          ? AppColors.primary.withValues(alpha: 0.2)
                          : AppColors.chipBackground,
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                    child: hasWorkout
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentWorkouts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WorkoutHistoryPage()),
                );
              },
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_recentWorkouts.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.fitness_center,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No workouts this week yet',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          )
        else
          ...(_recentWorkouts
              .take(3)
              .map((workout) => _buildWorkoutTile(workout))),
      ],
    );
  }

  Widget _buildWorkoutTile(WorkoutHistoryRecord workout) {
    final dateFormat = DateFormat('E, MMM d');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.check, color: AppColors.success),
        ),
        title: Text(
          workout.workoutName,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          dateFormat.format(workout.startedAt),
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: Text(
          '${(workout.durationSeconds / 60).round()} min',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
