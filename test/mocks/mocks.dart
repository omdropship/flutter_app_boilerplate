import 'package:mocktail/mocktail.dart';
import 'package:flutter_app_boilerplate/core/cache/cache_manager.dart';
import 'package:flutter_app_boilerplate/core/network/dio_client.dart';
import 'package:flutter_app_boilerplate/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:flutter_app_boilerplate/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_app_boilerplate/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_app_boilerplate/features/auth/domain/usecases/get_current_user.dart';
import 'package:flutter_app_boilerplate/features/auth/domain/usecases/login_user.dart';
import 'package:flutter_app_boilerplate/features/auth/domain/usecases/logout_user.dart';
import 'package:flutter_app_boilerplate/features/auth/domain/usecases/register_user.dart';
import 'package:flutter_app_boilerplate/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter_app_boilerplate/features/settings/presentation/bloc/theme_cubit.dart';

// Core Mocks
class MockCacheManager extends Mock implements CacheManager {}

class MockDioClient extends Mock implements DioClient {}

// Auth Feature Mocks
class MockAuthRepository extends Mock implements AuthRepository {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockLoginUser extends Mock implements LoginUser {}

class MockRegisterUser extends Mock implements RegisterUser {}

class MockLogoutUser extends Mock implements LogoutUser {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockAuthBloc extends Mock implements AuthBloc {}

class MockThemeCubit extends Mock implements ThemeCubit {}

// Register fallback values for mocktail
void registerFallbackValues() {
  registerFallbackValue(const LoginParams(email: '', password: ''));
  registerFallbackValue(const RegisterParams(email: '', password: ''));
}
