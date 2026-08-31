/// Punto único de configuración de la API.
///
/// El valor por defecto apunta a la única instalación de Recetas que este
/// cliente consume. Puede sobreescribirse en tiempo de compilación con
/// `--dart-define=API_BASE_URL=https://otra-instancia.example`.
class ApiConfig {
  const ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://recetas.daniellucia.es',
  );

  static const Duration connectTimeout = Duration(seconds: 15);

  /// Las importaciones por IA pueden tardar 10-60s en el servidor.
  static const Duration importTimeout = Duration(seconds: 90);

  static const Duration receiveTimeout = Duration(seconds: 20);
}
