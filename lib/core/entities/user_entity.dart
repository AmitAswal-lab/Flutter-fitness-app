import 'package:equatable/equatable.dart';

/// Core user entity for authentication.
/// Contains only auth-related fields.
/// Fitness-related fields (height, weight, etc.) belong in the profile feature.
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [uid, email, displayName, photoUrl];
}
