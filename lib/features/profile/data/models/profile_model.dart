import 'package:fitness_app/features/profile/domain/entities/user_profile.dart';

class ProfileModel extends UserProfile {
  const ProfileModel({
    required super.userId,
    super.heightCm,
    super.weightKg,
    super.dateOfBirth,
    super.gender,
    super.stepGoal,
    super.fitnessLevel,
    super.mainGoal,
    super.activityLevel,
    super.weeklyTrainingDays,
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
      fitnessLevel: json['fitnessLevel'] != null
          ? FitnessLevel.fromId(json['fitnessLevel'] as String)
          : null,
      mainGoal: json['mainGoal'] != null
          ? MainGoal.fromId(json['mainGoal'] as String)
          : null,
      activityLevel: json['activityLevel'] != null
          ? ActivityLevel.fromId(json['activityLevel'] as String)
          : null,
      weeklyTrainingDays: json['weeklyTrainingDays'] as int?,
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
      'fitnessLevel': fitnessLevel?.id,
      'mainGoal': mainGoal?.id,
      'activityLevel': activityLevel?.id,
      'weeklyTrainingDays': weeklyTrainingDays,
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
      fitnessLevel: fitnessLevel,
      mainGoal: mainGoal,
      activityLevel: activityLevel,
      weeklyTrainingDays: weeklyTrainingDays,
    );
  }

  ProfileModel copyWith({
    String? userId,
    double? heightCm,
    double? weightKg,
    DateTime? dateOfBirth,
    String? gender,
    int? stepGoal,
    FitnessLevel? fitnessLevel,
    MainGoal? mainGoal,
    ActivityLevel? activityLevel,
    int? weeklyTrainingDays,
  }) {
    return ProfileModel(
      userId: userId ?? this.userId,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      stepGoal: stepGoal ?? this.stepGoal,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      mainGoal: mainGoal ?? this.mainGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      weeklyTrainingDays: weeklyTrainingDays ?? this.weeklyTrainingDays,
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
      fitnessLevel: entity.fitnessLevel,
      mainGoal: entity.mainGoal,
      activityLevel: entity.activityLevel,
      weeklyTrainingDays: entity.weeklyTrainingDays,
    );
  }
}
