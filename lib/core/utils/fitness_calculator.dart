import 'package:fitness_app/features/profile/domain/entities/user_profile.dart';

/// Utility class for accurate fitness calculations based on user profile
class FitnessCalculator {
  /// Default values for calculations when profile data is missing
  static const double defaultHeightCm = 170.0;
  static const double defaultWeightKg = 70.0;
  static const double defaultStrideMeters = 0.70;

  /// MET values for different walking intensities
  /// Source: Compendium of Physical Activities
  static const double slowWalkingMet = 2.8; // < 2.5 mph
  static const double normalWalkingMet = 3.5; // 2.5-3.5 mph (average pace)
  static const double briskWalkingMet = 4.3; // 3.5-4.0 mph
  static const double fastWalkingMet = 5.0; // > 4.0 mph

  /// Calculate stride length from height
  /// Formula: stride = height × 0.414 (research-backed average)
  static double getStrideLengthMeters(double? heightCm) {
    final height = heightCm ?? defaultHeightCm;
    return (height * 0.414) / 100; // Convert cm to meters
  }

  /// Calculate distance from steps using stride length
  /// Returns distance in kilometers
  static double getDistanceKm(
    int steps, {
    double? heightCm,
    UserProfile? profile,
  }) {
    final stride =
        profile?.strideLengthMeters ?? getStrideLengthMeters(heightCm);
    return (steps * stride) / 1000; // Convert meters to km
  }

  /// Calculate distance in meters
  static double getDistanceMeters(
    int steps, {
    double? heightCm,
    UserProfile? profile,
  }) {
    final stride =
        profile?.strideLengthMeters ?? getStrideLengthMeters(heightCm);
    return steps * stride;
  }

  /// Calculate calories burned using MET-based formula
  /// Formula: Calories = METs × 3.5 × Weight(kg) × Time(min) / 200
  ///
  /// For step-based estimation, we estimate time from steps and pace
  /// Average walking pace: ~100 steps/minute (normal walking)
  static double getCaloriesBurned(
    int steps, {
    double? weightKg,
    UserProfile? profile,
    double metValue = normalWalkingMet,
  }) {
    final weight = profile?.weightKg ?? weightKg ?? defaultWeightKg;

    // Estimate time in minutes (average 100 steps per minute)
    final timeMinutes = steps / 100.0;

    // MET formula: METs × 3.5 × weight(kg) × time(min) / 200
    return (metValue * 3.5 * weight * timeMinutes) / 200;
  }

  /// Alternative: Simple calorie calculation per step
  /// Formula accounts for weight (standardized to 70kg baseline)
  static double getCaloriesSimple(
    int steps, {
    double? weightKg,
    UserProfile? profile,
  }) {
    final weight = profile?.weightKg ?? weightKg ?? defaultWeightKg;

    // Base: ~0.04 calories per step for 70kg person
    // Adjusted by weight ratio
    final weightFactor = weight / 70.0;
    return steps * 0.04 * weightFactor;
  }

  /// Calculate active minutes from steps
  /// Based on average walking pace of ~100 steps/minute
  static int getActiveMinutes(int steps) {
    return (steps / 100).round();
  }

  /// Format distance with appropriate unit
  static String formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).toStringAsFixed(0)} m';
    }
    return '${km.toStringAsFixed(2)} km';
  }

  /// Format calories
  static String formatCalories(double calories) {
    return calories.toStringAsFixed(0);
  }
}
