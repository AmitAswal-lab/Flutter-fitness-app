import 'package:fitness_app/features/steps/presentation/bloc/steps_bloc.dart';
import 'package:fitness_app/features/steps/presentation/widgets/step_counter_card.dart';
import 'package:fitness_app/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool _permissionGranted = false;
  bool _permissionChecked = false;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.activityRecognition.request();
    setState(() {
      _permissionGranted = status.isGranted;
      _permissionChecked = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionChecked) {
      return Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!_permissionGranted) {
      return Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.directions_walk, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'Activity Recognition Permission Required',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'This app needs permission to track your steps.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => openAppSettings(),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
