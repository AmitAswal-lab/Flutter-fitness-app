import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_template.dart';
import 'package:fitness_app/features/home_workout/presentation/bloc/home_workout_bloc.dart';
import 'package:fitness_app/features/home_workout/presentation/bloc/active_home_workout_bloc.dart';
import 'package:fitness_app/features/home_workout/presentation/pages/edit_workout_page.dart';
import 'package:fitness_app/features/home_workout/presentation/pages/active_home_workout_page.dart';
import 'package:fitness_app/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeWorkoutPage extends StatelessWidget {
  const HomeWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HomeWorkoutBloc>()..add(LoadHomeWorkout()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<HomeWorkoutBloc, HomeWorkoutState>(
          builder: (context, state) {
            if (state.status == HomeWorkoutStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.status == HomeWorkoutStatus.failure) {
              return Center(child: Text('Error: ${state.errorMessage}'));
            } else if (state.workout != null) {
              return SafeArea(
                child: Column(
                  children: [
                    // Custom AppBar
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          // Placeholder for "Day X" or Title
                          const Text(
                            "Full Body",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Optional menu or spacers
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    // Stats Cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              label: "Duration",
                              value: "${state.workout!.estimatedMinutes} mins",
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _StatCard(
                              label: "Exercises",
                              value: "${state.workout!.exercises.length}",
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Exercises Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Exercises",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BlocProvider.value(
                                    value: context.read<HomeWorkoutBloc>(),
                                    child: const EditWorkoutPage(),
                                  ),
                                ),
                              );
                            },
                            child: const Row(
                              children: [
                                Text("Edit"),
                                Icon(Icons.chevron_right, size: 16),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Exercise List
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.workout!.exercises.length,
                        separatorBuilder: (_, __) => const Divider(height: 32),
                        itemBuilder: (context, index) {
                          final item = state.workout!.exercises[index];
                          return _ExerciseItem(item: item);
                        },
                      ),
                    ),

                    // Start Button
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BlocProvider(
                                  create: (_) =>
                                      sl<ActiveHomeWorkoutBloc>()
                                        ..add(StartWorkout(state.workout!)),
                                  child: const ActiveHomeWorkoutPage(),
                                ),
                              ),
                            );
                          },
                          child: const Text(
                            "Start",
                            style: TextStyle(
                              fontSize: 18,
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
            return const Center(child: Text("Something went wrong"));
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _ExerciseItem extends StatelessWidget {
  final WorkoutExercise item;

  const _ExerciseItem({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Placeholder Image
        Container(
          width: 80,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
            // Mock image loading if url available
            // image: DecorationImage(...)
          ),
          alignment: Alignment.center,
          child: item.exercise.imageUrl != null
              ? Image.asset(
                  item.exercise.imageUrl!,
                  errorBuilder: (c, e, s) => const Icon(Icons.fitness_center),
                )
              : const Icon(Icons.fitness_center, color: Colors.grey),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.exercise.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              item.exercise.isTimeBased
                  ? _formatDuration(item.durationSeconds)
                  : "x${item.reps}",
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        const Spacer(),
        Icon(Icons.swap_vert, color: Colors.grey[400]),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }
}
