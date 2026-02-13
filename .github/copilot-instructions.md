# Pocket Union - Copilot Instructions

## Project Overview
**Pocket Union** is a Flutter personal finance app for couples using Clean Architecture, Riverpod state management, SQLite local storage, and Supabase backend authentication.

## Architecture Patterns

### 1. **Clean Architecture Layers**
- **Domain**: Pure business logic (models, ports/interfaces, DTOs)
  - `lib/domain/port/` - Abstract interfaces (e.g., `AuthPort`, `UserPort`)
  - `lib/domain/models/` - Domain entities (e.g., `DomainUser`, `couple`)
  - `lib/dto/` - Data transfer objects for API requests
- **Data**: Implementation of domain ports
  - `lib/Dao/sqlite/` - SQLite DAOs implementing ports using singleton lazy pattern
  - `lib/core/services/auth/` - Service implementations combining multiple data sources
- **Presentation**: UI layer
  - `lib/ui/screens/` - Screen components (organized by feature: `auth/`, `start/`)
  - `lib/ui/widgets/` - Reusable UI components
  - `lib/ui/theme/` - Centralized theme configuration

### 2. **State Management with Riverpod**
```dart
// Providers pattern (in lib/core/providers.dart):
final supabaseClientProvider = FutureProvider<SupabaseClient>((ref) async { ... });
final userDaoProvider = Provider<UserPort>((ref) => UserDaoSqlite(...));
final authServiceProvider = FutureProvider<AuthPort>((ref) async {
  final supabaseClient = await ref.watch(supabaseClientProvider.future);
  final userSqlite = ref.watch(userDaoProvider);
  return AuthService(supabaseClient, userSqlite);
});
```
- Use `ConsumerStatefulWidget` for forms that need providers
- Use `ConsumerState<T>` with `ref.read()` or `ref.watch()` to access providers
- **Critical**: Forms use `ref.read(authServiceProvider.future)` for one-time service access

### 3. **Data Persistence Pattern (DAO + Port)**
```dart
// Define abstract port in domain
abstract class UserPort {
  Future<bool> upsertUser(DomainUser user);
}

// Implement in data layer with singleton DB helper
class UserDaoSqlite extends UserPort {
  final DbSqlite dbHelper;
  UserDaoSqlite({required this.dbHelper});
  
  @override
  Future<bool> upsertUser(DomainUser user) async {
    final db = await dbHelper.database;
    await db.insert('profile', user.toMap(), 
      conflictAlgorithm: ConflictAlgorithm.replace);
    return true;
  }
}
```
- All data operations return `Future<bool>` or `Future<T>`
- Use `ConflictAlgorithm.replace` for upsert operations
- Database singleton: `DbSqlite.instance` - lazy initialized via getter

### 4. **Authentication Flow**
When implementing auth features:
1. **Register**: Call `authService.register()` which:
   - Creates Supabase user via `_supabaseClient.auth.signUp()`
   - Saves user to SQLite with Supabase ID using `_userDaoPort.upsertUser()`
   - Sets `isFirstLaunch: false` in SharedPreferences to skip start screen
2. **Login**: Call `authService.login()` which:
   - Authenticates with Supabase
   - Syncs user to local SQLite via `_userDaoPort.upsertUser()`
3. **Initial Route Logic**: `main.dart` reads `isFirstLaunch` from SharedPreferences to determine initial route

## File Organization & Naming Conventions

| Purpose | Location | Pattern |
|---------|----------|---------|
| Screens | `lib/ui/screens/{feature}/` | `SomethingScreen`, `something_screen.dart` |
| Screen widgets | `lib/ui/screens/{feature}/widgets/` | `SomethingForm`, `SomethingCard` |
| Reusable widgets | `lib/ui/widgets/` | `SomethingWidget`, `something_widget.dart` |
| DAOs | `lib/Dao/sqlite/` | `SomethingDaoSqlite`, `something_dao_sqlite.dart` |
| Models | `lib/domain/models/` | `DomainSomething`, `something.dart` |
| DTOs | `lib/dto/` | `SomethingDto`, `something_dto.dart` |
| Services | `lib/core/services/{feature}/` | `SomethingService`, `something_service.dart` |
| Ports | `lib/domain/port/{feature}/` | `SomethingPort`, `something_port.dart` |

## Common Workflows

### Adding a New Auth Feature
1. Create `SomethingDto` in `lib/dto/`
2. Add abstract method to appropriate `Port` in `lib/domain/port/`
3. Implement in service (e.g., `lib/core/services/auth/auth_service.dart`)
4. Create provider in `lib/core/providers.dart` if needed
5. Use in `ConsumerStatefulWidget` by calling `ref.read(authServiceProvider.future)`

### Adding a Data Entity
1. Create domain model in `lib/domain/models/` with `toMap()`, `fromMap()`, `fromJson()` methods
2. Create DAO in `lib/Dao/sqlite/` implementing appropriate `Port` interface
3. Update `DbSqlite._onCreate()` with SQL migration
4. Create provider in `lib/core/providers.dart`

### User Feedback Patterns
- **SnackBar** for temporary notifications: `ScaffoldMessenger.of(context).showSnackBar(...)`
- **AlertDialog** for important user confirmations: `showDialog()` with `barrierDismissible: false`
- **Error handling**: Catch Supabase's `AuthException` separately, show user-friendly messages

## Database Schema Patterns
- Tables use TEXT PKs (UUIDs from Supabase or local generation)
- Foreign keys enabled via `PRAGMA foreign_keys = ON`
- Sync tracking columns: `sync_status`, `last_sync_at`, `local_updated_at`, `is_deleted`
- Balance/numeric fields stored as INTEGER (cents) or TEXT
- Timestamps in ISO8601 format

## Key Dependencies
- **flutter_riverpod ^2.6.1**: State management
- **supabase_flutter ^2.0.0**: Auth & backend
- **sqflite ^2.3.0**: Local SQLite
- **shared_preferences ^2.2.2**: Persist app settings (e.g., `isFirstLaunch`)
- **flutter_dotenv ^6.0.0**: Load `.env` for Supabase credentials

## Common Gotchas
1. **Startup order**: `.env` loaded in `supabaseClientProvider` before `Supabase.initialize()`
2. **Mounted checks**: Always check `if (mounted)` before setState/Navigator in async operations
3. **Form validation**: Use `AutovalidateMode.onUnfocus` for better UX
4. **Navigation**: Use `pushReplacementNamed()` for auth transitions to prevent back button issues
5. **SQLite ID field**: Must be TEXT to store Supabase UUIDs, not INTEGER

## Testing Guidance
- Focus on DAOs and Services (pure logic layer)
- Mock Supabase responses using test fixtures
- Use `sqflite_common_ffi` for test database operations
- UI tests secondary priority; focus on data layer correctness
