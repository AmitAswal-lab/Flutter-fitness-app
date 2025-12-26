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

enum MainGoal {
  loseWeight,
  buildMuscle,
  keepFit;

  String get displayName {
    switch (this) {
      case MainGoal.loseWeight:
        return 'Lose Weight';
      case MainGoal.buildMuscle:
        return 'Build Muscle';
      case MainGoal.keepFit:
        return 'Keep Fit';
    }
  }

  String get id {
    switch (this) {
      case MainGoal.loseWeight:
        return 'lose_weight';
      case MainGoal.buildMuscle:
        return 'build_muscle';
      case MainGoal.keepFit:
        return 'keep_fit';
    }
  }

  static MainGoal fromId(String id) {
    return MainGoal.values.firstWhere(
      (e) => e.id == id,
      orElse: () => MainGoal.keepFit,
    );
  }
}

enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive;

  String get displayName {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'Sedentary';
      case ActivityLevel.lightlyActive:
        return 'Lightly Active';
      case ActivityLevel.moderatelyActive:
        return 'Moderately Active';
      case ActivityLevel.veryActive:
        return 'Very Active';
    }
  }

  String get id {
    switch (this) {
      case ActivityLevel.sedentary:
        return 'sedentary';
      case ActivityLevel.lightlyActive:
        return 'lightly_active';
      case ActivityLevel.moderatelyActive:
        return 'moderately_active';
      case ActivityLevel.veryActive:
        return 'very_active';
    }
  }

  static ActivityLevel fromId(String id) {
    return ActivityLevel.values.firstWhere(
      (e) => e.id == id,
      orElse: () => ActivityLevel.sedentary,
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

  // New Onboarding Fields
  final MainGoal? mainGoal;
  final ActivityLevel? activityLevel;
  final int? weeklyTrainingDays;
  const UserProfile({
    required this.userId,
    this.heightCm,
    this.weightKg,
    this.dateOfBirth,
    this.gender,
    this.stepGoal = 10000,
    this.fitnessLevel,
    this.mainGoal,
    this.activityLevel,
    this.weeklyTrainingDays,
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
      gender != null &&
      mainGoal != null &&
      activityLevel != null;

  @override
  List<Object?> get props => [
    userId,
    heightCm,
    weightKg,
    dateOfBirth,
    gender,
    stepGoal,
    fitnessLevel,
    mainGoal,
    activityLevel,
    weeklyTrainingDays,
  ];
}
