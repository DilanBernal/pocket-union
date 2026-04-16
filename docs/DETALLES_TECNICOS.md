# Documentación Técnica: Pocket Union Internals

Este documento describe cómo está operando actualmente la maquinaria de **Pocket Union**.

## 🏗️ Arquitectura de Datos (Offline-First)

La aplicación utiliza un patrón de **Repositorio Dual**.

* **SQLite (Local):** Actúa como la fuente de verdad inmediata para la UI. Cada transacción se guarda primero localmente con un `sync_status = 'pending'`.
* **Supabase (Nube):** Funciona como el estudio de grabación principal. Los servicios intentan sincronizar los datos locales con la nube de forma asíncrona.

### Flujo de Sincronización

1. El usuario registra un `Income` o `Expense`.
2. El `DaoSqlite` genera un `UUID` único y persiste en SQLite.
3. El `Service` correspondiente intenta el "push" a Supabase.
4. Si tiene éxito, el `sync_status` cambia a `synced`.

## 🧠 Gestión de Estado con Riverpod

Utilizamos una jerarquía de Providers para desacoplar la lógica:

1. **Dependency Providers:** Para el cliente de Supabase y las instancias de SQLite.
2. **Service Providers:** Encapsulan la lógica de negocio (ej. `authServiceProvider`).
3. **State Providers:** Gestionan la UI reactiva (ej. `allIncomesProvider`).

## 🔐 Seguridad y Precisión Financiera

* **Cálculos:** Todos los montos se manejan en **centavos (enteros)** en la base de datos para evitar errores de redondeo de punto flotante de IEEE 754. La clase `intl` se encarga de la visualización.
* **Sensibles:** Uso de `String.fromEnvironment` para claves de API via `--dart-define`.
* **IDs:** Implementación de `uuid` v4 para evitar colisiones entre registros locales y remotos.

## 🎨 Tematización

La app implementa un `AppTheme` personalizado que utiliza `GoogleFonts` para inyectar la estética Synthwave. El `GridBackground` es un `CustomPainter` optimizado para no penalizar el rendimiento del renderizado.

## 🧾 Cambios Importantes (Marzo 2026) - Historial de Transacciones

### Cambio aplicado (recurrentes)

Se agregaron dos mejoras funcionales en los historiales de ingresos y gastos:

1. Borrado por gesto `swipe` de izquierda a derecha (`DismissDirection.startToEnd`) con feedback visual de papelera.
2. Estado vacio refrescable por dos vias: `pull-to-refresh` y boton explicito `Actualizar`.

### Razon del cambio (recurrentes)

1. Reducir friccion en acciones frecuentes de limpieza del historial (UX mas rapida que entrar a detalle para eliminar).
2. Evitar estados vacios estaticos cuando la sincronizacion termina despues de abrir pantalla.
3. Mantener consistencia de comportamiento entre ingresos y gastos bajo el mismo patron de interaccion.

### Impacto tecnico (recurrentes)

1. Se extendio el puerto cloud de ingresos con `deleteIncome` y su implementacion en `IncomeService` con estrategia offline-first (eliminacion local obligatoria, sincronizacion cloud best-effort).
2. Las pantallas de historial usan `AlwaysScrollableScrollPhysics` en estado vacio para permitir refresco por gesto incluso sin items.
3. El borrado por gesto en UI usa `Dismissible` y delega en servicios para conservar separacion UI/negocio.

## 🧾 Cambios Importantes (Marzo 2026) - Programacion de Ingresos y Gastos Recurrentes

### Cambio aplicado

Se agrego soporte completo para programar ingresos y gastos recurrentes con entrada tipada y conversion a expresion `pg_cron`.

1. Nueva capa de dominio/datos/servicio para `recurrent_expense` (modelo, DTO, puertos, DAO SQLite y servicio cloud).
2. Actualizacion de `recurrent_income.recurrent_info` para almacenar cron textual (5 segmentos) en vez de estructura no tipada.
3. Nuevas pantallas de UI para programar ingresos y gastos recurrentes, con modo semanal y mensual.
4. Migracion SQLite v3 para crear tabla local `recurrent_expense` y mantener estrategia offline-first.

### Razon del cambio

1. `pg_cron` espera una expresion textual en orden `min hour day month dow`; el formato previo no representaba bien comodines/rangos.
2. El modulo de gastos recurrentes no existia en la app, lo que impedia cubrir ambos flujos financieros.
3. Se necesitaba una forma segura de que el usuario configure periodicidad sin escribir cron manualmente.

### Impacto tecnico

1. El formulario ahora traduce entradas tipadas (hora/minuto + dia semanal o dia mensual) a una cadena cron valida.
2. Los servicios siguen enfoque offline-first: guardan local primero y sincronizan Supabase en `try/catch`.
3. Se anadieron rutas y accesos en menu para `Programar ingresos` y `Programar gastos`.
4. Se incluyeron pruebas unitarias de servicios recurrentes para validar comportamiento ante caida de red.

### Tradeoffs

1. La UI inicial soporta solo periodicidad semanal/mensual para minimizar errores de entrada.
2. Aun no se ejecuta el cron dentro de la app; esta capa prepara y persiste la expresion para ejecucion en backend.

## 🧾 Cambios Importantes (Abril 2026) - Robustez en `CoupleService`

### Cambio aplicado

Se reforzo el flujo de union de pareja para evitar persistencias no garantizadas y errores silenciosos:

1. En `joinCoupleByCode`, la persistencia local (`upsertCouple`) y el guardado de `coupleId` en `SharedPreferences` ahora se ejecutan con `await Future.wait(...)`.
2. En `getCoupleByUserId`, se elimino el `catch (_) {}` al guardar en local y se reemplazo por logging de error con `stackTrace`.

### Razon del cambio

1. Sin `await`, el flujo podia retornar exito al usuario antes de terminar (o incluso fallar) la persistencia local.
2. Los `catch` silenciosos ocultaban fallos de sincronizacion local, complicando trazabilidad y debugging.

### Impacto tecnico

1. El estado local de pareja queda consistente al finalizar `joinCoupleByCode`.
2. Los errores de escritura local quedan observables en logs y no se silencian.
3. Se reduce el riesgo de navegacion con estado parcial (`coupleId` ausente o desincronizado).

### Tradeoffs

1. `joinCoupleByCode` puede demorar marginalmente mas, porque espera la persistencia local antes de retornar.

## 🧾 Cambios Importantes (Abril 2026) - Fundacion para Clean Architecture + SQLCipher

### Cambio aplicado

Se agrego la base transversal para la nueva arquitectura limpia sin romper el flujo actual:

1. Nuevo `core/` con componentes comunes:
   - `core/error` (`failures.dart`, `exceptions.dart`)
   - `core/network/connectivity_service.dart`
   - `core/sync` (`sync_service.dart`, `sync_service_impl.dart`, `sync_status.dart`)
   - `core/cache/cache_service.dart`
   - `core/logger/app_logger.dart`
   - `core/database/db_helper.dart` con SQLCipher y clave en `flutter_secure_storage`
2. Nuevo espacio de providers en `lib/providers/`:
   - `di_providers.dart`
   - `utility_providers.dart`
   - `cache_providers.dart`
3. Dependencias nuevas en `pubspec.yaml`: `sqflite_sqlcipher`, `flutter_secure_storage`, `connectivity_plus`, `logger`.

### Razon del cambio

1. El proyecto mezclaba infraestructura, negocio y UI en varios puntos, dificultando migrar a `presentation -> application -> domain <- data`.
2. La DB local estaba en texto plano (`sqflite`) y se necesitaba preparar cifrado local con SQLCipher.
3. Se requeria una base reusable para sincronizacion asincrona y cache TTL antes de migrar features una por una.

### Impacto tecnico

1. Se habilita una ruta de migracion incremental sin apagar los servicios/DAOs actuales.
2. La nueva DB cifrada se abre con una clave persistida en almacenamiento seguro del dispositivo.
3. Queda disponible un `SyncService` generico para encolar push no bloqueante y drenar pendientes al reconectar.

### Tradeoffs

1. Durante la migracion conviviran providers legacy (`lib/core/providers`) y nuevos (`lib/providers`) por un tiempo.
2. En esta fase la app aun no consume todas las piezas nuevas; la adopcion sera vertical por feature.

## 🧾 Cambios Importantes (Abril 2026) - Primer vertical slice nuevo (Auth + Category)

### Cambio aplicado

1. Se incorporo `data/dtos/auth/app_user_dto.dart` y `data/dtos/reference/category_dto.dart`.
2. Se crearon datasources nuevos:
   - `data/datasources/local/auth/auth_local_datasource_impl.dart`
   - `data/datasources/remote/auth/auth_remote_datasource_impl.dart`
   - `data/datasources/local/reference/category_local_datasource_impl.dart`
   - `data/datasources/remote/reference/category_remote_datasource_impl.dart`
3. Se agregaron repositorios nuevos:
   - `data/repositories/auth/auth_repository_impl.dart`
   - `data/repositories/reference/category_repository_impl.dart`
4. Se agrego capa `application` inicial:
   - `application/auth/auth_notifier.dart` + `auth_state.dart`
   - `application/reference/category_notifier.dart` + `category_state.dart`
5. Se completo la primera separacion de providers por responsabilidad (`di`, `local`, `remote`, `auth`, `reference`, `cache`, `utility`).

### Razon del cambio

1. Probar la viabilidad de la migracion con un corte vertical antes de mover el resto de features.
2. Establecer patron repetible: `domain contracts -> data impl -> providers -> application notifier`.
3. Consolidar offline-first de categorias con cola de sincronizacion no bloqueante.

### Impacto tecnico

1. Ya existe una ruta nueva para autenticar y observar usuario desde repositorio abstracto.
2. Categorias puede operar con fuente local y sincronizacion programada sin bloquear UI.
3. Queda habilitada la extension progresiva a transacciones, goals y recurrentes usando el mismo patron.

## 🧾 Cambios Importantes (Abril 2026) - Slice de transacciones (Revenue/Payment)

### Cambio aplicado

1. Se agregaron DTOs y datasources nuevos para transacciones:
   - `data/dtos/transaction/{revenue_dto,payment_dto}.dart`
   - `data/datasources/local/transaction/*`
   - `data/datasources/remote/transaction/*`
2. Se agregaron repositorios:
   - `data/repositories/transaction/revenue_repository_impl.dart`
   - `data/repositories/transaction/payment_repository_impl.dart`
3. Se agrego `application/transaction` con `AsyncNotifier` y estados para revenue/payment.
4. Se agrego `providers/transaction_providers.dart` para ensamblar repositorios y notifiers.

### Razon del cambio

1. Cubrir el flujo financiero principal con nomenclatura del dominio objetivo (`revenue/payment`) sin romper tablas existentes (`income/expense`).
2. Mantener UI responsive bajo estrategia offline-first y sincronizacion asincrona.

### Tradeoffs

1. En esta fase, los nuevos slices conviven con servicios legacy que aun usa la UI actual.
2. La unificacion completa de tablas y naming en backend se deja para el paso de limpieza final.

## 🧾 Cambios Importantes (Abril 2026) - Primer desacople de UI hacia Application

### Cambio aplicado

1. `ui/screens/auth/widgets/login_form.dart` ahora dispara login via `authNotifierProvider` (capa `application`) en vez de invocar directamente `AuthService`.

### Razon del cambio

1. Empezar la migracion real de `presentation -> application`, reduciendo acoplamiento de widgets con servicios concretos.
2. Preparar el arbol `presentation/` sin romper rutas existentes mediante wrappers/exports transitorios.

## 🧾 Cambios Importantes (Abril 2026) - Limpieza total legacy (modo desarrollo)

### Cambio aplicado

Se removieron por completo las capas legacy:

1. `lib/ui/`
2. `lib/Dao/`
3. `lib/core/providers/`
4. `lib/core/services/`
5. `lib/domain/models/`
6. `lib/domain/port/`
7. `lib/dto/`

Adicionalmente:

1. `presentation/` dejó de ser wrapper y pasó a tener implementaciones reales (router/theme/screens/widgets base).
2. Los datasources locales migraron a `core/database/db_helper.dart` (SQLCipher) sin dependencia de `DbSqlite` legado.
3. La suite de tests legacy fue reemplazada por pruebas unitarias alineadas a la arquitectura nueva.

### Razon del cambio

1. El proyecto aún no está publicado, por lo que era seguro ejecutar cleanup agresivo para reducir deuda técnica.
2. Mantener coexistencia legacy/nueva estaba introduciendo errores de compilación y ambigüedad de dependencias.

### Tradeoffs

1. Algunas pantallas avanzadas quedaron temporalmente como placeholders en `presentation/router.dart` mientras se remigran por feature.
