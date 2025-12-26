import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MeasurementsStep extends StatelessWidget {
  final VoidCallback onNext;

  const MeasurementsStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text(
                "Let us know you better",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Help boost your workout results",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Weight Section
              _MeasurementSection(
                label: 'Weight',
                value: state.weight,
                unit: state.isKg ? 'kg' : 'lbs',
                isMetric: state.isKg,
                onUnitChanged: (isMetric) => context.read<OnboardingBloc>().add(
                  WeightUnitChanged(isMetric),
                ),
                onValueChanged: (val) =>
                    context.read<OnboardingBloc>().add(WeightChanged(val)),
                min: 30,
                max: 150, // Kg range roughly
              ),

              const Divider(height: 48),

              // Height Section
              _MeasurementSection(
                label: 'Height',
                value: state.height,
                unit: state.isCm ? 'cm' : 'ft',
                isMetric: state.isCm,
                onUnitChanged: (isMetric) => context.read<OnboardingBloc>().add(
                  HeightUnitChanged(isMetric),
                ),
                onValueChanged: (val) =>
                    context.read<OnboardingBloc>().add(HeightChanged(val)),
                min: 100,
                max: 250, // cm range roughly
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: state.status == OnboardingStatus.submitting
                      ? null
                      : onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: state.status == OnboardingStatus.submitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'GET MY PLAN',
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

class _MeasurementSection extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final bool isMetric;
  final ValueChanged<bool> onUnitChanged;
  final ValueChanged<double> onValueChanged;
  final double min;
  final double max;

  const _MeasurementSection({
    required this.label,
    required this.value,
    required this.unit,
    required this.isMetric,
    required this.onUnitChanged,
    required this.onValueChanged,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                _UnitToggle(
                  label: label == 'Weight' ? 'kg' : 'cm',
                  isSelected: isMetric,
                  onTap: () => onUnitChanged(true),
                ),
                const SizedBox(width: 8),
                _UnitToggle(
                  label: label == 'Weight' ? 'lbs' : 'ft',
                  isSelected: !isMetric,
                  onTap: () => onUnitChanged(false),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '${value.toStringAsFixed(1)} $unit',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Slider(
          value: value,
          max: isMetric ? max : (label == 'Weight' ? 330 : 8.5),
          min: isMetric ? min : (label == 'Weight' ? 66 : 3.0),
          onChanged: onValueChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }
}

class _UnitToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _UnitToggle({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
