import 'package:dio/dio.dart';

import '../../config/api_config.dart';
import 'api_exception.dart';

/// Provee el token Bearer guardado, si lo hay.
typedef TokenReader = Future<String?> Function();

/// Wrapper fino sobre [Dio]: adjunta `Accept: application/json` y el header
/// `Authorization` en toda petición, y traduce cualquier fallo a
/// [ApiException]. No conoce nada de modelos ni de features concretas.
class ApiClient {
  ApiClient({
    required TokenReader tokenReader,
    void Function()? onUnauthorized,
    Dio? dio,
  })  : _tokenReader = tokenReader,
        _onUnauthorized = onUnauthorized,
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: '${ApiConfig.baseUrl}/api',
              connectTimeout: ApiConfig.connectTimeout,
              receiveTimeout: ApiConfig.receiveTimeout,
              contentType: Headers.jsonContentType,
              headers: const {'Accept': 'application/json'},
            )) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenReader();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenReader _tokenReader;
  final void Function()? _onUnauthorized;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await _send(
      () => _dio.get<dynamic>(path, queryParameters: query),
    );
    return _asJson(response);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Object? body,
    Duration? timeout,
  }) async {
    final response = await _send(
      () => _dio.post<dynamic>(
        path,
        data: body,
        options: timeout == null
            ? null
            : Options(receiveTimeout: timeout, sendTimeout: timeout),
      ),
    );
    return _asJson(response);
  }

  Map<String, dynamic> _asJson(Response<dynamic> response) {
    final data = response.data;
    if (data is Map<String, dynamic>) return data;
    return <String, dynamic>{};
  }

  Future<Response<dynamic>> _send(
    Future<Response<dynamic>> Function() call,
  ) async {
    try {
      return await call();
    } on DioException catch (error) {
      final exception = mapDioException(error);
      if (exception is UnauthorizedException) {
        _onUnauthorized?.call();
      }
      throw exception;
    }
  }
}
