import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:recetas_app/data/models/ingredient_line.dart';
import 'package:recetas_app/data/models/rating_result.dart';
import 'package:recetas_app/data/models/recipe_detail.dart';
import 'package:recetas_app/data/repositories/recipes_repository.dart';
import 'package:recetas_app/ui/features/recipes/view_models/recipe_detail_view_model.dart';
import 'package:recetas_app/ui/features/recipes/views/recipe_detail_screen.dart';

class _MockRecipesRepository extends Mock implements RecipesRepository {}

RecipeDetail _buildRecipe({List<String>? steps}) => RecipeDetail(
      id: 22,
      slug: 'lentejas-con-chorizo',
      title: 'Lentejas con chorizo',
      description: 'Un plato de cuchara clásico.',
      imageUrl: null,
      baseServings: 4,
      servings: 4,
      prepTimeMinutes: 25,
      cookTimeMinutes: 90,
      difficulty: 'medium',
      difficultyLabel: 'Media',
      categories: const ['Carne'],
      tags: const [],
      sourceUrl: null,
      sourceAuthor: null,
      instructionsSteps: steps,
      instructionsText: steps == null ? 'Cocinar todo junto.' : null,
      ingredients: const [
        IngredientLine(
          ingredientId: 5,
          name: 'Lentejas',
          unit: 'g',
          notes: null,
          isMain: true,
          quantity: 600,
        ),
      ],
      isFavorited: false,
      myRating: null,
      averageRating: 4.5,
      ratingsCount: 3,
      timesCooked: 2,
    );

void main() {
  late _MockRecipesRepository repository;

  setUp(() {
    repository = _MockRecipesRepository();
  });

  Future<void> pumpScreen(WidgetTester tester, RecipeDetail recipe) async {
    // El detalle es una CustomScrollView con slivers perezosos: se agranda
    // el viewport de test para que todo el contenido esté ya construido y
    // sea buscable/tocable sin tener que hacer scroll manual.
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    when(() => repository.detail('lentejas-con-chorizo', servings: null))
        .thenAnswer((_) async => recipe);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => RecipeDetailViewModel(
          recipesRepository: repository,
          slug: 'lentejas-con-chorizo',
        ),
        child: const MaterialApp(home: RecipeDetailScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('pinta título, ingredientes y pasos numerados', (tester) async {
    await pumpScreen(tester, _buildRecipe(steps: ['Sofríe la cebolla.', 'Añade las lentejas.']));

    expect(find.text('Lentejas con chorizo'), findsOneWidget);
    expect(find.text('Lentejas'), findsOneWidget);
    expect(find.text('Sofríe la cebolla.'), findsOneWidget);
    expect(find.text('Modo cocina'), findsOneWidget);
  });

  testWidgets('usa el texto libre cuando no hay pasos numerados', (tester) async {
    await pumpScreen(tester, _buildRecipe(steps: null));

    expect(find.text('Cocinar todo junto.'), findsOneWidget);
    expect(find.text('Modo cocina'), findsNothing);
  });

  testWidgets('marcar como favorita llama al repositorio', (tester) async {
    final recipe = _buildRecipe(steps: null);
    when(() => repository.toggleFavorite('lentejas-con-chorizo'))
        .thenAnswer((_) async => true);
    await pumpScreen(tester, recipe);

    await tester.tap(find.byKey(const ValueKey('recipe-detail-favorite')));
    await tester.pumpAndSettle();

    verify(() => repository.toggleFavorite('lentejas-con-chorizo')).called(1);
  });

  testWidgets('marcar como cocinada llama al repositorio', (tester) async {
    final recipe = _buildRecipe(steps: null);
    when(() => repository.markCooked('lentejas-con-chorizo'))
        .thenAnswer((_) async => 3);
    await pumpScreen(tester, recipe);

    await tester.tap(find.text('Marcar como cocinada'));
    await tester.pumpAndSettle();

    verify(() => repository.markCooked('lentejas-con-chorizo')).called(1);
    expect(find.text('¡Receta marcada como cocinada!'), findsOneWidget);
  });

  testWidgets('valorar con estrellas llama al repositorio', (tester) async {
    final recipe = _buildRecipe(steps: null);
    when(() => repository.rate('lentejas-con-chorizo', 5)).thenAnswer(
      (_) async => const RatingResult(myRating: 5, averageRating: 4.7, ratingsCount: 4),
    );
    await pumpScreen(tester, recipe);

    await tester.tap(find.byKey(const ValueKey('rating-star-5')));
    await tester.pumpAndSettle();

    verify(() => repository.rate('lentejas-con-chorizo', 5)).called(1);
  });
}
