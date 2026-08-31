import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recetas_app/core/auth/auth_session.dart';
import 'package:recetas_app/core/network/api_exception.dart';
import 'package:recetas_app/data/models/login_result.dart';
import 'package:recetas_app/data/models/user.dart';
import 'package:recetas_app/data/repositories/auth_repository.dart';
import 'package:recetas_app/data/services/auth_api.dart';
import 'package:recetas_app/data/services/token_store.dart';

class _MockAuthApi extends Mock implements AuthApi {}

class _MockTokenStore extends Mock implements TokenStore {}

void main() {
  late _MockAuthApi authApi;
  late _MockTokenStore tokenStore;
  late AuthSession authSession;
  late AuthRepository repository;

  const user = User(id: 1, name: 'Ana', email: 'ana@example.com', householdId: 3);

  setUp(() {
    authApi = _MockAuthApi();
    tokenStore = _MockTokenStore();
    authSession = AuthSession();
    repository = AuthRepository(
      authApi: authApi,
      tokenStore: tokenStore,
      authSession: authSession,
    );
    when(() => tokenStore.saveToken(any())).thenAnswer((_) async {});
    when(() => tokenStore.clearToken()).thenAnswer((_) async {});
  });

  group('login', () {
    test('guarda el token y actualiza AuthSession en éxito', () async {
      when(() => authApi.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
            deviceName: any(named: 'deviceName'),
          )).thenAnswer((_) async => const LoginResult(token: 'abc123', user: user));

      final result = await repository.login(
        email: 'ana@example.com',
        password: 'secret',
        deviceName: 'App Android',
      );

      expect(result, user);
      expect(authSession.isAuthenticated, isTrue);
      expect(authSession.currentUser, user);
      verify(() => tokenStore.saveToken('abc123')).called(1);
    });

    test('propaga ValidationException sin tocar la sesión', () async {
      when(() => authApi.login(
            email: any(named: 'email'),
            password: any(named: 'password'),
            deviceName: any(named: 'deviceName'),
          )).thenThrow(const ValidationException(
        'Las credenciales no son correctas.',
        {
          'email': ['Las credenciales no son correctas.'],
        },
      ));

      await expectLater(
        repository.login(
          email: 'ana@example.com',
          password: 'bad',
          deviceName: 'App Android',
        ),
        throwsA(isA<ValidationException>()),
      );
      expect(authSession.isAuthenticated, isFalse);
      verifyNever(() => tokenStore.saveToken(any()));
    });
  });

  group('logout', () {
    test('borra el token y limpia la sesión aunque falle el logout remoto',
        () async {
      authSession.setUser(user);
      when(() => authApi.logout()).thenThrow(const UnauthorizedException());

      await repository.logout();

      expect(authSession.isAuthenticated, isFalse);
      verify(() => tokenStore.clearToken()).called(1);
    });
  });

  group('tryRestoreSession', () {
    test('sin token guardado, no llama a /me y devuelve null', () async {
      when(() => tokenStore.readToken()).thenAnswer((_) async => null);

      final result = await repository.tryRestoreSession();

      expect(result, isNull);
      verifyNever(() => authApi.me());
    });

    test('con token válido, restaura la sesión', () async {
      when(() => tokenStore.readToken()).thenAnswer((_) async => 'abc123');
      when(() => authApi.me()).thenAnswer((_) async => user);

      final result = await repository.tryRestoreSession();

      expect(result, user);
      expect(authSession.isAuthenticated, isTrue);
    });

    test('con token revocado (401), lo borra y devuelve null', () async {
      when(() => tokenStore.readToken()).thenAnswer((_) async => 'expired');
      when(() => authApi.me()).thenThrow(const UnauthorizedException());

      final result = await repository.tryRestoreSession();

      expect(result, isNull);
      expect(authSession.isAuthenticated, isFalse);
      verify(() => tokenStore.clearToken()).called(1);
    });

    test('con fallo de red, propaga el error sin tocar el token', () async {
      when(() => tokenStore.readToken()).thenAnswer((_) async => 'abc123');
      when(() => authApi.me()).thenThrow(const NetworkException());

      await expectLater(
        repository.tryRestoreSession(),
        throwsA(isA<NetworkException>()),
      );
      verifyNever(() => tokenStore.clearToken());
    });
  });
}
