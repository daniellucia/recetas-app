import '../models/menu.dart';
import '../models/shopping_list.dart';
import '../services/menus_api.dart';

/// Fuente única de menús para los ViewModels. Delgado a propósito (ver
/// `RecipesRepository`).
class MenusRepository {
  const MenusRepository(this._api);

  final MenusApi _api;

  Future<List<Menu>> list() => _api.list();

  Future<Menu?> active() => _api.active();

  Future<Menu> detail(String slug) => _api.detail(slug);

  Future<ShoppingList> shoppingList(String slug) => _api.shoppingList(slug);

  Future<void> markItemCooked(String slug, int itemId) =>
      _api.markItemCooked(slug, itemId);
}
