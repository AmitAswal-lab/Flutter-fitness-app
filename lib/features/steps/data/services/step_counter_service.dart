import 'dart:async';

import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'native_step_detector.dart';

/// Service that runs step counting in the background using a foreground service.
/// Uses Android's native TYPE_STEP_DETECTOR sensor (hardware ML-based detection)
/// The native Kotlin code stores steps in SharedPreferences, which we read here.
class StepCounterService {
  static const String stepCountKey = 'background_step_count';
  static const String lastDateKey = 'background_step_date';
  static const String nativeStepKey = 'native_step_count';
  static const String nativeDateKey = 'native_step_date';

  static void init() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'step_counter_channel',
        channelName: 'Step Counter',
        channelDescription: 'Counts your steps in the background',
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(1000),
        autoRunOnBoot: true,
        autoRunOnMyPackageReplaced: true,
        allowWakeLock: true,
        allowWifiLock: false,
      ),
    );
  }

  static Future<void> requestPermissions() async {
    final notificationPermission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  static Future<ServiceRequestResult> startService() async {
    // Start native step detector in MainActivity
    await NativeStepDetector.startListening();

    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    }
    return FlutterForegroundTask.startService(
      notificationTitle: 'Step Counter Active',
      notificationText: 'Counting your steps...',
      callback: startCallback,
    );
  }

  static Future<ServiceRequestResult> stopService() {
    return FlutterForegroundTask.stopService();
  }

  static Future<bool> get isRunning => FlutterForegroundTask.isRunningService;

  static Future<int> getStepCount() async {
    final prefs = await SharedPreferences.getInstance();
    // Read from native step count (written by Kotlin)
    return prefs.getInt(nativeStepKey) ?? 0;
  }

  static Future<bool> isDetectorAvailable() {
    return NativeStepDetector.isAvailable();
  }
}

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(StepCounterTaskHandler());
}

/// Step counter that reads from native Android TYPE_STEP_DETECTOR
/// The native Kotlin code runs in MainActivity and stores steps in SharedPreferences
/// This task handler just polls SharedPreferences and broadcasts updates
class StepCounterTaskHandler extends TaskHandler {
  int _lastKnownSteps = 0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // Read current step count from SharedPreferences (set by native Kotlin)
    _lastKnownSteps = await _getNativeStepCount();
    _updateNotification();
    FlutterForegroundTask.sendDataToMain({'steps': _lastKnownSteps});
  }

  Future<int> _getNativeStepCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // Reload to get latest from native
    return prefs.getInt('native_step_count') ?? 0;
  }

  void _updateNotification() {
    FlutterForegroundTask.updateService(
      notificationTitle: 'Step Counter Active',
      notificationText: '$_lastKnownSteps steps today',
    );
  }

  @override
  void onRepeatEvent(DateTime timestamp) async {
    // Poll SharedPreferences for updated step count from native
    final currentSteps = await _getNativeStepCount();

    if (currentSteps != _lastKnownSteps) {
      _lastKnownSteps = currentSteps;
      _updateNotification();
    }

    FlutterForegroundTask.sendDataToMain({'steps': _lastKnownSteps});
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    // Native detector continues to run in MainActivity
  }

  @override
  void onReceiveData(Object data) {}

  @override
  void onNotificationButtonPressed(String id) {}

  @override
  void onNotificationPressed() {
    FlutterForegroundTask.launchApp();
  }

  @override
  void onNotificationDismissed() {}
}
