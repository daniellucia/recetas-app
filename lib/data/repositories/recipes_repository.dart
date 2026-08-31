import '../models/import_result.dart';
import '../models/paginated.dart';
import '../models/rating_result.dart';
import '../models/recipe_detail.dart';
import '../models/recipe_summary.dart';
import '../services/recipes_api.dart';

/// Fuente única de recetas para los ViewModels. Delgado a propósito: la API
/// ya devuelve exactamente lo que la UI necesita, no hay transformación de
/// dominio real que aplicar aquí.
class RecipesRepository {
  const RecipesRepository(this._api);

  final RecipesApi _api;

  Future<Paginated<RecipeSummary>> search({
    String? search,
    String? category,
    String? tag,
    bool? favoritesOnly,
    String? sort,
    int page = 1,
  }) =>
      _api.list(
        search: search,
        category: category,
        tag: tag,
        favoritesOnly: favoritesOnly,
        sort: sort,
        page: page,
      );

  Future<RecipeDetail> detail(String slug, {int? servings}) =>
      _api.detail(slug, servings: servings);

  Future<bool> toggleFavorite(String slug) => _api.toggleFavorite(slug);

  Future<RatingResult> rate(String slug, int rating) =>
      _api.rate(slug, rating);

  Future<int> markCooked(String slug) => _api.markCooked(slug);

  Future<ImportResult> importFromUrl(String url) => _api.importFromUrl(url);
}
