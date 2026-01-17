# ENFOQUE DE ARQUITECTURA CON RIVERPROD

Implementaremos una arquitectura escalable usando Riverpod como núcleo. Sigue estos principios:

1. Jerarquía de Providers:
    * Providers de solo lectura para dependencias (Supabase, repositorios)
    * StateNotifierProvider para lógica de negocio y estado mutable
    * Future/StreamProviders para operaciones asíncronas
2. Patrón Repository:
    * Capa de datos abstracta que unifica Supabase (remoto) y SQLite (local)
    * Implementa sincronización offline-first para datos financieros críticos
3. Estructura por características:

```markdown
└── 📁lib
    └── 📁core
        ├── providers.dart
    └── 📁Dao
        └── 📁sqlite
            ├── category_dao_sqlite.dart
            ├── db_helper_sqlite.dart
            ├── revenue_dao_sqlite.dart
            ├── user_dao_sqlite.dart
        └── 📁supabase
            └── 📁auth
    └── 📁domain
        └── 📁models
            ├── category.dart
            ├── payment.dart
            ├── revenue.dart
            ├── user.dart
        └── 📁port
            ├── auth_port.dart
    └── 📁dto
        ├── login_dto.dart
        ├── register_dto.dart
    └── 📁services
        └── 📁auth
            ├── auth_service.dart
    └── 📁ui
        └── 📁screens
            └── 📁auth
                └── 📁widgets
                    ├── auth_text_form_field.dart
                    ├── login_form.dart
                    ├── register_form.dart
                ├── login_screen.dart
                ├── register_screen.dart
            └── 📁start
                └── 📁widgets
                ├── start_screen.dart
            ├── home_screen.dart
            ├── new_entry_screen.dart
            ├── new_out_screen.dart
        └── 📁theme
            ├── app_theme.dart
        └── 📁widgets
            ├── form_title.dart
            ├── grid_background.dart
            ├── input_with_button.dart
            ├── list_menu.dart
        ├── router.dart
    └── main.dart

```

1. Buenas prácticas específicas:
    * Usar autoDispose para providers que no son globales
    * Implementar StateNotifier con estados inmutables
    * Validación de datos financieros en la capa de negocio
    * Manejo de errores con estados de error específicos
Ejemplo musical: Riverpod es como el pedalboard de efectos completo - cada pedal (Provider) tiene una función específica, se conectan en un orden lógico (jerarquía) y el pedal de alimentación (ProviderScope) da energía a todo el sistema.
