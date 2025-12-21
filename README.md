# Flutter Clean Architecture Boilerplate

Production-ready Flutter boilerplate with Clean Architecture, BLoC state management, and best practices.

---

## Table of Contents

- [Overview](#overview)
- [Quick Start](#quick-start)
- [Architecture](#architecture)
  - [Clean Architecture Layers](#clean-architecture-layers)
  - [Data Flow](#data-flow)
- [Project Structure](#project-structure)
- [Core Modules](#core-modules)
  - [Error Handling](#error-handling)
  - [Network Layer](#network-layer)
  - [Cache Layer](#cache-layer)
  - [Theme System](#theme-system)
  - [Localization](#localization)
  - [Navigation](#navigation)
- [Features](#features)
  - [Auth Feature (Example)](#auth-feature-example)
  - [Adding a New Feature](#adding-a-new-feature)
- [State Management](#state-management)
- [Dependency Injection](#dependency-injection)
- [Testing](#testing)
- [Commands Reference](#commands-reference)
- [Customization](#customization)
- [FAQ](#faq)

---

## Overview

| Feature | Technology |
|---------|------------|
| Architecture | Clean Architecture |
| State Management | BLoC / Cubit |
| Dependency Injection | GetIt |
| Routing | Auto Route |
| HTTP Client | Dio |
| Local Storage | SharedPreferences |
| Localization | Easy Localization |
| Code Generation | Freezed, JSON Serializable |

---

## Quick Start

### 1. Clone and Install

```bash
git clone https://github.com/yourusername/flutter_app_boilerplate.git
cd flutter_app_boilerplate
flutter pub get
```

### 2. Generate Code

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 3. Run

```bash
flutter run
```

---

## Architecture

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                      PRESENTATION                            │
│                                                              │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐             │
│   │  Pages   │    │   BLoC   │    │ Widgets  │             │
│   └────┬─────┘    └────┬─────┘    └──────────┘             │
│        │               │                                    │
├────────┼───────────────┼────────────────────────────────────┤
│        │    DOMAIN     │                                    │
│        ▼               ▼                                    │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐             │
│   │ UseCases │    │ Entities │    │  Repos   │ (abstract)  │
│   └────┬─────┘    └──────────┘    └────┬─────┘             │
│        │                               │                    │
├────────┼───────────────────────────────┼────────────────────┤
│        │         DATA                  │                    │
│        ▼                               ▼                    │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐             │
│   │  Repos   │    │  Models  │    │ DataSrcs │             │
│   │  (impl)  │    │ (freezed)│    │ (remote/ │             │
│   └──────────┘    └──────────┘    │  local)  │             │
│                                   └──────────┘             │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

```
User Action
    │
    ▼
┌─────────┐     ┌─────────┐     ┌────────────┐     ┌────────────┐
│  Page   │ ──▶ │  BLoC   │ ──▶ │  UseCase   │ ──▶ │ Repository │
└─────────┘     └─────────┘     └────────────┘     └────────────┘
                                                          │
                    ┌─────────────────────────────────────┘
                    │
                    ▼
            ┌──────────────┐
            │  DataSource  │
            │              │
            │ ┌──────────┐ │
            │ │  Remote  │ │ ──▶ API
            │ └──────────┘ │
            │ ┌──────────┐ │
            │ │  Local   │ │ ──▶ Cache
            │ └──────────┘ │
            └──────────────┘
```

**Key Rules:**
- Domain layer has NO external dependencies (pure Dart)
- Data layer implements Domain interfaces
- Presentation layer only knows about Domain
- Dependencies point inward (outer → inner)

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # Root widget with providers
├── injection_container.dart     # GetIt DI setup
│
├── config/
│   └── routes/
│       └── app_router.dart      # Auto Route config
│
├── core/                        # Shared code
│   ├── cache/
│   │   ├── cache_keys.dart      # Cache key enum
│   │   ├── cache_manager.dart   # SharedPreferences wrapper
│   │   └── cacheable_base_model.dart
│   │
│   ├── constants/
│   │   ├── api_constants.dart   # API URLs, timeouts
│   │   ├── app_assets.dart      # Asset paths
│   │   ├── app_durations.dart   # Animation durations
│   │   └── app_spacing.dart     # Spacing values
│   │
│   ├── error/
│   │   ├── exceptions.dart      # Low-level exceptions
│   │   └── failures.dart        # High-level failures
│   │
│   ├── extensions/
│   │   ├── context_extensions.dart
│   │   ├── datetime_extensions.dart
│   │   └── string_extensions.dart
│   │
│   ├── localization/
│   │   ├── locale_keys.dart     # Type-safe translation keys
│   │   ├── localization_manager.dart
│   │   └── supported_locales.dart
│   │
│   ├── navigation/
│   │   └── navigation_manager.dart
│   │
│   ├── network/
│   │   └── dio_client.dart      # HTTP client singleton
│   │
│   ├── theme/
│   │   ├── app_theme.dart       # Base theme interface
│   │   ├── dark/
│   │   │   ├── color_scheme_dark.dart
│   │   │   ├── dark_theme.dart
│   │   │   └── text_theme_dark.dart
│   │   └── light/
│   │       ├── color_scheme_light.dart
│   │       ├── light_theme.dart
│   │       └── text_theme_light.dart
│   │
│   ├── usecases/
│   │   └── usecase.dart         # Base UseCase interface
│   │
│   └── widgets/                 # Reusable widgets
│       ├── app_button.dart
│       ├── app_cached_image.dart
│       ├── app_text_field.dart
│       ├── error_widget.dart
│       └── loading_indicator.dart
│
└── features/                    # Feature modules
    ├── auth/
    │   ├── data/
    │   │   ├── datasources/
    │   │   ├── models/
    │   │   └── repositories/
    │   ├── domain/
    │   │   ├── entities/
    │   │   ├── repositories/
    │   │   └── usecases/
    │   └── presentation/
    │       ├── bloc/
    │       ├── pages/
    │       └── widgets/
    ├── home/
    ├── onboarding/
    ├── settings/
    └── splash/
```

---

## Core Modules

### Error Handling

Two-layer error system using the Either pattern:

| Layer | Type | Where Used |
|-------|------|------------|
| Low-level | `Exception` | DataSources |
| High-level | `Failure` | BLoC/Presentation |

**Example:**

```dart
// In DataSource - throw exceptions
throw ServerException(message: 'User not found', statusCode: 404);

// In Repository - catch and convert to failures
try {
  return Right(await remoteDataSource.login(...));
} on ServerException catch (e) {
  return Left(ServerFailure(message: e.message));
}

// In BLoC - handle failures
result.fold(
  (failure) => emit(AuthError(failure.message)),
  (user) => emit(Authenticated(user)),
);
```

### Network Layer

Singleton Dio client with interceptors:

```dart
// Make requests
final response = await DioClient.instance.get('/users');
final response = await DioClient.instance.post('/login', data: {...});

// Set auth token
DioClient.instance.setAuthToken('your-token');

// Clear auth token
DioClient.instance.clearAuthToken();
```

**Interceptors:**
- Logging (debug mode only)
- Error handling (401 detection)

### Cache Layer

Type-safe caching with SharedPreferences:

```dart
// String
await CacheManager.instance.setString(CacheKeys.accessToken, token);
final token = CacheManager.instance.getString(CacheKeys.accessToken);

// Bool
await CacheManager.instance.setBool(CacheKeys.onboardingCompleted, value: true);

// Object (must implement CacheableModel)
await CacheManager.instance.setObject(CacheKeys.user, userModel);
final user = CacheManager.instance.getObject(CacheKeys.user, UserModel.fromJson);

// List
await CacheManager.instance.setList(CacheKeys.favorites, items);
```

### Theme System

```dart
// Access current theme
final colorScheme = Theme.of(context).colorScheme;
final textTheme = Theme.of(context).textTheme;

// Or use extensions
context.colorScheme.primary
context.textTheme.headlineLarge

// Toggle theme
context.read<ThemeCubit>().toggleTheme();

// Set specific theme
context.read<ThemeCubit>().setTheme(ThemeMode.dark);
```

**Customization:**
1. Edit `lib/core/theme/light/color_scheme_light.dart`
2. Edit `lib/core/theme/dark/color_scheme_dark.dart`

### Localization

**Type-safe translations:**

```dart
// Basic usage
Text(LocaleKeys.authLogin.tr())

// With named arguments
Text(LocaleKeys.homeWelcome.tr(namedArgs: {'name': 'John'}))
// JSON: "welcome": "Welcome, {name}!"

// Change language
context.read<LocaleCubit>().setLocale(context, SupportedLocale.turkish);
```

**Add new language:**

1. Create `assets/translations/xx.json`
2. Add to `SupportedLocale` enum:
```dart
newLanguage(
  locale: Locale('xx'),
  languageCode: 'xx',
  name: 'Language Name',
  nativeName: 'Native Name',
  flag: '🏳️',
),
```
3. Add to `main.dart` supportedLocales

### Navigation

```dart
// Using NavigationManager
NavigationManager.instance.push(NavigationRoute.home);
NavigationManager.instance.replace(NavigationRoute.login);
NavigationManager.instance.pop();

// Using Auto Route directly
context.router.push(const HomeRoute());
context.router.replaceAll([const LoginRoute()]);
```

---

## Features

### Auth Feature (Example)

```
features/auth/
├── data/
│   ├── datasources/
│   │   ├── auth_local_datasource.dart    # Cache operations
│   │   └── auth_remote_datasource.dart   # API calls
│   ├── models/
│   │   └── user_model.dart               # Freezed DTO
│   └── repositories/
│       └── auth_repository_impl.dart     # Implementation
├── domain/
│   ├── entities/
│   │   └── user.dart                     # Pure Dart entity
│   ├── repositories/
│   │   └── auth_repository.dart          # Abstract interface
│   └── usecases/
│       ├── get_current_user.dart
│       ├── login_user.dart
│       ├── logout_user.dart
│       └── register_user.dart
└── presentation/
    ├── bloc/
    │   ├── auth_bloc.dart
    │   ├── auth_event.dart
    │   └── auth_state.dart
    ├── pages/
    │   ├── login_page.dart
    │   └── register_page.dart
    └── widgets/
        └── auth_form.dart
```

### Adding a New Feature

**Step 1: Create folder structure**

```bash
mkdir -p lib/features/your_feature/{data/{datasources,models,repositories},domain/{entities,repositories,usecases},presentation/{bloc,pages,widgets}}
```

**Step 2: Create files in order**

| Order | Layer | File | Description |
|-------|-------|------|-------------|
| 1 | Domain | `entity.dart` | Pure Dart class |
| 2 | Domain | `repository.dart` | Abstract interface |
| 3 | Domain | `usecase.dart` | Business logic |
| 4 | Data | `model.dart` | Freezed DTO |
| 5 | Data | `datasource.dart` | API/Cache calls |
| 6 | Data | `repository_impl.dart` | Implementation |
| 7 | Presentation | `bloc.dart` | State management |
| 8 | Presentation | `page.dart` | UI |

**Step 3: Register in DI**

```dart
// injection_container.dart
Future<void> _initYourFeature() async {
  // BLoC
  sl.registerFactory<YourBloc>(() => YourBloc(sl()));

  // UseCases
  sl.registerLazySingleton<YourUseCase>(() => YourUseCase(sl()));

  // Repository
  sl.registerLazySingleton<YourRepository>(() => YourRepositoryImpl(
    remoteDataSource: sl(),
    localDataSource: sl(),
  ));

  // DataSources
  sl.registerLazySingleton<YourRemoteDataSource>(
    () => YourRemoteDataSourceImpl(dioClient: sl()),
  );
}
```

**Step 4: Add route**

```dart
// app_router.dart
AutoRoute(page: YourRoute.page),
```

**Step 5: Generate code**

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## State Management

Using BLoC pattern:

```dart
// Events
abstract class AuthEvent extends Equatable {}
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
}

// States
abstract class AuthState extends Equatable {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
}
class AuthError extends AuthState {
  final String message;
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required this.loginUser}) : super(const AuthInitial()) {
    on<LoginRequested>(_onLogin);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await loginUser(LoginParams(
      email: event.email,
      password: event.password,
    ));

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}
```

**Using in UI:**

```dart
// Trigger event
context.read<AuthBloc>().add(LoginRequested(email: email, password: password));

// Listen to state
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) return LoadingIndicator();
    if (state is AuthError) return Text(state.message);
    if (state is AuthAuthenticated) return Text('Welcome ${state.user.name}');
    return LoginForm();
  },
)
```

---

## Dependency Injection

Using GetIt service locator:

```dart
// Access dependencies
final authBloc = sl<AuthBloc>();
final cacheManager = sl<CacheManager>();

// Registration types
sl.registerFactory<T>(() => T());           // New instance each time
sl.registerLazySingleton<T>(() => T());     // Single instance, lazy
sl.registerSingleton<T>(T());               // Single instance, immediate
```

**Registration order matters!** Register dependencies before dependents.

---

## Testing

### Structure

```
test/
├── fixtures/              # JSON test data
│   ├── user.json
│   └── auth_response.json
├── helpers/
│   ├── pump_app.dart      # Widget test helpers
│   └── test_helpers.dart  # Test data factory
├── mocks/
│   └── mocks.dart         # Mock definitions
└── features/
    └── auth/
        ├── domain/
        │   └── usecases/
        │       └── login_user_test.dart
        └── presentation/
            └── bloc/
                └── auth_bloc_test.dart
```

### Example Test

```dart
void main() {
  late LoginUser usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUser(mockRepository);
  });

  test('should return User when login is successful', () async {
    // Arrange
    when(() => mockRepository.login(
      email: any(named: 'email'),
      password: any(named: 'password'),
    )).thenAnswer((_) async => Right(testUser));

    // Act
    final result = await usecase(LoginParams(
      email: 'test@example.com',
      password: 'password123',
    ));

    // Assert
    expect(result, Right(testUser));
  });
}
```

### Run Tests

```bash
# All tests
flutter test

# With coverage
flutter test --coverage

# Specific test
flutter test test/features/auth/domain/usecases/login_user_test.dart
```

---

## Commands Reference

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `dart run build_runner build --delete-conflicting-outputs` | Generate code (once) |
| `dart run build_runner watch --delete-conflicting-outputs` | Generate code (watch) |
| `flutter run` | Run app |
| `flutter test` | Run tests |
| `flutter test --coverage` | Run tests with coverage |
| `flutter analyze` | Analyze code |
| `flutter clean` | Clean build |

---

## Customization

### Change App Name

1. `pubspec.yaml` → `name: your_app_name`
2. `lib/app.dart` → `title: 'Your App Name'`
3. Android: `android/app/src/main/AndroidManifest.xml`
4. iOS: `ios/Runner/Info.plist`

### Change API URL

Edit `lib/core/constants/api_constants.dart`:

```dart
static const String baseUrl = 'https://your-api.com';
```

### Change Primary Color

Edit `lib/core/theme/light/color_scheme_light.dart`:

```dart
final Color primary = const Color(0xFFYOURCOLOR);
```

### Add New Dependency

1. Add to `pubspec.yaml`
2. Run `flutter pub get`
3. Register in `injection_container.dart` if needed

---

## FAQ

**Q: Why Clean Architecture?**
> Separation of concerns, testability, and scalability. Each layer has a single responsibility and can be modified independently.

**Q: Why BLoC over other state management?**
> BLoC enforces unidirectional data flow, separates business logic from UI, and has excellent tooling (bloc_test, flutter_bloc).

**Q: When to use Cubit vs BLoC?**
> Use Cubit for simple state (theme, locale). Use BLoC when you need event-driven architecture or complex state transitions.

**Q: Why GetIt for DI?**
> Simple API, no code generation, supports lazy singletons and factories. Alternative: Injectable for code generation.

**Q: Why Freezed?**
> Immutable data classes with copyWith, JSON serialization, and union types. Reduces boilerplate significantly.

**Q: How to add authentication guards?**
> Add guards in `app_router.dart`:
```dart
@override
List<AutoRouteGuard> get guards => [AuthGuard()];
```

---

## License

MIT License - see [LICENSE](LICENSE) file.
