import 'package:fitness_app/core/utils/device_utils.dart';
import 'package:fitness_app/core/widgets/lifecycle_observer.dart';
import 'package:fitness_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fitness_app/features/profile/domain/entities/user_profile.dart';
import 'package:fitness_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fitness_app/features/profile/presentation/pages/profile_page.dart';
import 'package:fitness_app/features/steps/presentation/bloc/steps_bloc.dart';
import 'package:fitness_app/features/steps/presentation/widgets/step_counter_card.dart';
import 'package:fitness_app/features/workout/presentation/bloc/workout_bloc.dart';
import 'package:fitness_app/features/workout/presentation/pages/workout_library_page.dart';
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
    // Skip permission request on simulator - auto-grant for testing
    if (DeviceUtils.isSimulatorSync) {
      setState(() {
        _permissionGranted = true;
        _permissionChecked = true;
      });
      return;
    }

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

    final authState = context.read<AuthBloc>().state;
    final userId = authState is AuthAuthenticated ? authState.user.uid : '';

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              sl<StepsBloc>()..add(WatchStepsSpeed(userId: userId)),
        ),
        BlocProvider(
          create: (context) =>
              sl<ProfileBloc>()..add(LoadProfile(userId: userId)),
        ),
        BlocProvider(create: (context) => sl<WorkoutBloc>()),
      ],
      child: _HomeContent(userId: userId),
    );
  }
}

/// Separate widget to access BLoC context for lifecycle refresh
class _HomeContent extends StatelessWidget {
  final String userId;

  const _HomeContent({required this.userId});

  @override
  Widget build(BuildContext context) {
    return LifecycleObserver(
      onResume: () {
        // Refresh steps when app comes back from background
        context.read<StepsBloc>().add(RefreshSteps(userId: userId));
        context.read<ProfileBloc>().add(LoadProfile(userId: userId));
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_outline),
              onPressed: () => _navigateToProfile(context),
              tooltip: 'Profile',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => _signOut(context),
              tooltip: 'Sign Out',
            ),
          ],
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, profileState) {
            UserProfile? profile;
            if (profileState is ProfileLoaded) {
              profile = profileState.profile;
            } else if (profileState is ProfileSaved) {
              profile = profileState.profile;
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  StepCounterCard(userProfile: profile),
                  _buildWorkoutCard(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: InkWell(
        onTap: () => _navigateToWorkouts(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Workouts',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Browse workout library',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToWorkouts(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<WorkoutBloc>(),
          child: const WorkoutLibraryPage(),
        ),
      ),
    );
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<AuthBloc>()),
            BlocProvider(create: (_) => sl<ProfileBloc>()),
          ],
          child: const ProfilePage(),
        ),
      ),
    );
  }

  void _signOut(BuildContext context) {
    context.read<AuthBloc>().add(AuthSignOutRequested());
  }
}
