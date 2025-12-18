import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:fitness_app/features/profile/data/models/profile_model.dart';
import 'package:fitness_app/features/profile/domain/entities/user_profile.dart';
import 'package:fitness_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:fpdart/fpdart.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileLocalDataSource localDataSource;

  ProfileRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, UserProfile?>> getProfile(String userId) async {
    try {
      final profile = await localDataSource.getProfile(userId);
      return Right(profile?.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveProfile(UserProfile profile) async {
    try {
      final profileModel = ProfileModel.fromEntity(profile);
      await localDataSource.saveProfile(profileModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
