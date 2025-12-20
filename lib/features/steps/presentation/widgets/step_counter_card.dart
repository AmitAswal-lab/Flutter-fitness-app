import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/features/profile/domain/entities/user_profile.dart';
import 'package:fitness_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fitness_app/features/steps/presentation/bloc/steps_bloc.dart';
import 'package:fitness_app/features/steps/presentation/pages/step_details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StepCounterCard extends StatelessWidget {
  final UserProfile? userProfile;

  const StepCounterCard({super.key, this.userProfile});

  int get goalSteps => userProfile?.stepGoal ?? 10000;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StepsBloc, StepsState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () => _navigateToDetails(context),
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryVariant],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(child: _buildStepContent(state)),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white54,
                  size: 32,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepContent(StepsState state) {
    if (state is StepsLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
      );
    }

    if (state is StepsError) {
      return Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white70, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Error loading steps',
              style: TextStyle(color: AppColors.white80, fontSize: 14),
            ),
          ),
        ],
      );
    }

    final steps = state is StepsLoadSuccess ? state.stepRecord.steps : 0;
    final progress = (steps / goalSteps).clamp(0.0, 1.0);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.directions_walk,
            color: Colors.white,
            size: 32,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Today's Steps",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: steps),
                duration: const Duration(milliseconds: 1000),
                builder: (context, value, child) {
                  return Text(
                    _formatNumber(value),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress >= 1.0 ? Colors.greenAccent : Colors.white,
                  ),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(progress * 100).toInt()}% of ${_formatNumber(goalSteps)} goal',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToDetails(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<StepsBloc>()),
            BlocProvider.value(value: context.read<ProfileBloc>()),
          ],
          child: StepDetailsPage(userProfile: userProfile),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(2)}k';
    }
    return number.toString();
  }
}
