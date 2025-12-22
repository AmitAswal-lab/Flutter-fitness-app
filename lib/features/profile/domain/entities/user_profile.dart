import 'package:equatable/equatable.dart';

enum FitnessLevel {
  beginner,
  intermediate,
  advanced;

  String get displayName {
    switch (this) {
      case FitnessLevel.beginner:
        return 'Noob';
      case FitnessLevel.intermediate:
        return 'Master';
      case FitnessLevel.advanced:
        return 'Elite';
    }
  }

  String get id {
    switch (this) {
      case FitnessLevel.beginner:
        return 'beginner';
      case FitnessLevel.intermediate:
        return 'intermediate';
      case FitnessLevel.advanced:
        return 'advanced';
    }
  }

  static FitnessLevel fromId(String id) {
    return FitnessLevel.values.firstWhere(
      (e) => e.id == id,
      orElse: () => FitnessLevel.beginner,
    );
  }
}

class UserProfile extends Equatable {
  final String userId;
  final double? heightCm;
  final double? weightKg;
  final DateTime? dateOfBirth;
  final String? gender; // 'male', 'female', 'other'
  final int stepGoal;
  final FitnessLevel? fitnessLevel;

  const UserProfile({
    required this.userId,
    this.heightCm,
    this.weightKg,
    this.dateOfBirth,
    this.gender,
    this.stepGoal = 10000,
    this.fitnessLevel,
  });

  /// Calculate stride length based on height (walking formula)
  double get strideLengthMeters {
    if (heightCm == null) return 0.762; // default ~30 inches
    return (heightCm! * 0.415) / 100;
  }

  /// Calculate age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Calculate BMI (Body Mass Index)
  double? get bmi {
    if (heightCm == null || weightKg == null) return null;
    final heightM = heightCm! / 100;
    return weightKg! / (heightM * heightM);
  }

  /// Check if profile is complete
  bool get isComplete =>
      heightCm != null &&
      weightKg != null &&
      dateOfBirth != null &&
      gender != null &&
      fitnessLevel != null;

  @override
  List<Object?> get props => [
    userId,
    heightCm,
    weightKg,
    dateOfBirth,
    gender,
    stepGoal,
    fitnessLevel,
  ];
}
