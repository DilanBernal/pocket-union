# CONFIGURACIÓN Y USO DE DEPENDENCIAS

Supabase + Riverpod Integration:
SQLite con SQFlite:

* Configurar base de datos local para caché de transacciones
* Implementar migraciones versionadas
* Sincronización diferencial con Supabase
* Migracion gradual a `sqflite_sqlcipher` para cifrado local en repositorios nuevos
Seguridad Financiera:
* Usar `String.fromEnvironment` con `--dart-define` para keys sensibles (NUNCA hardcodear)
* uuid para identificadores únicos de transacciones
* Validar cálculos financieros en el backend cuando sea posible
* Guardar secretos de dispositivo (clave DB/tokens) en `flutter_secure_storage`
Estado Local:
* shared_preferences para preferencias de usuario (moneda, temas)
* intl para formato de monedas y fechas según localización
Conectividad y observabilidad:
* `connectivity_plus` para disparar `flushPending()` en reconexión
* `logger` (wrapper `AppLogger`) para trazabilidad consistente
Ejemplo musical: SQLite es como tu grabadora multipista portátil - guarda tus ideas (datos) localmente, mientras Supabase es el estudio profesional en la nube donde sincronizas tus mezclas finales.
