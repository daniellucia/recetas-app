import 'package:flutter/foundation.dart';

import '../../../../data/models/menu.dart';
import '../../../../data/repositories/menus_repository.dart';

class MenuViewModel extends ChangeNotifier {
  MenuViewModel({required MenusRepository menusRepository})
      : _repository = menusRepository {
    load();
  }

  final MenusRepository _repository;

  Menu? menu;
  bool isLoading = true;
  Object? error;
  Set<int> markingItemIds = {};

  Future<void> load() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      menu = await _repository.active();
    } catch (e) {
      error = e;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markItemCooked(MenuItem item) async {
    final current = menu;
    if (current == null || markingItemIds.contains(item.id)) return;
    markingItemIds = {...markingItemIds, item.id};
    notifyListeners();
    try {
      await _repository.markItemCooked(current.slug, item.id);
      menu = await _repository.active();
    } catch (e) {
      error = e;
    } finally {
      markingItemIds = {...markingItemIds}..remove(item.id);
      notifyListeners();
    }
  }
}
