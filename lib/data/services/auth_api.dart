import '../../core/network/api_client.dart';
import '../models/login_result.dart';
import '../models/user.dart';

/// Envuelve los endpoints de autenticación (`/api/login`, `/api/logout`,
/// `/api/me`). Sin lógica de negocio: cada método es una llamada directa.
class AuthApi {
  const AuthApi(this._client);

  final ApiClient _client;

  Future<LoginResult> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    final json = await _client.postJson(
      '/login',
      body: {
        'email': email,
        'password': password,
        'device_name': deviceName,
      },
    );
    return LoginResult.fromJson(json);
  }

  Future<void> logout() => _client.postJson('/logout');

  Future<User> me() async {
    final json = await _client.getJson('/me');
    return User.fromJson(json['user'] as Map<String, dynamic>);
  }
}
