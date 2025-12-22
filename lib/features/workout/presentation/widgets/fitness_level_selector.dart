import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/features/profile/domain/entities/user_profile.dart';
import 'package:flutter/material.dart';

class FitnessLevelSelector extends StatelessWidget {
  final FitnessLevel? selectedLevel;
  final ValueChanged<FitnessLevel> onLevelSelected;

  const FitnessLevelSelector({
    super.key,
    required this.selectedLevel,
    required this.onLevelSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Select your experience level',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'We will adapt the workout difficulty to match your fitness level.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _buildOption(
          context,
          level: FitnessLevel.beginner,
          title: 'Beginner',
          description: 'Refined movements to build a solid foundation.',
          icon: '🌱',
        ),
        const SizedBox(height: 12),
        _buildOption(
          context,
          level: FitnessLevel.intermediate,
          title: 'Intermediate',
          description: 'Challenging workouts to push your limits.',
          icon: '🌿',
        ),
        const SizedBox(height: 12),
        _buildOption(
          context,
          level: FitnessLevel.advanced,
          title: 'Advanced',
          description: 'High-intensity sessions for elite performance.',
          icon: '🌳',
        ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required FitnessLevel level,
    required String title,
    required String description,
    required String icon,
  }) {
    final isSelected = selectedLevel == level;
    final borderColor = isSelected
        ? AppColors.primary
        : AppColors.textHint.withValues(alpha: 0.2);
    final backgroundColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.05)
        : Colors.white;

    return InkWell(
      onTap: () => onLevelSelected(level),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.primary : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
