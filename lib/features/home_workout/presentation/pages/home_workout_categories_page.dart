import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/features/home_workout/presentation/pages/home_workout_page.dart';
import 'package:flutter/material.dart';

class HomeWorkoutCategoriesPage extends StatelessWidget {
  const HomeWorkoutCategoriesPage({super.key});

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
      ),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
          ],
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
