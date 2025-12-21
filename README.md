# Flutter App Boilerplate

A production-ready Flutter boilerplate following **Clean Architecture** principles with BLoC state management.

## 🏗️ Architecture

This project follows **Clean Architecture** with a feature-first approach:

```
lib/
├── config/                 # App configuration
│   └── routes/            # Auto Route configuration
├── core/                   # Core functionality
│   ├── cache/             # Local caching with SharedPreferences
│   ├── constants/         # App constants, spacing, durations
│   ├── error/             # Exceptions and Failures
│   ├── extensions/        # Dart extensions
│   ├── navigation/        # Navigation manager
│   ├── network/           # Dio HTTP client
│   ├── theme/             # Light & Dark themes
│   ├── usecases/          # Base usecase class
│   └── widgets/           # Reusable widgets
├── features/              # Feature modules
│   ├── auth/              # Authentication feature
│   │   ├── data/          # Data layer
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/        # Domain layer
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/  # Presentation layer
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   ├── home/
│   ├── onboarding/
│   ├── settings/
│   └── splash/
├── app.dart               # Root widget
├── injection_container.dart # Dependency injection
└── main.dart              # Entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)

### Installation

1. Clone this repository:
```bash
git clone https://github.com/yourusername/flutter_app_boilerplate.git
cd flutter_app_boilerplate
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run code generation:
```bash
dart run build_runner build --delete-conflicting-outputs
```

4. Run the app:
```bash
flutter run
```

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management |
| `get_it` | Dependency injection |
| `auto_route` | Declarative routing |
| `dio` | HTTP client |
| `dartz` | Functional programming (Either) |
| `freezed` | Immutable models |
| `shared_preferences` | Local storage |
| `cached_network_image` | Image caching |
| `easy_localization` | Internationalization |
| `equatable` | Value equality |

## 🎨 Features

- ✅ **Clean Architecture** - Separation of concerns with data/domain/presentation layers
- ✅ **BLoC Pattern** - Predictable state management
- ✅ **Dependency Injection** - GetIt for service locator pattern
- ✅ **Type-safe Routing** - Auto Route with generated routes
- ✅ **Error Handling** - Either pattern for functional error handling
- ✅ **Theming** - Light & Dark theme support
- ✅ **Localization** - Multi-language support (EN, TR)
- ✅ **Network Layer** - Dio with interceptors
- ✅ **Caching** - SharedPreferences wrapper
- ✅ **Reusable Widgets** - Common UI components

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📝 Code Generation

This project uses code generation for:
- **Freezed** - Immutable data classes
- **Auto Route** - Type-safe navigation

Run after modifying annotated files:
```bash
dart run build_runner build --delete-conflicting-outputs
```

Or watch for changes:
```bash
dart run build_runner watch --delete-conflicting-outputs
```

## 🏛️ Architecture Layers

### Domain Layer
- **Entities**: Business objects
- **Repositories**: Abstract interfaces
- **Use Cases**: Business logic units

### Data Layer
- **Models**: Data transfer objects (DTOs)
- **Data Sources**: Remote (API) and Local (Cache)
- **Repository Implementations**: Concrete implementations

### Presentation Layer
- **BLoC/Cubit**: State management
- **Pages**: Screen widgets
- **Widgets**: UI components

## 📁 Adding a New Feature

1. Create feature folder structure:
```
lib/features/your_feature/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── bloc/
    ├── pages/
    └── widgets/
```

2. Register dependencies in `injection_container.dart`
3. Add routes in `app_router.dart`
4. Run code generation

## 🔐 Environment Variables

Create `.env` file in root:
```
API_BASE_URL=https://api.example.com
API_KEY=your_api_key
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
