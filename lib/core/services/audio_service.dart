import 'package:audio_session/audio_session.dart' as audio_session;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Service for handling audio feedback during workouts
/// Uses audio_session for proper coordination between TTS and background music
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _musicPlayer = AudioPlayer();
  audio_session.AudioSession? _audioSession;
  bool _isInitialized = false;
  bool _isMusicPlaying = false;
  double _musicVolume = 0.4;

  /// Check if music is currently playing
  bool get isMusicPlaying => _isMusicPlaying;

  /// Initialize audio session, TTS and music player
  Future<void> init() async {
    if (_isInitialized) return;

    // Configure the audio session for mixing audio
    _audioSession = await audio_session.AudioSession.instance;
    await _audioSession!.configure(
      audio_session.AudioSessionConfiguration(
        avAudioSessionCategory: audio_session.AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            audio_session.AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: audio_session.AVAudioSessionMode.defaultMode,
        androidAudioAttributes: const audio_session.AndroidAudioAttributes(
          contentType: audio_session.AndroidAudioContentType.music,
          usage: audio_session.AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType:
            audio_session.AndroidAudioFocusGainType.gainTransientMayDuck,
        androidWillPauseWhenDucked: false,
      ),
    );

    // Configure TTS
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.awaitSpeakCompletion(true);

    // Configure music player
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(_musicVolume);

    _isInitialized = true;
  }

  /// Speak the preparation announcement
  Future<void> speakPreparation(String workoutName) async {
    await init();
    await _tts.speak('Get ready for $workoutName');
  }

  /// Speak exercise start announcement
  Future<void> speakExerciseStart({
    required String exerciseName,
    int? durationSeconds,
    int? reps,
  }) async {
    await init();

    String text;
    if (durationSeconds != null && durationSeconds > 0) {
      text = '$exerciseName, $durationSeconds seconds';
    } else if (reps != null && reps > 0) {
      text = '$exerciseName, $reps reps';
    } else {
      text = exerciseName;
    }

    await _tts.speak(text);
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
    await stopBackgroundMusic();
    await _tts.speak('Workout complete! Great job!');
  }

  /// Play a beep sound for countdown
  Future<void> playBeep() async {
    await init();
    await _tts.speak('beep');
  }

  /// Stop any ongoing speech
  Future<void> stop() async {
    await _tts.stop();
  }

  // ========== Background Music Methods ==========

  /// Start playing background music
  Future<void> startBackgroundMusic() async {
    await init();
    try {
      await _musicPlayer.play(
        UrlSource(
          'https://cdn.pixabay.com/download/audio/2022/03/15/audio_8cb749d484.mp3',
        ),
      );
      _isMusicPlaying = true;
    } catch (e) {
      _isMusicPlaying = false;
    }
  }

  /// Stop background music
  Future<void> stopBackgroundMusic() async {
    await _musicPlayer.stop();
    _isMusicPlaying = false;
  }

  /// Toggle background music
  Future<void> toggleBackgroundMusic() async {
    if (_isMusicPlaying) {
      await stopBackgroundMusic();
    } else {
      await startBackgroundMusic();
    }
  }

  /// Set music volume (0.0 to 1.0)
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume.clamp(0.0, 1.0);
    await _musicPlayer.setVolume(_musicVolume);
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _tts.stop();
    await _musicPlayer.dispose();
  }
}
