import 'package:fitness_app/features/profile/domain/entities/user_profile.dart';

class ProfileModel extends UserProfile {
  const ProfileModel({
    required super.userId,
    super.heightCm,
    super.weightKg,
    super.dateOfBirth,
    super.gender,
    super.stepGoal,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      userId: json['userId'] as String,
      heightCm: json['heightCm'] != null
          ? (json['heightCm'] as num).toDouble()
          : null,
      weightKg: json['weightKg'] != null
          ? (json['weightKg'] as num).toDouble()
          : null,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'] as String)
          : null,
      gender: json['gender'] as String?,
      stepGoal: json['stepGoal'] as int? ?? 10000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'stepGoal': stepGoal,
    };
  }

  UserProfile toEntity() {
    return UserProfile(
      userId: userId,
      heightCm: heightCm,
      weightKg: weightKg,
      dateOfBirth: dateOfBirth,
      gender: gender,
      stepGoal: stepGoal,
    );
  }

  ProfileModel copyWith({
    String? userId,
    double? heightCm,
    double? weightKg,
    DateTime? dateOfBirth,
    String? gender,
    int? stepGoal,
  }) {
    return ProfileModel(
      userId: userId ?? this.userId,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      stepGoal: stepGoal ?? this.stepGoal,
    );
  }

  factory ProfileModel.fromEntity(UserProfile entity) {
    return ProfileModel(
      userId: entity.userId,
      heightCm: entity.heightCm,
      weightKg: entity.weightKg,
      dateOfBirth: entity.dateOfBirth,
      gender: entity.gender,
      stepGoal: entity.stepGoal,
    );
  }
}
