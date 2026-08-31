import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../data/repositories/auth_repository.dart';

/// Estado de UI de la pantalla de login. La verdad de "hay sesión o no" la
/// mantiene `AuthSession` (ver `core/auth/auth_session.dart`); este
/// ViewModel solo orquesta el formulario: carga, error general y errores
/// por campo.
class AuthViewModel extends ChangeNotifier {
  AuthViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository;

  final AuthRepository _authRepository;

  bool isLoading = false;
  String? errorMessage;
  Map<String, List<String>> fieldErrors = const {};

  String? fieldError(String field) => fieldErrors[field]?.firstOrNull;

  Future<bool> login({required String email, required String password}) async {
    isLoading = true;
    errorMessage = null;
    fieldErrors = const {};
    notifyListeners();

    try {
      final deviceName = await _resolveDeviceName();
      await _authRepository.login(
        email: email,
        password: password,
        deviceName: deviceName,
      );
      return true;
    } on ValidationException catch (e) {
      errorMessage = e.message;
      fieldErrors = e.errors;
      return false;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String> _resolveDeviceName() async {
    try {
      final plugin = DeviceInfoPlugin();
      if (Platform.isIOS) {
        final info = await plugin.iosInfo;
        return info.name.isNotEmpty ? info.name : 'App iOS';
      }
      if (Platform.isAndroid) {
        final info = await plugin.androidInfo;
        return info.model.isNotEmpty ? info.model : 'App Android';
      }
    } catch (_) {
      // Sin acceso a la info del dispositivo: se usa el fallback genérico.
    }
    return Platform.isIOS ? 'App iOS' : 'App Android';
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
