import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/features/steps/presentation/bloc/steps_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;

class StepCounterCard extends StatelessWidget {
  final int goalSteps;

  const StepCounterCard({super.key, this.goalSteps = 10000});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StepsBloc, StepsState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildStepCounter(state),
              const SizedBox(height: 24),
              _buildProgressIndicator(state),
              const SizedBox(height: 16),
              _buildGoalInfo(state),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Today\'s Steps',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.white20,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department,
                color: AppColors.secondary,
                size: 18,
              ),
              const SizedBox(width: 4),
              const Text(
                'Active',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepCounter(StepsState state) {
    if (state is StepsLoading) {
      return const SizedBox(
        height: 80,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.white,
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (state is StepsError) {
      return SizedBox(
        height: 80,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.white70,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                'Error: ${state.message}',
                style: TextStyle(color: AppColors.white80, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final steps = state is StepsLoadSuccess ? state.stepRecord.steps : 0;

    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: steps),
      duration: const Duration(milliseconds: 1500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Icon(Icons.directions_walk, color: AppColors.white, size: 40),
            const SizedBox(width: 12),
            Text(
              _formatNumber(value),
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 56,
                fontWeight: FontWeight.bold,
                letterSpacing: -2,
              ),
            ),
            const SizedBox(width: 8),
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                'steps',
                style: TextStyle(
                  color: AppColors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProgressIndicator(StepsState state) {
    final steps = state is StepsLoadSuccess ? state.stepRecord.steps : 0;
    final progress = (steps / goalSteps).clamp(0.0, 1.0);

    return SizedBox(
      height: 120,
      width: 120,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: progress),
        duration: const Duration(milliseconds: 1500),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          return CustomPaint(
            painter: _CircularProgressPainter(
              progress: value,
              backgroundColor: AppColors.white20,
              progressColor: AppColors.secondary,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(value * 100).toInt()}%',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'of goal',
                    style: TextStyle(color: AppColors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGoalInfo(StepsState state) {
    final steps = state is StepsLoadSuccess ? state.stepRecord.steps : 0;
    final remaining = (goalSteps - steps).clamp(0, goalSteps);
    final calories = (steps * 0.04).toInt();
    final distance = (steps * 0.0008).toStringAsFixed(2);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          icon: Icons.flag,
          value: _formatNumber(remaining),
          label: 'To Goal',
        ),
        _buildStatItem(
          icon: Icons.local_fire_department,
          value: '$calories',
          label: 'Calories',
        ),
        _buildStatItem(
          icon: Icons.straighten,
          value: '$distance km',
          label: 'Distance',
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.white15,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: AppColors.white70, fontSize: 12)),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k'.replaceAll('.0k', 'k');
    }
    return number.toString();
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;

  _CircularProgressPainter({
    required this.progress,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 10.0;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
