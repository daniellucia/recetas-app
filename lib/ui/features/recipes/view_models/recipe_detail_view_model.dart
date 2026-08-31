import 'package:flutter/foundation.dart';

import '../../../../data/models/recipe_detail.dart';
import '../../../../data/repositories/recipes_repository.dart';

class RecipeDetailViewModel extends ChangeNotifier {
  RecipeDetailViewModel({
    required RecipesRepository recipesRepository,
    required this.slug,
  }) : _repository = recipesRepository {
    _load();
  }

  final RecipesRepository _repository;
  final String slug;

  RecipeDetail? recipe;
  bool isLoading = true;
  Object? error;
  bool isUpdatingServings = false;
  bool isTogglingFavorite = false;
  bool isRating = false;
  bool isMarkingCooked = false;
  String? cookedMessage;

  Future<void> _load({int? servings}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      recipe = await _repository.detail(slug, servings: servings);
    } catch (e) {
      error = e;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reload() => _load(servings: recipe?.servings);

  Future<void> setServings(int servings) async {
    if (servings < 1 || isUpdatingServings) return;
    isUpdatingServings = true;
    notifyListeners();
    try {
      recipe = await _repository.detail(slug, servings: servings);
    } catch (e) {
      error = e;
    } finally {
      isUpdatingServings = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite() async {
    final current = recipe;
    if (current == null || isTogglingFavorite) return;
    isTogglingFavorite = true;
    recipe = current.copyWith(isFavorited: !current.isFavorited);
    notifyListeners();
    try {
      final isFavorited = await _repository.toggleFavorite(slug);
      recipe = recipe?.copyWith(isFavorited: isFavorited);
    } catch (e) {
      recipe = current;
      error = e;
    } finally {
      isTogglingFavorite = false;
      notifyListeners();
    }
  }

  Future<void> rate(int rating) async {
    if (recipe == null || isRating) return;
    isRating = true;
    notifyListeners();
    try {
      final result = await _repository.rate(slug, rating);
      recipe = recipe?.copyWith(
        myRating: result.myRating,
        averageRating: result.averageRating,
        ratingsCount: result.ratingsCount,
      );
    } catch (e) {
      error = e;
    } finally {
      isRating = false;
      notifyListeners();
    }
  }

  Future<void> markCooked() async {
    if (recipe == null || isMarkingCooked) return;
    isMarkingCooked = true;
    cookedMessage = null;
    notifyListeners();
    try {
      final timesCooked = await _repository.markCooked(slug);
      recipe = recipe?.copyWith(timesCooked: timesCooked);
      cookedMessage = '¡Receta marcada como cocinada!';
    } catch (e) {
      error = e;
    } finally {
      isMarkingCooked = false;
      notifyListeners();
    }
  }
}
