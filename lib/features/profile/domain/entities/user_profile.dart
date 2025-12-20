import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String userId;
  final double? heightCm;
  final double? weightKg;
  final DateTime? dateOfBirth;
  final String? gender; // 'male', 'female', 'other'
  final int stepGoal;

  const UserProfile({
    required this.userId,
    this.heightCm,
    this.weightKg,
    this.dateOfBirth,
    this.gender,
    this.stepGoal = 10000,
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
      gender != null;

  @override
  List<Object?> get props => [
    userId,
    heightCm,
    weightKg,
    dateOfBirth,
    gender,
    stepGoal,
  ];
}
