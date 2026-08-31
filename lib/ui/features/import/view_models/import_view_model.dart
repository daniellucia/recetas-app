import 'package:flutter/foundation.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../data/models/import_result.dart';
import '../../../../data/repositories/recipes_repository.dart';

class ImportViewModel extends ChangeNotifier {
  ImportViewModel({required RecipesRepository recipesRepository})
      : _repository = recipesRepository;

  final RecipesRepository _repository;

  bool isLoading = false;
  ImportResult? lastResult;
  String? errorMessage;

  Future<void> importFromUrl(String url) async {
    isLoading = true;
    lastResult = null;
    errorMessage = null;
    notifyListeners();

    try {
      lastResult = await _repository.importFromUrl(url.trim());
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    lastResult = null;
    errorMessage = null;
    notifyListeners();
  }
}
