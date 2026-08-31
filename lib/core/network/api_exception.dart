import 'package:dio/dio.dart';

/// Errores de la API tipados para que la UI pinte mensajes en español sin
/// tener que conocer nada de Dio/HTTP.
sealed class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// 401: sin token o token inválido/revocado.
final class UnauthorizedException extends ApiException {
  const UnauthorizedException([
    super.message = 'Tu sesión ha caducado. Vuelve a iniciar sesión.',
  ]);
}

/// 403: sin permiso (p. ej. menú de otro hogar).
final class ForbiddenException extends ApiException {
  const ForbiddenException([
    super.message = 'No tienes permiso para hacer esto.',
  ]);
}

/// 422: validación fallida. `errors` es el mapa `campo: [mensajes]`.
final class ValidationException extends ApiException {
  const ValidationException(super.message, this.errors);

  final Map<String, List<String>> errors;

  String? firstErrorFor(String field) => errors[field]?.firstOrNull;
}

/// Sin conexión, timeout, o el servidor no responde.
final class NetworkException extends ApiException {
  const NetworkException([
    super.message = 'No se pudo conectar. Comprueba tu conexión.',
  ]);
}

/// Cualquier otro fallo del servidor (429, 5xx, respuesta inesperada...).
final class ApiFailure extends ApiException {
  const ApiFailure(super.message, {this.statusCode});

  final int? statusCode;
}

/// Traduce una [DioException] a un [ApiException] tipado, reutilizando los
/// mensajes que la propia API ya devuelve en `message`/`errors`/`error`.
ApiException mapDioException(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
      return const NetworkException();
    case DioExceptionType.cancel:
      return const NetworkException('La petición se canceló.');
    case DioExceptionType.badCertificate:
      return const NetworkException('No se pudo verificar la conexión segura.');
    case DioExceptionType.badResponse:
      return _mapResponse(error);
    default:
      return const NetworkException();
  }
}

ApiException _mapResponse(DioException error) {
  final response = error.response;
  final statusCode = response?.statusCode;
  final data = response?.data;
  final body = data is Map<String, dynamic> ? data : const <String, dynamic>{};

  final message = (body['message'] as String?) ??
      (body['error'] as String?) ??
      'Ha ocurrido un error inesperado.';

  switch (statusCode) {
    case 401:
      return UnauthorizedException(message);
    case 403:
      return ForbiddenException(message);
    case 422:
      final rawErrors = body['errors'];
      final errors = <String, List<String>>{};
      if (rawErrors is Map) {
        for (final entry in rawErrors.entries) {
          final value = entry.value;
          errors[entry.key as String] = value is List
              ? value.map((e) => e.toString()).toList()
              : [value.toString()];
        }
      }
      return ValidationException(message, errors);
    default:
      return ApiFailure(message, statusCode: statusCode);
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
