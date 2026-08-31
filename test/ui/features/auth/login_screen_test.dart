import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:recetas_app/core/network/api_exception.dart';
import 'package:recetas_app/data/models/user.dart';
import 'package:recetas_app/data/repositories/auth_repository.dart';
import 'package:recetas_app/ui/features/auth/view_models/auth_view_model.dart';
import 'package:recetas_app/ui/features/auth/views/login_screen.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late _MockAuthRepository authRepository;

  setUp(() {
    authRepository = _MockAuthRepository();
  });

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthViewModel(authRepository: authRepository),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
  }

  testWidgets('envía email y contraseña y llama a AuthRepository.login',
      (tester) async {
    when(() => authRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
          deviceName: any(named: 'deviceName'),
        )).thenAnswer((_) async =>
        const User(id: 1, name: 'Ana', email: 'ana@example.com', householdId: 3));

    await pumpLoginScreen(tester);

    await tester.enterText(find.byType(TextFormField).first, 'ana@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'secret123');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    verify(() => authRepository.login(
          email: 'ana@example.com',
          password: 'secret123',
          deviceName: any(named: 'deviceName'),
        )).called(1);
  });

  testWidgets('muestra el error de credenciales devuelto por la API',
      (tester) async {
    when(() => authRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
          deviceName: any(named: 'deviceName'),
        )).thenThrow(const ValidationException(
      'Las credenciales no son correctas.',
      {
        'email': ['Las credenciales no son correctas.'],
      },
    ));

    await pumpLoginScreen(tester);

    await tester.enterText(find.byType(TextFormField).first, 'ana@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'wrong');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Las credenciales no son correctas.'), findsWidgets);
  });

  testWidgets('valida que email y contraseña no estén vacíos', (tester) async {
    await pumpLoginScreen(tester);

    await tester.tap(find.text('Entrar'));
    await tester.pump();

    expect(find.text('Introduce tu email.'), findsOneWidget);
    expect(find.text('Introduce tu contraseña.'), findsOneWidget);
    verifyNever(() => authRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
          deviceName: any(named: 'deviceName'),
        ));
  });
}
