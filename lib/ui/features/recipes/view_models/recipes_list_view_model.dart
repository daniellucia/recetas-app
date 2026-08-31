import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/models/recipe_summary.dart';
import '../../../../data/repositories/recipes_repository.dart';

enum RecipeSortOption {
  recent('', 'Más recientes'),
  rating('rating', 'Mejor valoradas'),
  name('name', 'Nombre');

  const RecipeSortOption(this.apiValue, this.label);

  final String apiValue;
  final String label;
}

/// Estado de la pantalla "Explorar recetas": búsqueda con debounce, filtro
/// de favoritas, orden y scroll infinito sobre la paginación de la API.
class RecipesListViewModel extends ChangeNotifier {
  RecipesListViewModel({required RecipesRepository recipesRepository})
      : _repository = recipesRepository {
    _load(reset: true);
  }

  final RecipesRepository _repository;
  Timer? _debounce;

  List<RecipeSummary> items = [];
  bool isLoading = true;
  bool isLoadingMore = false;
  bool favoritesOnly = false;
  RecipeSortOption sort = RecipeSortOption.recent;
  String query = '';
  Object? error;

  int _page = 1;
  bool _hasNextPage = true;
  bool get hasNextPage => _hasNextPage;

  void setQuery(String value) {
    query = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _load(reset: true));
  }

  void setFavoritesOnly(bool value) {
    if (favoritesOnly == value) return;
    favoritesOnly = value;
    _load(reset: true);
  }

  void setSort(RecipeSortOption value) {
    if (sort == value) return;
    sort = value;
    _load(reset: true);
  }

  Future<void> refresh() => _load(reset: true);

  Future<void> loadMore() async {
    if (isLoading || isLoadingMore || !_hasNextPage) return;
    await _load(reset: false);
  }

  Future<void> _load({required bool reset}) async {
    if (reset) {
      isLoading = true;
      error = null;
      _page = 1;
    } else {
      isLoadingMore = true;
    }
    notifyListeners();

    try {
      final page = reset ? 1 : _page + 1;
      final result = await _repository.search(
        search: query,
        favoritesOnly: favoritesOnly ? true : null,
        sort: sort.apiValue,
        page: page,
      );
      items = reset ? result.data : [...items, ...result.data];
      _page = result.currentPage;
      _hasNextPage = result.hasNextPage;
      error = null;
    } catch (e) {
      error = e;
    } finally {
      isLoading = false;
      isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(RecipeSummary recipe) async {
    final index = items.indexWhere((r) => r.slug == recipe.slug);
    if (index == -1) return;

    final optimistic = recipe.copyWith(isFavorited: !recipe.isFavorited);
    items = [...items]..[index] = optimistic;
    notifyListeners();

    try {
      final isFavorited = await _repository.toggleFavorite(recipe.slug);
      items = [...items]..[index] = optimistic.copyWith(isFavorited: isFavorited);
      notifyListeners();
    } catch (_) {
      // Revierte el optimismo si la petición falla.
      items = [...items]..[index] = recipe;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
