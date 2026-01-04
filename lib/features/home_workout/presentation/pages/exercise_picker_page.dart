import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/core/data/exercise_repository.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise.dart';
import 'package:flutter/material.dart';

/// Modern exercise picker with multi-select, search, and category tabs
class ExercisePickerPage extends StatefulWidget {
  final List<String> alreadySelectedIds;

  const ExercisePickerPage({super.key, this.alreadySelectedIds = const []});

  @override
  State<ExercisePickerPage> createState() => _ExercisePickerPageState();
}

class _ExercisePickerPageState extends State<ExercisePickerPage> {
  final ExerciseRepository _repository = ExerciseRepository();
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};

  List<Exercise> _allExercises = [];
  List<Exercise> _filteredExercises = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Cardio',
    'Strength',
    'HIIT',
    'Stretching',
  ];

  @override
  void initState() {
    super.initState();
    _allExercises = _repository.getAllExercises();
    _filteredExercises = _allExercises;
    _selectedIds.addAll(widget.alreadySelectedIds);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterExercises() {
    setState(() {
      _filteredExercises = _allExercises.where((exercise) {
        final matchesSearch =
            _searchQuery.isEmpty ||
            exercise.name.toLowerCase().contains(_searchQuery.toLowerCase());

        final matchesCategory =
            _selectedCategory == 'All' ||
            exercise.category.name.toLowerCase() ==
                _selectedCategory.toLowerCase();

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Select Exercises',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_selectedIds.isNotEmpty)
            TextButton(
              onPressed: () => setState(() => _selectedIds.clear()),
              child: const Text('Clear'),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryTabs(),
          _buildSelectionCount(),
          Expanded(child: _buildExerciseGrid()),
        ],
      ),
      floatingActionButton: _selectedIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _addSelectedExercises,
              backgroundColor: AppColors.success,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Add ${_selectedIds.length} Exercise${_selectedIds.length > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Search exercises...',
          hintStyle: TextStyle(color: AppColors.textSecondary),
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    _searchQuery = '';
                    _filterExercises();
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.cardBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: (value) {
          _searchQuery = value;
          _filterExercises();
        },
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _selectedCategory = category);
                _filterExercises();
              },
              backgroundColor: AppColors.cardBackground,
              selectedColor: AppColors.success,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              checkmarkColor: Colors.white,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSelectionCount() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_filteredExercises.length} exercises',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          if (_selectedIds.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_selectedIds.length} selected',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExerciseGrid() {
    if (_filteredExercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No exercises found',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _filteredExercises.length,
      itemBuilder: (context, index) {
        return _buildExerciseCard(_filteredExercises[index]);
      },
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    final isSelected = _selectedIds.contains(exercise.id);
    final isAlreadyAdded = widget.alreadySelectedIds.contains(exercise.id);

    return GestureDetector(
      onTap: isAlreadyAdded ? null : () => _toggleSelection(exercise.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isAlreadyAdded
              ? AppColors.chipBackground
              : isSelected
              ? AppColors.success.withValues(alpha: 0.15)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.success : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.success.withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon/GIF placeholder
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: _getCategoryColor(
                            exercise.category,
                          ).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            exercise.category.icon,
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Exercise name
                  Text(
                    exercise.name,
                    style: TextStyle(
                      color: isAlreadyAdded
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Category tag
                  Row(
                    children: [
                      _buildMiniTag(
                        exercise.category.displayName,
                        _getCategoryColor(exercise.category),
                      ),
                      const Spacer(),
                      Icon(
                        exercise.isTimeBased ? Icons.timer : Icons.repeat,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Selection checkbox
            Positioned(
              top: 8,
              right: 8,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isAlreadyAdded
                      ? AppColors.textSecondary
                      : isSelected
                      ? AppColors.success
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isAlreadyAdded
                        ? AppColors.textSecondary
                        : isSelected
                        ? AppColors.success
                        : AppColors.textSecondary,
                    width: 2,
                  ),
                ),
                child: isAlreadyAdded || isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
            ),
            // Already added indicator
            if (isAlreadyAdded)
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Already added',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getCategoryColor(ExerciseCategory category) {
    switch (category) {
      case ExerciseCategory.cardio:
        return Colors.orange;
      case ExerciseCategory.strength:
        return Colors.blue;
      case ExerciseCategory.hiit:
        return Colors.red;
      case ExerciseCategory.yoga:
        return Colors.purple;
      case ExerciseCategory.stretching:
        return Colors.teal;
      case ExerciseCategory.calisthenics:
        return Colors.green;
    }
  }

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _addSelectedExercises() {
    final selectedExercises = _allExercises
        .where(
          (e) =>
              _selectedIds.contains(e.id) &&
              !widget.alreadySelectedIds.contains(e.id),
        )
        .toList();
    Navigator.pop(context, selectedExercises);
  }
}
