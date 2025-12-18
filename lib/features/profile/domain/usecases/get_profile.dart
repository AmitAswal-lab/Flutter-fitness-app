import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/profile/domain/entities/user_profile.dart';
import 'package:fitness_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetProfile {
  final ProfileRepository repository;

  GetProfile(this.repository);

  Future<Either<Failure, UserProfile?>> call(String userId) {
    return repository.getProfile(userId);
  }
}
