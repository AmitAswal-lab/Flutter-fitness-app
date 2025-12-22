import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/features/profile/domain/entities/user_profile.dart';
import 'package:fitness_app/features/profile/domain/usecases/get_profile.dart';
import 'package:fitness_app/features/profile/domain/usecases/save_profile.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise.dart';
import 'package:fitness_app/features/workout/domain/entities/workout_template.dart';
import 'package:fitness_app/features/workout/domain/services/workout_adapter_service.dart';
import 'package:fitness_app/features/workout/presentation/pages/active_workout_page.dart';
import 'package:fitness_app/features/workout/presentation/widgets/fitness_level_selector.dart';
import 'package:fitness_app/injection_container.dart';
import 'package:flutter/material.dart';

class WorkoutDetailPage extends StatefulWidget {
  final WorkoutTemplate workout;
  final String userId;

  const WorkoutDetailPage({
    super.key,
    required this.workout,
    required this.userId,
  });

  @override
  State<WorkoutDetailPage> createState() => _WorkoutDetailPageState();
}

class _WorkoutDetailPageState extends State<WorkoutDetailPage> {
  late WorkoutTemplate _displayedWorkout;
  UserProfile? _userProfile;
  final _workoutAdapter = WorkoutAdapterService();
  bool _isAdapted = false;

  @override
  void initState() {
    super.initState();
    _displayedWorkout = widget.workout;
    _checkFitnessLevel();
  }

  Future<void> _checkFitnessLevel() async {
    final getProfile = sl<GetProfile>();
    final result = await getProfile(widget.userId);

    result.fold(
      (failure) {
        // Even on failure, show selector for new users
        if (mounted) {
          _showFitnessLevelSelectorForNewUser();
        }
      },
      (profile) async {
        if (profile == null) {
          // New user without profile - show selector
          if (mounted) {
            await _showFitnessLevelSelectorForNewUser();
          }
          return;
        }

        setState(() => _userProfile = profile);

        if (profile.fitnessLevel == null) {
          // Existing user without fitness level set
          if (mounted) {
            await _showFitnessLevelSelector(profile);
          }
        } else {
          _adaptWorkout(profile);
        }
      },
    );
  }

  Future<void> _showFitnessLevelSelectorForNewUser() async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: FitnessLevelSelector(
          selectedLevel: null,
          onLevelSelected: (level) {
            _createProfileWithFitnessLevel(level);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _createProfileWithFitnessLevel(FitnessLevel level) async {
    // Create a new minimal profile with just userId and fitnessLevel
    final newProfile = UserProfile(userId: widget.userId, fitnessLevel: level);

    final saveProfile = sl<SaveProfile>();
    await saveProfile(newProfile);

    setState(() => _userProfile = newProfile);
    _adaptWorkout(newProfile);
  }

  Future<void> _showFitnessLevelSelector(UserProfile profile) async {
    // Wait for frame to ensure context is valid
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: FitnessLevelSelector(
          selectedLevel: null,
          onLevelSelected: (level) {
            _saveFitnessLevel(profile, level);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> _saveFitnessLevel(
    UserProfile profile,
    FitnessLevel level,
  ) async {
    // 1. Create updated profile entity
    final updatedProfile = UserProfile(
      userId: profile.userId,
      heightCm: profile.heightCm,
      weightKg: profile.weightKg,
      dateOfBirth: profile.dateOfBirth,
      gender: profile.gender,
      stepGoal: profile.stepGoal,
      fitnessLevel: level,
    );

    // 2. Save it
    final saveProfile = sl<SaveProfile>();
    await saveProfile(updatedProfile);

    // 3. Update local state and adapt
    setState(() => _userProfile = updatedProfile);
    _adaptWorkout(updatedProfile);
  }

  void _adaptWorkout(UserProfile profile) {
    if (profile.fitnessLevel == null) return;

    final adapted = _workoutAdapter.adaptWorkout(widget.workout, profile);
    setState(() {
      _displayedWorkout = adapted;
      _isAdapted = _displayedWorkout != widget.workout;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: _buildHeader()),
          SliverToBoxAdapter(child: _buildExerciseHeader()),
          _buildExerciseList(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: _buildStartButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _displayedWorkout.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryVariant],
            ),
          ),
          child: Center(
            child: Text(
              _displayedWorkout.category.icon,
              style: const TextStyle(fontSize: 80),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _displayedWorkout.description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          if (_isAdapted && _userProfile?.fitnessLevel != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Adapted for your ${_userProfile!.fitnessLevel!.displayName} level',
                      style: const TextStyle(
                        color: AppColors.info,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              _buildStatCard(
                icon: Icons.timer,
                value: '${_displayedWorkout.estimatedMinutes}',
                label: 'Minutes',
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.fitness_center,
                value: '${_displayedWorkout.exercises.length}',
                label: 'Exercises',
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.repeat,
                value: '${_displayedWorkout.totalSets}',
                label: 'Total Sets',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Row(
        children: [
          const Text(
            'Exercises',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(
            '${_displayedWorkout.exercises.length} total',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final workoutExercise = _displayedWorkout.exercises[index];
        bool isChanged = false;

        // Visual indicator if sets/reps changed from original (simple check)
        if (index < widget.workout.exercises.length) {
          final original = widget.workout.exercises[index];
          isChanged =
              workoutExercise.sets != original.sets ||
              workoutExercise.reps != original.reps ||
              workoutExercise.durationSeconds != original.durationSeconds;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: isChanged
                ? Border.all(
                    color: AppColors.info.withValues(alpha: 0.3),
                    width: 1,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isChanged
                      ? AppColors.info.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isChanged ? AppColors.info : AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      workoutExercise.exercise.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getExerciseDetail(workoutExercise),
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              if (isChanged)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: AppColors.info,
                  ),
                ),
              Icon(
                workoutExercise.exercise.isTimeBased
                    ? Icons.timer
                    : Icons.repeat,
                color: Colors.grey[400],
                size: 20,
              ),
            ],
          ),
        );
      }, childCount: _displayedWorkout.exercises.length),
    );
  }

  String _getExerciseDetail(WorkoutExercise we) {
    if (we.exercise.isTimeBased) {
      return '${we.sets} sets × ${we.durationSeconds}s';
    }
    return '${we.sets} sets × ${we.reps} reps';
  }

  Widget _buildStartButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () => _startWorkout(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow, size: 28),
              SizedBox(width: 8),
              Text(
                'Start Workout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startWorkout(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ActiveWorkoutPage(
          workout: _displayedWorkout,
          userId: widget.userId,
        ),
      ),
    );
  }
}
