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
  //External - must be registered first
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  //DataSources
  sl.registerLazySingleton<StepLocalDatasource>(
    () => StepLocalDatasourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<PedometerDataSource>(
    () => PedometerDataSourceImpl(),
  );

  //Repositories
  sl.registerLazySingleton<StepsRepository>(
    () => StepRepositoryImpl(
      pedometerDatasource: sl(),
      stepLocalDatasource: sl(),
    ),
  );

  //UseCases
  sl.registerLazySingleton(() => GetStepStream(sl()));
  sl.registerLazySingleton(() => GetDailySteps(sl()));
  sl.registerLazySingleton(() => GetWeeklySteps(sl()));

  //Bloc
  sl.registerFactory(() => StepsBloc(getStepStream: sl()));
}
