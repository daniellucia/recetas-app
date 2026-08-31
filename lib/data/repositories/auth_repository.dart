import '../../core/auth/auth_session.dart';
import '../../core/network/api_exception.dart';
import '../models/user.dart';
import '../services/auth_api.dart';
import '../services/token_store.dart';

/// Orquesta login/logout/restauración de sesión: llama a [AuthApi],
/// persiste el token en [TokenStore] y mantiene [AuthSession] al día.
class AuthRepository {
  AuthRepository({
    required AuthApi authApi,
    required TokenStore tokenStore,
    required AuthSession authSession,
  })  : _authApi = authApi,
        _tokenStore = tokenStore,
        _authSession = authSession;

  final AuthApi _authApi;
  final TokenStore _tokenStore;
  final AuthSession _authSession;

  Future<User> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    final result = await _authApi.login(
      email: email,
      password: password,
      deviceName: deviceName,
    );
    await _tokenStore.saveToken(result.token);
    _authSession.setUser(result.user);
    return result.user;
  }

  Future<void> logout() async {
    try {
      await _authApi.logout();
    } on ApiException {
      // El token ya podría ser inválido; da igual, se borra igualmente.
    } finally {
      await _tokenStore.clearToken();
      _authSession.clear();
    }
  }

  /// Al abrir la app: si hay token guardado, lo valida contra `/api/me`.
  /// Si el token es inválido/caducado, lo borra y devuelve `null` (vuelve a
  /// login). Si falla por red, propaga el error para que la UI pueda
  /// reintentar sin forzar un logout por un problema transitorio.
  Future<User?> tryRestoreSession() async {
    final token = await _tokenStore.readToken();
    if (token == null) return null;

    try {
      final user = await _authApi.me();
      _authSession.setUser(user);
      return user;
    } on UnauthorizedException {
      await _tokenStore.clearToken();
      _authSession.clear();
      return null;
    }
  }
}
