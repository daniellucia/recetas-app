import '../../config/api_config.dart';
import '../../core/network/api_client.dart';
import '../models/import_result.dart';
import '../models/paginated.dart';
import '../models/rating_result.dart';
import '../models/recipe_detail.dart';
import '../models/recipe_summary.dart';

/// Envuelve los endpoints de recetas. Sin lógica de negocio: cada método es
/// una llamada directa a `ApiClient` → modelo.
class RecipesApi {
  const RecipesApi(this._client);

  final ApiClient _client;

  Future<Paginated<RecipeSummary>> list({
    String? search,
    String? category,
    String? tag,
    bool? favoritesOnly,
    String? sort,
    int page = 1,
    int perPage = 20,
  }) async {
    final json = await _client.getJson('/recipes', query: {
      'search': (search == null || search.isEmpty) ? null : search,
      'category': category,
      'tag': tag,
      'favorites_only': favoritesOnly == true ? '1' : null,
      'sort': (sort == null || sort.isEmpty) ? null : sort,
      'page': page,
      'per_page': perPage,
    });
    return Paginated.fromJson(json, RecipeSummary.fromJson);
  }

  Future<RecipeDetail> detail(String slug, {int? servings}) async {
    final json = await _client.getJson(
      '/recipes/$slug',
      query: servings == null ? null : {'servings': servings},
    );
    return RecipeDetail.fromJson(json['recipe'] as Map<String, dynamic>);
  }

  Future<bool> toggleFavorite(String slug) async {
    final json = await _client.postJson('/recipes/$slug/favorite');
    return json['is_favorited'] as bool;
  }

  Future<RatingResult> rate(String slug, int rating) async {
    final json = await _client.postJson(
      '/recipes/$slug/rate',
      body: {'rating': rating},
    );
    return RatingResult.fromJson(json);
  }

  Future<int> markCooked(String slug) async {
    final json = await _client.postJson('/recipes/$slug/cooked');
    return json['times_cooked'] as int;
  }

  Future<ImportResult> importFromUrl(String url) async {
    final json = await _client.postJson(
      '/recipes/import',
      body: {'url': url},
      timeout: ApiConfig.importTimeout,
    );
    return ImportResult.fromJson(json);
  }
}
