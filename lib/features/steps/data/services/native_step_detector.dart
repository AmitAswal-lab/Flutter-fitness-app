import 'dart:async';

import 'package:flutter/services.dart';

/// Native Android Step Detector wrapper
/// Uses Android's TYPE_STEP_DETECTOR sensor (hardware ML-based detection)
/// This is what Google Fit uses - highly accurate, no false positives
class NativeStepDetector {
  static const MethodChannel _channel = MethodChannel(
    'com.example.fitness_app/step_detector',
  );
  static const EventChannel _eventChannel = EventChannel(
    'com.example.fitness_app/step_events',
  );

  static Stream<Map<String, dynamic>>? _stepStream;

  /// Check if step detector is available on this device
  static Future<bool> isAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Start listening for step events
  static Future<bool> startListening() async {
    try {
      final result = await _channel.invokeMethod<bool>('startListening');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Stop listening for step events
  static Future<bool> stopListening() async {
    try {
      final result = await _channel.invokeMethod<bool>('stopListening');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get current step count
  static Future<int> getStepCount() async {
    try {
      final result = await _channel.invokeMethod<int>('getStepCount');
      return result ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Reset step count to zero
  static Future<bool> resetStepCount() async {
    try {
      final result = await _channel.invokeMethod<bool>('resetStepCount');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Stream of step events from native detector
  static Stream<Map<String, dynamic>> get stepStream {
    _stepStream ??= _eventChannel.receiveBroadcastStream().map(
      (event) => Map<String, dynamic>.from(event as Map),
    );
    return _stepStream!;
  }
}
