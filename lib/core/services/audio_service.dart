import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Service for handling audio feedback during workouts
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isInitialized = false;

  /// Initialize TTS settings
  Future<void> init() async {
    if (_isInitialized) return;

    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _isInitialized = true;
  }

  /// Speak the preparation announcement
  Future<void> speakPreparation(String exerciseName) async {
    await init();
    await _tts.speak('Get ready for $exerciseName');
  }

  /// Speak exercise start announcement
  Future<void> speakExerciseStart({
    required String exerciseName,
    int? durationSeconds,
    int? reps,
  }) async {
    await init();
    if (durationSeconds != null && durationSeconds > 0) {
      await _tts.speak('$exerciseName, $durationSeconds seconds');
    } else if (reps != null && reps > 0) {
      await _tts.speak('$exerciseName, $reps reps');
    } else {
      await _tts.speak(exerciseName);
    }
  }

  /// Speak rest phase announcement
  Future<void> speakRestStart(String nextExerciseName) async {
    await init();
    await _tts.speak('Rest. Next: $nextExerciseName');
  }

  /// Speak countdown number
  Future<void> speakCountdown(int number) async {
    await init();
    await _tts.speak('$number');
  }

  /// Speak workout complete
  Future<void> speakComplete() async {
    await init();
    await _tts.speak('Workout complete! Great job!');
  }

  /// Play a beep sound for countdown
  Future<void> playBeep() async {
    // Using a simple tone from the assets
    // For now, we'll use TTS as a fallback for the beep
    await init();
    await _tts.speak('beep');
  }

  /// Stop any ongoing speech
  Future<void> stop() async {
    await _tts.stop();
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _tts.stop();
    await _audioPlayer.dispose();
  }
}
