import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../data/models/shopping_list.dart';
import '../../../../data/repositories/menus_repository.dart';

/// El estado de "tachado" es puramente del dispositivo (como el
/// `localStorage` de la web): no se envía nunca al servidor.
class ShoppingListViewModel extends ChangeNotifier {
  ShoppingListViewModel({required MenusRepository menusRepository})
      : _repository = menusRepository {
    load();
  }

  final MenusRepository _repository;

  ShoppingList? shoppingList;
  String? _menuSlug;
  bool isLoading = true;
  Object? error;
  Set<int> checkedIds = {};

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final menu = await _repository.active();
      if (menu == null) {
        shoppingList = null;
        _menuSlug = null;
      } else {
        _menuSlug = menu.slug;
        shoppingList = await _repository.shoppingList(menu.slug);
        await _loadCheckedState();
      }
    } catch (e) {
      error = e;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  String get _prefsKey => 'shopping_checked_${_menuSlug ?? ''}';

  Future<void> _loadCheckedState() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? const [];
    checkedIds = raw.map(int.parse).toSet();
  }

  Future<void> toggle(int ingredientId) async {
    checkedIds = checkedIds.contains(ingredientId)
        ? ({...checkedIds}..remove(ingredientId))
        : {...checkedIds, ingredientId};
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      checkedIds.map((e) => e.toString()).toList(),
    );
  }
}
