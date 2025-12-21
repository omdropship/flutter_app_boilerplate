import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_app_boilerplate/core/error/failures.dart';
import 'package:flutter_app_boilerplate/features/auth/domain/usecases/get_current_user.dart';
import 'package:flutter_app_boilerplate/features/auth/domain/usecases/login_user.dart';
import 'package:flutter_app_boilerplate/features/auth/domain/usecases/logout_user.dart';
import 'package:flutter_app_boilerplate/features/auth/domain/usecases/register_user.dart';
import 'package:flutter_app_boilerplate/features/auth/presentation/bloc/auth_bloc.dart';

import '../../../../mocks/mocks.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late AuthBloc bloc;
  late MockLoginUser mockLoginUser;
  late MockRegisterUser mockRegisterUser;
  late MockLogoutUser mockLogoutUser;
  late MockGetCurrentUser mockGetCurrentUser;

  setUp(() {
    mockLoginUser = MockLoginUser();
    mockRegisterUser = MockRegisterUser();
    mockLogoutUser = MockLogoutUser();
    mockGetCurrentUser = MockGetCurrentUser();

    bloc = AuthBloc(
      loginUser: mockLoginUser,
      registerUser: mockRegisterUser,
      logoutUser: mockLogoutUser,
      getCurrentUser: mockGetCurrentUser,
    );
  });

  setUpAll(() {
    registerFallbackValues();
  });

  tearDown(() {
    bloc.close();
  });

  final tUser = TestData.testUser;

  test('initial state should be AuthInitial', () {
    expect(bloc.state, equals(const AuthInitial()));
  });

  group('LoginRequested', () {
    const tEmail = 'test@example.com';
    const tPassword = 'password123';

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when login succeeds',
      build: () {
        when(() => mockLoginUser(any()))
            .thenAnswer((_) async => Right(tUser));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(
        email: tEmail,
        password: tPassword,
      )),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(tUser),
      ],
      verify: (_) {
        verify(() => mockLoginUser(const LoginParams(
              email: tEmail,
              password: tPassword,
            ))).called(1);
      },
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthError] when login fails',
      build: () {
        when(() => mockLoginUser(any()))
            .thenAnswer((_) async => const Left(ServerFailure('Invalid credentials')));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoginRequested(
        email: tEmail,
        password: tPassword,
      )),
      expect: () => [
        const AuthLoading(),
        const AuthError('Invalid credentials'),
      ],
    );
  });

  group('LogoutRequested', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthInitial] when logout succeeds',
      build: () {
        when(() => mockLogoutUser(any()))
            .thenAnswer((_) async => const Right(null));
        return bloc;
      },
      act: (bloc) => bloc.add(const LogoutRequested()),
      expect: () => [
        const AuthLoading(),
        const AuthInitial(),
      ],
    );
  });

  group('CheckAuthStatus', () {
    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when user is logged in',
      build: () {
        when(() => mockGetCurrentUser(any()))
            .thenAnswer((_) async => Right(tUser));
        return bloc;
      },
      act: (bloc) => bloc.add(const CheckAuthStatus()),
      expect: () => [
        const AuthLoading(),
        AuthAuthenticated(tUser),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when user is not logged in',
      build: () {
        when(() => mockGetCurrentUser(any()))
            .thenAnswer((_) async => const Left(CacheFailure('No user found')));
        return bloc;
      },
      act: (bloc) => bloc.add(const CheckAuthStatus()),
      expect: () => [
        const AuthLoading(),
        const AuthUnauthenticated(),
      ],
    );
  });
}
