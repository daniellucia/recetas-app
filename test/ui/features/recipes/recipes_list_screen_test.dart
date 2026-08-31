import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:recetas_app/data/models/paginated.dart';
import 'package:recetas_app/data/models/recipe_summary.dart';
import 'package:recetas_app/data/repositories/recipes_repository.dart';
import 'package:recetas_app/ui/features/recipes/view_models/recipes_list_view_model.dart';
import 'package:recetas_app/ui/features/recipes/views/recipes_list_screen.dart';

class _MockRecipesRepository extends Mock implements RecipesRepository {}

const _lentejas = RecipeSummary(
  id: 22,
  slug: 'lentejas-con-chorizo',
  title: 'Lentejas con chorizo',
  description: null,
  imageUrl: null,
  baseServings: 4,
  prepTimeMinutes: 25,
  cookTimeMinutes: 90,
  difficulty: 'medium',
  difficultyLabel: 'Media',
  categories: ['Carne'],
  tags: [],
  averageRating: 4.5,
  ratingsCount: 3,
  isFavorited: false,
);

void main() {
  late _MockRecipesRepository repository;

  setUp(() {
    repository = _MockRecipesRepository();
    registerFallbackValue(false);
  });

  void stubSearch(List<RecipeSummary> data) {
    when(() => repository.search(
          search: any(named: 'search'),
          category: any(named: 'category'),
          tag: any(named: 'tag'),
          favoritesOnly: any(named: 'favoritesOnly'),
          sort: any(named: 'sort'),
          page: any(named: 'page'),
        )).thenAnswer(
      (_) async => Paginated(data: data, currentPage: 1, lastPage: 1),
    );
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => RecipesListViewModel(recipesRepository: repository),
        child: const MaterialApp(home: RecipesListScreen()),
      ),
    );
  }

  testWidgets('pinta la lista de recetas tras cargar', (tester) async {
    stubSearch([_lentejas]);

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Lentejas con chorizo'), findsOneWidget);
    expect(find.text('Carne'), findsOneWidget);
  });

  testWidgets('muestra un estado vacío cuando no hay resultados', (tester) async {
    stubSearch([]);

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('No se encontraron recetas'), findsOneWidget);
  });

  testWidgets('alterna el favorito al tocar el icono', (tester) async {
    stubSearch([_lentejas]);
    when(() => repository.toggleFavorite('lentejas-con-chorizo'))
        .thenAnswer((_) async => true);

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    final favoriteButton = find.byKey(const ValueKey('favorite-lentejas-con-chorizo'));
    await tester.tap(favoriteButton);
    await tester.pumpAndSettle();

    verify(() => repository.toggleFavorite('lentejas-con-chorizo')).called(1);
    expect(
      find.descendant(of: favoriteButton, matching: find.byIcon(Icons.favorite_rounded)),
      findsOneWidget,
    );
  });
}
