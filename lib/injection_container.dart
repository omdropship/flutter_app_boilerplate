import 'package:get_it/get_it.dart';
import 'core/cache/cache_manager.dart';
import 'core/network/dio_client.dart';
import 'core/navigation/navigation_manager.dart';
import 'config/routes/app_router.dart';

// Features
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/logout_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/settings/presentation/bloc/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  //==============================
  // CORE
  //==============================
  sl.registerLazySingleton<CacheManager>(() => CacheManager.instance);
  sl.registerLazySingleton<DioClient>(() => DioClient.instance);
  sl.registerLazySingleton<NavigationManager>(() => NavigationManager.instance);
  sl.registerLazySingleton<AppRouter>(() => AppRouter());

  //==============================
  // FEATURES
  //==============================
  await _initAuthFeature();
  await _initSettingsFeature();
}

Future<void> _initAuthFeature() async {
  // BLoC - Factory (new instance each time)
  sl.registerFactory<AuthBloc>(() => AuthBloc(
        loginUser: sl(),
        registerUser: sl(),
        logoutUser: sl(),
        getCurrentUser: sl(),
      ));

  // UseCases - LazySingleton
  sl.registerLazySingleton<LoginUser>(() => LoginUser(sl()));
  sl.registerLazySingleton<RegisterUser>(() => RegisterUser(sl()));
  sl.registerLazySingleton<LogoutUser>(() => LogoutUser(sl()));
  sl.registerLazySingleton<GetCurrentUser>(() => GetCurrentUser(sl()));

  // Repository - LazySingleton
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        dioClient: sl(),
      ));

  // DataSources - LazySingleton
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(cacheManager: sl()),
  );
}

Future<void> _initSettingsFeature() async {
  // Cubit - Factory
  sl.registerFactory<ThemeCubit>(() => ThemeCubit(sl()));
}
