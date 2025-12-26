import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/features/profile/domain/entities/user_profile.dart'; // For ActivityLevel enum
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActivityStep extends StatelessWidget {
  final VoidCallback onNext;

  const ActivityStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text(
                "What's your activity level?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: ActivityLevel.values.map((level) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _ActivityCard(
                        level: level,
                        isSelected: state.activityLevel == level,
                        onTap: () => context.read<OnboardingBloc>().add(
                          ActivityLevelChanged(level),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: state.activityLevel != null ? onNext : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'NEXT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final ActivityLevel level;
  final bool isSelected;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.level,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            // Emoji/Icon placeholder
            Text(_getEmoji(level), style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Text(
              level.displayName,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEmoji(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.sedentary:
        return '🧑‍💻';
      case ActivityLevel.lightlyActive:
        return '🚶';
      case ActivityLevel.moderatelyActive:
        return '🏃';
      case ActivityLevel.veryActive:
        return '🏋️';
    }
  }
}
