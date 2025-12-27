import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_template.dart';
import 'package:fitness_app/features/home_workout/presentation/bloc/home_workout_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditWorkoutPage extends StatelessWidget {
  const EditWorkoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Edit plan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Reset button (optional, not implemented logic yet)
          TextButton(
            onPressed: () {
              // Reset logic could go here
            },
            child: const Text("Reset"),
          ),
        ],
      ),
      body: BlocBuilder<HomeWorkoutBloc, HomeWorkoutState>(
        builder: (context, state) {
          if (state.workout == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: state.workout!.exercises.length,
                  onReorder: (oldIndex, newIndex) {
                    context.read<HomeWorkoutBloc>().add(
                      ReorderExercises(oldIndex, newIndex),
                    );
                  },
                  itemBuilder: (context, index) {
                    final item = state.workout!.exercises[index];
                    return _EditExerciseItem(
                      key: ValueKey(
                        item.exercise.id + index.toString(),
                      ), // ensuring unique key even if duplicate exercise
                      item: item,
                      index: index,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<HomeWorkoutBloc>().add(
                            SaveHomeWorkout(),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EditExerciseItem extends StatelessWidget {
  final WorkoutExercise item;
  final int index;

  const _EditExerciseItem({
    required super.key,
    required this.item,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white, // Important for dragging visual
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Drag Handle (Left side as often seen in lists, or handle on right?)
          // ReorderableListView has default handle, but we can custom trigger if we want.
          // Default is long press on item.
          // Let's add a clear drag handle if possible or just use the icon.
          const Icon(Icons.drag_handle, color: Colors.grey),
          const SizedBox(width: 16),

          // Image
          Container(
            width: 60,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: item.exercise.imageUrl != null
                ? Image.asset(
                    item.exercise.imageUrl!,
                    errorBuilder: (c, e, s) =>
                        const Icon(Icons.fitness_center, size: 20),
                  )
                : const Icon(
                    Icons.fitness_center,
                    color: Colors.grey,
                    size: 20,
                  ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.exercise.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _RoundIconButton(
                      icon: Icons.remove,
                      onPressed: () {
                        if (item.exercise.isTimeBased) {
                          if (item.durationSeconds > 5) {
                            context.read<HomeWorkoutBloc>().add(
                              UpdateExerciseDuration(
                                index,
                                item.durationSeconds - 5,
                              ),
                            );
                          }
                        } else {
                          if (item.reps > 1) {
                            context.read<HomeWorkoutBloc>().add(
                              UpdateExerciseReps(index, item.reps - 1),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    Text(
                      item.exercise.isTimeBased
                          ? _formatDuration(item.durationSeconds)
                          : "x${item.reps}",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    _RoundIconButton(
                      icon: Icons.add,
                      onPressed: () {
                        if (item.exercise.isTimeBased) {
                          context.read<HomeWorkoutBloc>().add(
                            UpdateExerciseDuration(
                              index,
                              item.durationSeconds + 5,
                            ),
                          );
                        } else {
                          context.read<HomeWorkoutBloc>().add(
                            UpdateExerciseReps(index, item.reps + 1),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Swap/Sort Icon (Visual indication that it's sortable)
          const Icon(Icons.swap_vert, color: AppColors.primary),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _RoundIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: Colors.black87),
      ),
    );
  }
}
