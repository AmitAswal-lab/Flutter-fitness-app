import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/entities/user_entity.dart';
import 'package:fpdart/fpdart.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  Future<Either<Failure, void>> signOut();

  UserEntity? getCurrentUser();

  Stream<UserEntity?> get authStateChanges;
}
