import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;

  // Fitness-related fields for personalized calculations
  final double? heightCm; // Height in centimeters
  final double? weightKg; // Weight in kilograms
  final DateTime? dateOfBirth;
  final String? gender; // 'male', 'female', 'other'

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.heightCm,
    this.weightKg,
    this.dateOfBirth,
    this.gender,
  });

  /// Calculate stride length based on height (average formula)
  double get strideLengthMeters {
    if (heightCm == null) return 0.762; // default ~30 inches
    return (heightCm! * 0.415) / 100; // walking stride
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

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    photoUrl,
    heightCm,
    weightKg,
    dateOfBirth,
    gender,
  ];
}
