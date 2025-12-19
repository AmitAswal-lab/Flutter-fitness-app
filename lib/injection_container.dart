import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fitness_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fitness_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fitness_app/features/auth/domain/usecases/get_auth_state.dart';
import 'package:fitness_app/features/auth/domain/usecases/get_current_user.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_in.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_out.dart';
import 'package:fitness_app/features/auth/domain/usecases/sign_up.dart';
import 'package:fitness_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fitness_app/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:fitness_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:fitness_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:fitness_app/features/profile/domain/usecases/get_profile.dart';
import 'package:fitness_app/features/profile/domain/usecases/save_profile.dart';
import 'package:fitness_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:fitness_app/features/steps/data/datasources/pedometer_datasource.dart';
import 'package:fitness_app/features/steps/data/datasources/step_local_datasource.dart';
import 'package:fitness_app/features/steps/data/repositories/step_repository_impl.dart';
import 'package:fitness_app/features/steps/domain/repositories/step_repository.dart';
import 'package:fitness_app/features/steps/domain/usecases/get_daily_steps.dart';
import 'package:fitness_app/features/steps/domain/usecases/get_step_stream.dart';
import 'package:fitness_app/features/steps/domain/usecases/get_weekly_steps.dart';
import 'package:fitness_app/features/steps/presentation/bloc/steps_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //=== External ===
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => FirebaseAuth.instance);

  //=== Auth Feature ===
  // DataSources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => SignIn(sl()));
  sl.registerLazySingleton(() => SignUp(sl()));
  sl.registerLazySingleton(() => SignOut(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => GetAuthState(sl()));

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      signIn: sl(),
      signUp: sl(),
      signOutUseCase: sl(),
      getCurrentUser: sl(),
      getAuthState: sl(),
    ),
  );

  //=== Steps Feature ===
  // DataSources
  sl.registerLazySingleton<StepLocalDatasource>(
    () => StepLocalDatasourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<PedometerDataSource>(
    () => PedometerDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<StepsRepository>(
    () => StepRepositoryImpl(
      pedometerDatasource: sl(),
      stepLocalDatasource: sl(),
    ),
  );

  // UseCases
  sl.registerLazySingleton(() => GetStepStream(sl()));
  sl.registerLazySingleton(() => GetDailySteps(sl()));
  sl.registerLazySingleton(() => GetWeeklySteps(sl()));

  // Bloc
  sl.registerFactory(() => StepsBloc(getStepStream: sl()));

  //=== Profile Feature ===
  // DataSources
  sl.registerLazySingleton<ProfileLocalDataSource>(
    () => ProfileLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Repositories
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(localDataSource: sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => GetProfile(sl()));
  sl.registerLazySingleton(() => SaveProfile(sl()));

  // Bloc
  sl.registerFactory(() => ProfileBloc(getProfile: sl(), saveProfile: sl()));
}
