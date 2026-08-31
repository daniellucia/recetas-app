import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/auth/auth_session.dart';
import 'core/network/api_client.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/menus_repository.dart';
import 'data/repositories/recipes_repository.dart';
import 'data/services/auth_api.dart';
import 'data/services/menus_api.dart';
import 'data/services/recipes_api.dart';
import 'data/services/token_store.dart';
import 'routing/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStore = TokenStore();
  final authSession = AuthSession();

  final apiClient = ApiClient(
    tokenReader: tokenStore.readToken,
    onUnauthorized: () {
      tokenStore.clearToken();
      authSession.clear();
    },
  );

  final authRepository = AuthRepository(
    authApi: AuthApi(apiClient),
    tokenStore: tokenStore,
    authSession: authSession,
  );
  final recipesRepository = RecipesRepository(RecipesApi(apiClient));
  final menusRepository = MenusRepository(MenusApi(apiClient));

  try {
    // Valida el token guardado contra /api/me antes de pintar nada, para
    // no enseñar login parpadeando si ya hay sesión.
    await authRepository.tryRestoreSession();
  } catch (_) {
    // Sin red al abrir: se queda sin sesión, el usuario puede reintentar
    // iniciando sesión manualmente en cuanto quiera.
  }

  final router = buildAppRouter(authSession: authSession);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authSession),
        Provider<AuthRepository>.value(value: authRepository),
        Provider<RecipesRepository>.value(value: recipesRepository),
        Provider<MenusRepository>.value(value: menusRepository),
      ],
      child: RecetasApp(router: router),
    ),
  );
}
