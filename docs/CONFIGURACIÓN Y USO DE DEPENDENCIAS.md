# CONFIGURACIÓN Y USO DE DEPENDENCIAS

Supabase + Riverpod Integration:
SQLite con SQFlite:

* Configurar base de datos local para caché de transacciones
* Implementar migraciones versionadas
* Sincronización diferencial con Supabase
Seguridad Financiera:
* Usar flutter_dotenv para keys sensibles (NUNCA en el código)
* uuid para identificadores únicos de transacciones
* Validar cálculos financieros en el backend cuando sea posible
Estado Local:
* shared_preferences para preferencias de usuario (moneda, temas)
* intl para formato de monedas y fechas según localización
Ejemplo musical: SQLite es como tu grabadora multipista portátil - guarda tus ideas (datos) localmente, mientras Supabase es el estudio profesional en la nube donde sincronizas tus mezclas finales.
