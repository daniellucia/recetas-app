import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recetas_app/data/models/menu.dart';
import 'package:recetas_app/data/repositories/menus_repository.dart';
import 'package:recetas_app/data/services/menus_api.dart';

class _MockMenusApi extends Mock implements MenusApi {}

void main() {
  late _MockMenusApi api;
  late MenusRepository repository;

  setUp(() {
    api = _MockMenusApi();
    repository = MenusRepository(api);
  });

  test('active delega en MenusApi.active y puede devolver null', () async {
    when(() => api.active()).thenAnswer((_) async => null);

    final result = await repository.active();

    expect(result, isNull);
  });

  test('active devuelve el menú cuando lo hay', () async {
    const menu = Menu(
      id: 1,
      slug: 'menu-semana-1',
      name: 'Semana 1',
      servings: 4,
      isActive: true,
      activeWeekStart: '2026-08-25',
      items: [],
    );
    when(() => api.active()).thenAnswer((_) async => menu);

    final result = await repository.active();

    expect(result, menu);
  });

  test('markItemCooked delega en MenusApi.markItemCooked', () async {
    when(() => api.markItemCooked('menu-semana-1', 10))
        .thenAnswer((_) async {});

    await repository.markItemCooked('menu-semana-1', 10);

    verify(() => api.markItemCooked('menu-semana-1', 10)).called(1);
  });
}
