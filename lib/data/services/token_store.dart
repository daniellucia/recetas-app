import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda el token Bearer en el almacenamiento seguro del dispositivo.
/// Nunca en `SharedPreferences` en plano.
class TokenStore {
  TokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'recetas_auth_token';

  final FlutterSecureStorage _storage;

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);

  Future<void> clearToken() => _storage.delete(key: _tokenKey);
}
