import 'package:fitness_app/core/entities/user_entity.dart';
import 'package:fitness_app/features/auth/domain/repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository repository;

  GetCurrentUser(this.repository);

  UserEntity? call() {
    return repository.getCurrentUser();
  }
}
