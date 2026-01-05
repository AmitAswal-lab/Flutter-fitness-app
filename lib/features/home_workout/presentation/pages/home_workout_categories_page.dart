import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/core/services/custom_workout_service.dart';
import 'package:fitness_app/features/home_workout/presentation/pages/create_workout_page.dart';
import 'package:fitness_app/features/home_workout/presentation/pages/custom_workout_detail_page.dart';
import 'package:fitness_app/features/home_workout/presentation/pages/exercise_library_page.dart';
import 'package:fitness_app/features/home_workout/presentation/pages/home_workout_page.dart';
import 'package:fitness_app/features/home_workout/presentation/pages/workout_history_page.dart';
import 'package:flutter/material.dart';

class HomeWorkoutCategoriesPage extends StatefulWidget {
  const HomeWorkoutCategoriesPage({super.key});

  @override
  State<HomeWorkoutCategoriesPage> createState() =>
      _HomeWorkoutCategoriesPageState();
}

class _HomeWorkoutCategoriesPageState extends State<HomeWorkoutCategoriesPage> {
  List<CustomWorkout> _customWorkouts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCustomWorkouts();
  }

  Future<void> _loadCustomWorkouts() async {
    final workouts = await CustomWorkoutService().getAllWorkouts();
    if (mounted) {
      setState(() {
        _customWorkouts = workouts;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Workouts"),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WorkoutHistoryPage()),
              );
            },
            tooltip: 'Workout History',
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Built-in workouts
            _CategoryCard(
              title: "Full Body",
              subtitle: "Comprehensive full body routine",
              icon: Icons.accessibility_new,
              color: AppColors.primary,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeWorkoutPage()),
                );
              },
            ),
            const SizedBox(height: 16),
            const _CategoryCard(
              title: "Upper Body",
              subtitle: "Chest, Back, Arms",
              icon: Icons.fitness_center,
              color: AppColors.textHint,
              isComingSoon: true,
            ),
            const SizedBox(height: 16),
            const _CategoryCard(
              title: "Legs",
              subtitle: "Quads, Hamstrings, Calves",
              icon: Icons.directions_run,
              color: AppColors.textHint,
              isComingSoon: true,
            ),

            // Custom workouts section
            if (_customWorkouts.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Text(
                'My Custom Workouts',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              ..._customWorkouts.map(
                (workout) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _CustomWorkoutCard(
                    workout: workout,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CustomWorkoutDetailPage(workout: workout),
                        ),
                      );
                    },
                    onDelete: () => _deleteWorkout(workout),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),
            // Create Workout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateWorkoutPage(),
                    ),
                  );
                  if (result != null) {
                    _loadCustomWorkouts(); // Refresh list
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Create Custom Workout'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Exercise Library Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ExerciseLibraryPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.library_books),
                label: const Text('Browse Exercise Library'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: AppColors.primary),
                  foregroundColor: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteWorkout(CustomWorkout workout) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Workout?'),
        content: Text('Are you sure you want to delete "${workout.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await CustomWorkoutService().deleteWorkout(workout.id);
              _loadCustomWorkouts();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomWorkoutCard extends StatelessWidget {
  final CustomWorkout workout;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CustomWorkoutCard({
    required this.workout,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workout.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${workout.exercises.length} exercises • ${workout.totalMinutes} min • ${workout.difficulty}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isComingSoon;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isComingSoon ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isComingSoon
              ? AppColors.white.withOpacity(0.5)
              : AppColors.surface, // Adjust for coming soon
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isComingSoon
                ? AppColors.textHint.withOpacity(0.3)
                : color.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: isComingSoon
              ? []
              : [
                  BoxShadow(
                    color: color.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isComingSoon
                    ? AppColors.textHint.withOpacity(0.1)
                    : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isComingSoon ? AppColors.textHint : color,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isComingSoon
                              ? AppColors.textHint
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (isComingSoon) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textHint.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "Coming Soon",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textHint,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!isComingSoon)
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textHint,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }
}
