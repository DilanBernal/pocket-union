# Refactor de Auth + Drift para `UserDaoSqlite`

## Qué cambió

- `auth_remote_data_source` ahora replica el flujo de `AuthService` al iniciar sesión:
  - marca `isFirstLaunch` como `false`
  - autentica en Supabase
  - sincroniza el perfil local
  - guarda `isInSession`, `idUser` y `userProfile`
  - intenta resolver y persistir el `coupleId` y el perfil de la pareja
- `UserDaoSqlite` pasó a consumir `AppDatabase` de Drift en vez de `DbSqlite`.
- El DAO de usuario ahora expone su provider con `@riverpod`.
- Se agregó un provider dedicado para `AppDatabase`.
- El esquema Drift del perfil se alineó con la tabla SQLite existente para no duplicar datos.

## Por qué se hizo

La intención fue reducir la diferencia entre el flujo de login remoto y el flujo consolidado de `AuthService`, de modo que ambos persistan sesión y usuario local de forma coherente. Además, mover el DAO de usuario a Drift mejora el tipado, simplifica consultas y prepara la base para migrar gradualmente otros DAOs sin depender de `DbSqlite`.

## Impacto esperado

- Menor riesgo de divergencia entre `AuthService` y el datasource remoto de login.
- Mejor integración con Riverpod mediante providers generados.
- Consultas de usuario más seguras y tipadas con Drift.
- Base técnica para migrar el resto de la persistencia local a Drift.

## Tradeoffs

- Se introduce una migración de esquema en Drift para el perfil de usuario.
- El proyecto mantiene temporalmente dos capas de acceso SQLite: la antigua basada en `DbSqlite` y la nueva basada en Drift para `profile`.
- Será necesario regenerar código (`riverpod_generator` y `drift_dev`) después de esta refactorización.

