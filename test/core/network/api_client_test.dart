import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:recetas_app/core/network/api_exception.dart';

DioException _responseError(int statusCode, Map<String, dynamic> body) {
  final requestOptions = RequestOptions(path: '/test');
  return DioException(
    requestOptions: requestOptions,
    type: DioExceptionType.badResponse,
    response: Response(
      requestOptions: requestOptions,
      statusCode: statusCode,
      data: body,
    ),
  );
}

void main() {
  group('mapDioException', () {
    test('401 se traduce a UnauthorizedException con el mensaje de la API', () {
      final error = _responseError(401, {'message': 'No autenticado.'});

      final exception = mapDioException(error);

      expect(exception, isA<UnauthorizedException>());
      expect(exception.message, 'No autenticado.');
    });

    test('403 se traduce a ForbiddenException', () {
      final error = _responseError(403, {'message': 'Sin permiso.'});

      final exception = mapDioException(error);

      expect(exception, isA<ForbiddenException>());
    });

    test('422 se traduce a ValidationException con el mapa de errores', () {
      final error = _responseError(422, {
        'message': 'Los datos no son válidos.',
        'errors': {
          'email': ['Las credenciales no son correctas.'],
        },
      });

      final exception = mapDioException(error) as ValidationException;

      expect(exception.message, 'Los datos no son válidos.');
      expect(
        exception.firstErrorFor('email'),
        'Las credenciales no son correctas.',
      );
    });

    test('422 sin `errors` (fallo de /recipes/import) usa `error` como mensaje',
        () {
      final error = _responseError(422, {
        'error': 'No se pudo analizar el vídeo.',
      });

      final exception = mapDioException(error);

      expect(exception.message, 'No se pudo analizar el vídeo.');
    });

    test('429/5xx sin cuerpo reconocido cae en ApiFailure genérico', () {
      final error = _responseError(500, {});

      final exception = mapDioException(error) as ApiFailure;

      expect(exception.statusCode, 500);
      expect(exception.message, 'Ha ocurrido un error inesperado.');
    });

    test('timeout de conexión se traduce a NetworkException', () {
      final requestOptions = RequestOptions(path: '/test');
      final error = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionTimeout,
      );

      expect(mapDioException(error), isA<NetworkException>());
    });
  });
}
