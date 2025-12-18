import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/profile/domain/entities/user_profile.dart';
import 'package:fitness_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class SaveProfile {
  final ProfileRepository repository;

  SaveProfile(this.repository);

  Future<Either<Failure, void>> call(UserProfile profile) {
    return repository.saveProfile(profile);
  }
}
