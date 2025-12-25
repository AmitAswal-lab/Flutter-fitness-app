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
            ? _getWeeklyData(state.stepRecord, state.weeklyHistory)
            : _getEmptyWeekData();

        // Generate day labels for the last 7 days
        final dayLabels = _getDayLabels();

        // Calculate today's index (Mon=0, Sun=6)
        final todayIndex = DateTime.now().weekday - 1;

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
                    final isToday = index == todayIndex;
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
                  final isToday = index == todayIndex;
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

  /// Get day labels for Monday to Sunday
  List<String> _getDayLabels() {
    return ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  }

  List<StepRecord> _getWeeklyData(
    StepRecord currentRecord,
    List<StepRecord> history,
  ) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    // Find Monday of the current week (weekday 1 is Mon, 7 is Sun)
    final monday = todayStart.subtract(Duration(days: now.weekday - 1));

    final List<StepRecord> data = [];

    for (int i = 0; i < 7; i++) {
      final date = monday.add(Duration(days: i));

      if (date.isAtSameMomentAs(todayStart)) {
        // Today - use current record (realtime)
        data.add(currentRecord);
      } else if (date.isAfter(todayStart)) {
        // Future days - 0 steps
        data.add(StepRecord(steps: 0, timestamp: date));
      } else {
        // Past days - find matching record in history
        final record = history.firstWhere(
          (h) =>
              h.timestamp.year == date.year &&
              h.timestamp.month == date.month &&
              h.timestamp.day == date.day,
          orElse: () => StepRecord(steps: 0, timestamp: date),
        );
        data.add(record);
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
