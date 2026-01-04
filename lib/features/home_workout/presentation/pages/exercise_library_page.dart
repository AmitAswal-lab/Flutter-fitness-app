import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/core/data/exercise_repository.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise.dart';
import 'package:flutter/material.dart';

class ExerciseLibraryPage extends StatefulWidget {
  const ExerciseLibraryPage({super.key});

  @override
  State<ExerciseLibraryPage> createState() => _ExerciseLibraryPageState();
}

class _ExerciseLibraryPageState extends State<ExerciseLibraryPage> {
  final ExerciseRepository _repository = ExerciseRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Exercise> _allExercises = [];
  List<Exercise> _filteredExercises = [];
  ExerciseCategory? _selectedCategory;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _allExercises = _repository.getAllExercises();
    _filteredExercises = _allExercises;
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
            exercise.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            exercise.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );

        final matchesCategory =
            _selectedCategory == null || exercise.category == _selectedCategory;

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
          'Exercise Library',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryFilter(),
          _buildExerciseCount(),
          Expanded(child: _buildExerciseList()),
        ],
      ),
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

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _buildCategoryChip(null, 'All'),
          ...ExerciseCategory.values.map(
            (category) => _buildCategoryChip(category, category.displayName),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(ExerciseCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedCategory = category;
          });
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
  }

  Widget _buildExerciseCount() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '${_filteredExercises.length} exercises',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    if (_filteredExercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No exercises found',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredExercises.length,
      itemBuilder: (context, index) {
        return _buildExerciseCard(_filteredExercises[index]);
      },
    );
  }

  Widget _buildExerciseCard(Exercise exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.cardBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showExerciseDetails(exercise),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Placeholder for GIF - will show icon for now
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    exercise.category.icon,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.muscleGroups
                          .map((m) => m.displayName)
                          .join(', '),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildTag(
                          exercise.category.displayName,
                          AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        _buildTag(
                          exercise.isTimeBased ? 'Time' : 'Reps',
                          AppColors.info,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _showExerciseDetails(Exercise exercise) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              exercise.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildTag(exercise.category.displayName, AppColors.success),
                const SizedBox(width: 8),
                ...exercise.muscleGroups
                    .take(3)
                    .map(
                      (m) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildTag(m.displayName, AppColors.info),
                      ),
                    ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              exercise.description,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // Placeholder for GIF animation
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      exercise.category.icon,
                      style: const TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'GIF Animation Coming Soon',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
