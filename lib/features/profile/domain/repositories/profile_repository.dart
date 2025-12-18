import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/profile/domain/entities/user_profile.dart';
import 'package:fpdart/fpdart.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserProfile?>> getProfile(String userId);
  Future<Either<Failure, void>> saveProfile(UserProfile profile);
}
