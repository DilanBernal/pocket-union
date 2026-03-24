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
* **Sensibles:** Uso de `flutter_dotenv` para claves de API.
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
