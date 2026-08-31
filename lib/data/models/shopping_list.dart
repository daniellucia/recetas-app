class ShoppingListItem {
  const ShoppingListItem({
    required this.ingredientId,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.isMain,
  });

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) =>
      ShoppingListItem(
        ingredientId: json['ingredient_id'] as int,
        name: json['name'] as String,
        unit: json['unit'] as String?,
        quantity: (json['quantity'] as num).toDouble(),
        isMain: json['is_main'] as bool? ?? false,
      );

  final int ingredientId;
  final String name;
  final String? unit;
  final double quantity;
  final bool isMain;
}

/// `GET /api/menus/{slug}/shopping-list`.
class ShoppingList {
  const ShoppingList({required this.servings, required this.items});

  factory ShoppingList.fromJson(Map<String, dynamic> json) => ShoppingList(
        servings: json['servings'] as int,
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => ShoppingListItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final int servings;
  final List<ShoppingListItem> items;
}
