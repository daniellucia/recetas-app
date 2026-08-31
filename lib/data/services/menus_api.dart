import '../../core/network/api_client.dart';
import '../models/menu.dart';
import '../models/shopping_list.dart';

/// Envuelve los endpoints de menús. Sin lógica de negocio: cada método es
/// una llamada directa a `ApiClient` → modelo.
class MenusApi {
  const MenusApi(this._client);

  final ApiClient _client;

  Future<List<Menu>> list() async {
    final json = await _client.getJson('/menus');
    return (json['data'] as List<dynamic>)
        .map((e) => Menu.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Menu?> active() async {
    final json = await _client.getJson('/menus/active');
    final menu = json['menu'];
    return menu == null ? null : Menu.fromJson(menu as Map<String, dynamic>);
  }

  Future<Menu> detail(String slug) async {
    final json = await _client.getJson('/menus/$slug');
    return Menu.fromJson(json['menu'] as Map<String, dynamic>);
  }

  Future<ShoppingList> shoppingList(String slug) async {
    final json = await _client.getJson('/menus/$slug/shopping-list');
    return ShoppingList.fromJson(json);
  }

  Future<void> markItemCooked(String slug, int itemId) =>
      _client.postJson('/menus/$slug/items/$itemId/cooked');
}
