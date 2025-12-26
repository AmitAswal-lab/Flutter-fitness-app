import 'package:fitness_app/core/constants/app_colors.dart';
import 'package:fitness_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:fitness_app/features/onboarding/presentation/widgets/gender_step.dart';
import 'package:fitness_app/features/onboarding/presentation/widgets/goal_step.dart';
import 'package:fitness_app/features/onboarding/presentation/widgets/activity_step.dart';
import 'package:fitness_app/features/onboarding/presentation/widgets/weekly_goal_step.dart';
import 'package:fitness_app/features/onboarding/presentation/widgets/measurements_step.dart';
import 'package:fitness_app/features/auth/presentation/pages/auth_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // If can pop, pop. Else do nothing (forcing user to complete).
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OnboardingBloc, OnboardingState>(
      listener: (context, state) {
        if (state.status == OnboardingStatus.success) {
          // Navigate to AuthWrapper which will now redirect to Home
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AuthWrapper()),
          );
        } else if (state.status == OnboardingStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'An error occurred')),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: _prevPage,
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Skip - Navigate to AuthWrapper/Home
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const AuthWrapper()),
                );
              },
              child: const Text('Skip', style: TextStyle(color: Colors.grey)),
            ),
          ],
          title: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_currentPage + 1) / _totalPages,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable swipe to enforce validation/flow
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  GenderStep(onNext: _nextPage),
                  GoalStep(onNext: _nextPage),
                  ActivityStep(onNext: _nextPage),
                  WeeklyGoalStep(onNext: _nextPage),
                  MeasurementsStep(
                    onNext: () {
                      context.read<OnboardingBloc>().add(
                        const SubmitOnboarding(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
