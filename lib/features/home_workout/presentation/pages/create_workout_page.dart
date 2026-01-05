import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/core/data/exercise_repository.dart';
import 'package:fitness_app/core/services/custom_workout_service.dart';
import 'package:fitness_app/features/home_workout/presentation/pages/exercise_picker_page.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise.dart';
import 'package:flutter/material.dart';

/// Selected exercise with custom reps/duration
class SelectedExercise {
  final Exercise exercise;
  int reps;
  int durationSeconds;
  int restSeconds;

  SelectedExercise({
    required this.exercise,
    this.reps = 12,
    this.durationSeconds = 30,
    this.restSeconds = 15,
  });
}

class CreateWorkoutPage extends StatefulWidget {
  /// If provided, the page will be in edit mode
  final CustomWorkout? existingWorkout;

  const CreateWorkoutPage({super.key, this.existingWorkout});

  bool get isEditMode => existingWorkout != null;

  @override
  State<CreateWorkoutPage> createState() => _CreateWorkoutPageState();
}

class _CreateWorkoutPageState extends State<CreateWorkoutPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final List<SelectedExercise> _selectedExercises = [];
  String _category = 'Full Body';
  String _difficulty = 'Beginner';
  String? _existingId; // For updates

  final List<String> _categories = [
    'Full Body',
    'Upper Body',
    'Lower Body',
    'Core',
    'Cardio',
    'HIIT',
  ];
  final List<String> _difficulties = ['Beginner', 'Intermediate', 'Advanced'];

  @override
  void initState() {
    super.initState();
    _loadExistingWorkout();
  }

  void _loadExistingWorkout() {
    final workout = widget.existingWorkout;
    if (workout == null) return;

    _existingId = workout.id;
    _nameController.text = workout.name;
    _descController.text = workout.description;
    _category = workout.category;
    _difficulty = workout.difficulty;

    // Load exercises
    final repo = ExerciseRepository();
    for (final customEx in workout.exercises) {
      final exercise = repo.getById(customEx.exerciseId);
      if (exercise != null) {
        _selectedExercises.add(
          SelectedExercise(
            exercise: exercise,
            reps: customEx.reps,
            durationSeconds: customEx.durationSeconds,
            restSeconds: customEx.restSeconds,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  int get _totalMinutes {
    int totalSeconds = 0;
    for (var ex in _selectedExercises) {
      if (ex.exercise.isTimeBased) {
        totalSeconds += ex.durationSeconds;
      } else {
        totalSeconds += 30; // Estimate 30s per rep-based exercise
      }
      totalSeconds += ex.restSeconds;
    }
    return (totalSeconds / 60).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          widget.isEditMode ? 'Edit Workout' : 'Create Workout',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => _showDiscardDialog(),
        ),
        actions: [
          TextButton(
            onPressed: _canSave ? _saveWorkout : null,
            child: Text(
              'Save',
              style: TextStyle(
                color: _canSave ? AppColors.success : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNameField(),
            const SizedBox(height: 16),
            _buildDescriptionField(),
            const SizedBox(height: 16),
            _buildCategoryDropdown(),
            const SizedBox(height: 16),
            _buildDifficultyDropdown(),
            const SizedBox(height: 24),
            _buildExercisesHeader(),
            const SizedBox(height: 12),
            _buildExercisesList(),
            const SizedBox(height: 16),
            _buildAddExerciseButton(),
            const SizedBox(height: 32),
            _buildSummary(),
          ],
        ),
      ),
    );
  }

  bool get _canSave =>
      _nameController.text.isNotEmpty && _selectedExercises.isNotEmpty;

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: 'Workout Name',
        labelStyle: TextStyle(color: AppColors.textSecondary),
        hintText: 'e.g., Morning Routine',
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descController,
      style: const TextStyle(color: AppColors.textPrimary),
      maxLines: 2,
      decoration: InputDecoration(
        labelText: 'Description (optional)',
        labelStyle: TextStyle(color: AppColors.textSecondary),
        hintText: 'Brief description of this workout...',
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _category,
      decoration: InputDecoration(
        labelText: 'Category',
        labelStyle: TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: AppColors.cardBackground,
      items: _categories
          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
          .toList(),
      onChanged: (v) => setState(() => _category = v!),
    );
  }

  Widget _buildDifficultyDropdown() {
    return DropdownButtonFormField<String>(
      value: _difficulty,
      decoration: InputDecoration(
        labelText: 'Difficulty',
        labelStyle: TextStyle(color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      dropdownColor: AppColors.cardBackground,
      items: _difficulties
          .map((d) => DropdownMenuItem(value: d, child: Text(d)))
          .toList(),
      onChanged: (v) => setState(() => _difficulty = v!),
    );
  }

  Widget _buildExercisesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Exercises',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          '${_selectedExercises.length} added',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildExercisesList() {
    if (_selectedExercises.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.chipBackground),
        ),
        child: Column(
          children: [
            Icon(
              Icons.fitness_center,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              'No exercises added yet',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              'Tap + to add exercises',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _selectedExercises.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          final item = _selectedExercises.removeAt(oldIndex);
          _selectedExercises.insert(newIndex, item);
        });
      },
      itemBuilder: (context, index) {
        return _buildExerciseCard(_selectedExercises[index], index);
      },
    );
  }

  Widget _buildExerciseCard(SelectedExercise selected, int index) {
    final exercise = selected.exercise;
    return Card(
      key: ValueKey(exercise.id + index.toString()),
      margin: const EdgeInsets.only(bottom: 8),
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: const Icon(
                Icons.drag_handle,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _buildChip(
                        exercise.isTimeBased
                            ? '${selected.durationSeconds}s'
                            : '${selected.reps} reps',
                      ),
                      const SizedBox(width: 8),
                      _buildChip('${selected.restSeconds}s rest'),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              color: AppColors.textSecondary,
              onPressed: () => _editExercise(index),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: AppColors.error,
              onPressed: () =>
                  setState(() => _selectedExercises.removeAt(index)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(color: AppColors.info, fontSize: 12)),
    );
  }

  Widget _buildAddExerciseButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _showExercisePicker,
        icon: const Icon(Icons.add),
        label: const Text('Add Exercise'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: AppColors.success),
          foregroundColor: AppColors.success,
        ),
      ),
    );
  }

  Widget _buildSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Exercises', '${_selectedExercises.length}'),
          _buildSummaryItem('Est. Time', '$_totalMinutes min'),
          _buildSummaryItem('Difficulty', _difficulty),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.success,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
      ],
    );
  }

  void _showExercisePicker() async {
    final alreadySelectedIds = _selectedExercises
        .map((e) => e.exercise.id)
        .toList();

    final result = await Navigator.push<List<Exercise>>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ExercisePickerPage(alreadySelectedIds: alreadySelectedIds),
      ),
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        for (final exercise in result) {
          _selectedExercises.add(
            SelectedExercise(
              exercise: exercise,
              reps: 12,
              durationSeconds: exercise.isTimeBased ? 30 : 0,
              restSeconds: 15,
            ),
          );
        }
      });
    }
  }

  void _editExercise(int index) {
    final selected = _selectedExercises[index];
    showDialog(
      context: context,
      builder: (context) => _EditExerciseDialog(
        selected: selected,
        onSave: (reps, duration, rest) {
          setState(() {
            selected.reps = reps;
            selected.durationSeconds = duration;
            selected.restSeconds = rest;
          });
        },
      ),
    );
  }

  void _showDiscardDialog() {
    if (_selectedExercises.isEmpty && _nameController.text.isEmpty) {
      Navigator.pop(context);
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Workout?'),
        content: const Text('Your changes will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  void _saveWorkout() async {
    // Create custom workout from selected exercises
    final now = DateTime.now();
    final isEdit = _existingId != null;
    final workout = CustomWorkout(
      id: _existingId ?? 'custom_${now.millisecondsSinceEpoch}',
      name: _nameController.text.trim(),
      description: _descController.text.trim(),
      category: _category,
      difficulty: _difficulty,
      exercises: _selectedExercises
          .map(
            (selected) => CustomWorkoutExercise(
              exerciseId: selected.exercise.id,
              exerciseName: selected.exercise.name,
              category: selected.exercise.category.name,
              isTimeBased: selected.exercise.isTimeBased,
              reps: selected.reps,
              durationSeconds: selected.durationSeconds,
              restSeconds: selected.restSeconds,
            ),
          )
          .toList(),
      createdAt: widget.existingWorkout?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      await CustomWorkoutService().saveWorkout(workout);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? '"${workout.name}" updated!'
                  : '"${workout.name}" saved!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, workout);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

class _EditExerciseDialog extends StatefulWidget {
  final SelectedExercise selected;
  final Function(int reps, int duration, int rest) onSave;

  const _EditExerciseDialog({required this.selected, required this.onSave});

  @override
  State<_EditExerciseDialog> createState() => _EditExerciseDialogState();
}

class _EditExerciseDialogState extends State<_EditExerciseDialog> {
  late int _reps;
  late int _duration;
  late int _rest;

  @override
  void initState() {
    super.initState();
    _reps = widget.selected.reps;
    _duration = widget.selected.durationSeconds;
    _rest = widget.selected.restSeconds;
  }

  @override
  Widget build(BuildContext context) {
    final isTimeBased = widget.selected.exercise.isTimeBased;
    return AlertDialog(
      title: Text('Edit ${widget.selected.exercise.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isTimeBased)
            _buildSlider(
              'Duration',
              _duration,
              10,
              120,
              (v) => setState(() => _duration = v),
              's',
            )
          else
            _buildSlider(
              'Reps',
              _reps,
              1,
              50,
              (v) => setState(() => _reps = v),
              '',
            ),
          const SizedBox(height: 16),
          _buildSlider(
            'Rest',
            _rest,
            5,
            60,
            (v) => setState(() => _rest = v),
            's',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSave(_reps, _duration, _rest);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildSlider(
    String label,
    int value,
    int min,
    int max,
    Function(int) onChanged,
    String suffix,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $value$suffix'),
        Slider(
          value: value.toDouble(),
          min: min.toDouble(),
          max: max.toDouble(),
          divisions: max - min,
          onChanged: (v) => onChanged(v.toInt()),
        ),
      ],
    );
  }
}
