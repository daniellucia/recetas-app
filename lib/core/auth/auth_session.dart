import 'package:flutter/foundation.dart';

import '../../data/models/user.dart';

/// Fuente de verdad, a nivel de app, de si hay una sesión activa. La usan
/// tanto `ApiClient` (para reaccionar a un 401 en cualquier petición) como
/// `go_router` (`refreshListenable`) para redirigir a login sin que ninguna
/// pantalla concreta tenga que orquestarlo.
///
/// Deliberadamente separada de `AuthRepository`/`AuthViewModel`: si
/// `AuthRepository` dependiera del `ApiClient` y el `ApiClient` dependiera a
/// su vez de `AuthRepository` para notificar un 401, se cerraría un ciclo de
/// dependencias. `AuthSession` no depende de nada y ambos la observan.
class AuthSession extends ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void clear() {
    if (_currentUser == null) return;
    _currentUser = null;
    notifyListeners();
  }
}
