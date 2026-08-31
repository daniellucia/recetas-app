import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recetas_app/data/models/paginated.dart';
import 'package:recetas_app/data/models/rating_result.dart';
import 'package:recetas_app/data/models/recipe_summary.dart';
import 'package:recetas_app/data/repositories/recipes_repository.dart';
import 'package:recetas_app/data/services/recipes_api.dart';

class _MockRecipesApi extends Mock implements RecipesApi {}

void main() {
  late _MockRecipesApi api;
  late RecipesRepository repository;

  setUp(() {
    api = _MockRecipesApi();
    repository = RecipesRepository(api);
  });

  test('search delega en RecipesApi.list con los mismos filtros', () async {
    const summary = RecipeSummary(
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
    when(() => api.list(
          search: 'lentejas',
          category: null,
          tag: null,
          favoritesOnly: true,
          sort: 'rating',
          page: 2,
        )).thenAnswer((_) async => const Paginated(
          data: [summary],
          currentPage: 2,
          lastPage: 3,
        ));

    final result = await repository.search(
      search: 'lentejas',
      favoritesOnly: true,
      sort: 'rating',
      page: 2,
    );

    expect(result.data, [summary]);
    expect(result.hasNextPage, isTrue);
  });

  test('rate delega en RecipesApi.rate y devuelve el resultado', () async {
    when(() => api.rate('lentejas-con-chorizo', 5)).thenAnswer(
      (_) async => const RatingResult(
        myRating: 5,
        averageRating: 4.5,
        ratingsCount: 4,
      ),
    );

    final result = await repository.rate('lentejas-con-chorizo', 5);

    expect(result.myRating, 5);
    verify(() => api.rate('lentejas-con-chorizo', 5)).called(1);
  });
}
