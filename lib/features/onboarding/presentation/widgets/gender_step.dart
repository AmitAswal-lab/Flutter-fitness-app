import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GenderStep extends StatelessWidget {
  final VoidCallback onNext;

  const GenderStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardingBloc, OnboardingState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              const Text(
                "What's your gender?",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Let us know you better",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _GenderCard(
                      label: 'Male',
                      icon: Icons.male, // Placeholder for image
                      isSelected: state.gender == 'male',
                      onTap: () => context.read<OnboardingBloc>().add(
                        const GenderChanged('male'),
                      ),
                    ),
                    const SizedBox(width: 24),
                    _GenderCard(
                      label: 'Female',
                      icon: Icons.female, // Placeholder for image
                      isSelected: state.gender == 'female',
                      onTap: () => context.read<OnboardingBloc>().add(
                        const GenderChanged('female'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: state.gender != null ? onNext : null,
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
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

class _GenderCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 120, // Adjust based on screen size ideally
            height: 300,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.grey[200],
              shape: BoxShape
                  .circle, // Temporary: Circle for icon. User design has full body image.
              // In real app, use Image.asset here
            ),
            child: Icon(
              icon,
              size: 64,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
