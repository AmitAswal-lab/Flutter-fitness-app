import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_template.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:fitness_app/features/workout/presentation/pages/workout_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WorkoutLibraryPage extends StatefulWidget {
  const WorkoutLibraryPage({super.key});

  @override
  State<WorkoutLibraryPage> createState() => _WorkoutLibraryPageState();
}

class _WorkoutLibraryPageState extends State<WorkoutLibraryPage> {
  @override
  void initState() {
    super.initState();
    context.read<WorkoutBloc>().add(const LoadWorkouts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Workouts'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(child: _buildWorkoutList()),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return BlocBuilder<WorkoutBloc, WorkoutState>(
      builder: (context, state) {
        final selectedCategory = state is WorkoutLoaded
            ? state.selectedCategory
            : null;

        return Container(
          height: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildFilterChip('All', null, selectedCategory),
              ...ExerciseCategory.values.map(
                (cat) =>
                    _buildFilterChip(cat.displayName, cat, selectedCategory),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    String label,
    ExerciseCategory? category,
    ExerciseCategory? selected,
  ) {
    final isSelected = category == selected;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          context.read<WorkoutBloc>().add(FilterByCategory(category: category));
        },
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        checkmarkColor: Colors.white,
      ),
    );
  }

  Widget _buildWorkoutList() {
    return BlocBuilder<WorkoutBloc, WorkoutState>(
      builder: (context, state) {
        if (state is WorkoutLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is WorkoutError) {
          return Center(child: Text('Error: ${state.message}'));
        }

        if (state is WorkoutLoaded) {
          if (state.workouts.isEmpty) {
            return const Center(child: Text('No workouts found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.workouts.length,
            itemBuilder: (context, index) {
              return _buildWorkoutCard(state.workouts[index]);
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildWorkoutCard(WorkoutTemplate workout) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _navigateToDetail(workout),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      workout.category.icon,
                      style: const TextStyle(fontSize: 24),
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
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          workout.description,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.timer,
                    '${workout.estimatedMinutes} min',
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.fitness_center,
                    '${workout.exercises.length} exercises',
                  ),
                  const SizedBox(width: 12),
                  _buildDifficultyChip(workout.difficulty),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(WorkoutDifficulty difficulty) {
    Color bgColor;
    switch (difficulty) {
      case WorkoutDifficulty.beginner:
        bgColor = Colors.green[100]!;
        break;
      case WorkoutDifficulty.intermediate:
        bgColor = Colors.orange[100]!;
        break;
      case WorkoutDifficulty.advanced:
        bgColor = Colors.red[100]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(difficulty.icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            difficulty.displayName,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[800],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(WorkoutTemplate workout) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<WorkoutBloc>(),
          child: WorkoutDetailPage(workout: workout),
        ),
      ),
    );
  }
}
