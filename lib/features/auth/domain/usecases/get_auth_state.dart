import 'package:fitness_app/core/entities/user_entity.dart';
import 'package:fitness_app/features/auth/domain/repositories/auth_repository.dart';

class GetAuthState {
  final AuthRepository repository;

  GetAuthState(this.repository);

  Stream<UserEntity?> call() {
    return repository.authStateChanges;
  }
}
