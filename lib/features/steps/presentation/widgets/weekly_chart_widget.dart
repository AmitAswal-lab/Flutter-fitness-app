import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/features/steps/domain/entities/step_record.dart';
import 'package:fitness_app/features/steps/presentation/bloc/steps_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WeeklyChartWidget extends StatelessWidget {
  final int goalSteps;

  const WeeklyChartWidget({super.key, this.goalSteps = 10000});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StepsBloc, StepsState>(
      builder: (context, state) {
        // Get weekly history from bloc if available
        final List<StepRecord> weeklyData = state is StepsLoadSuccess
            ? _getWeeklyData(state.stepRecord)
            : _getEmptyWeekData();

        // Generate day labels for the last 7 days
        final dayLabels = _getDayLabels();

        return SizedBox(
          height: 180,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: weeklyData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final record = entry.value;
                    final isToday = index == 6; // Last bar is always today
                    return _buildBar(record.steps, isToday);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: dayLabels.asMap().entries.map((entry) {
                  final index = entry.key;
                  final day = entry.value;
                  final isToday = index == 6; // Last label is always today
                  return SizedBox(
                    width: 36,
                    child: Text(
                      day,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isToday ? AppColors.primary : Colors.grey[600],
                        fontWeight: isToday
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBar(int steps, bool isToday) {
    final maxHeight = 120.0;
    final percentage = (steps / goalSteps).clamp(0.0, 1.0);
    final height = (percentage * maxHeight).clamp(8.0, maxHeight);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (steps > 0)
          Text(
            _formatCompact(steps),
            style: TextStyle(
              fontSize: 10,
              color: isToday ? AppColors.primary : Colors.grey[600],
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        const SizedBox(height: 4),
        Container(
          width: 36,
          height: height,
          decoration: BoxDecoration(
            color: isToday
                ? AppColors.primary
                : percentage >= 1.0
                ? Colors.green
                : AppColors.primary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  /// Get day labels for the last 7 days (ending with today)
  List<String> _getDayLabels() {
    const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final now = DateTime.now();
    final labels = <String>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      // DateTime.weekday: Monday = 1, Sunday = 7
      // We need index: Monday = 0, Sunday = 6
      final dayIndex = date.weekday - 1;
      labels.add(dayNames[dayIndex]);
    }

    return labels;
  }

  List<StepRecord> _getWeeklyData(StepRecord currentRecord) {
    // Show last 7 days, with today's actual count at the end
    final now = DateTime.now();
    final List<StepRecord> data = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));
      if (i == 0) {
        // Today - use current record
        data.add(currentRecord);
      } else {
        // Placeholder - in real app, fetch from history
        data.add(StepRecord(steps: 0, timestamp: date));
      }
    }

    return data;
  }

  List<StepRecord> _getEmptyWeekData() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - i));
      return StepRecord(steps: 0, timestamp: date);
    });
  }

  String _formatCompact(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k'.replaceAll('.0k', 'k');
    }
    return number.toString();
  }
}
