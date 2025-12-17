import 'package:fitness_app/features/steps/presentation/bloc/steps_bloc.dart';
import 'package:fitness_app/features/steps/presentation/widgets/step_counter_card.dart';
import 'package:fitness_app/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<StepsBloc>()..add(WatchStepsSpeed()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: const SingleChildScrollView(
          child: Column(children: [StepCounterCard()]),
        ),
      ),
    );
  }
}
