/// Un ingrediente de `RecipeDetail.ingredients`, con la cantidad ya
/// escalada al número de raciones pedido.
class IngredientLine {
  const IngredientLine({
    required this.ingredientId,
    required this.name,
    required this.unit,
    required this.notes,
    required this.isMain,
    required this.quantity,
  });

  factory IngredientLine.fromJson(Map<String, dynamic> json) =>
      IngredientLine(
        ingredientId: json['ingredient_id'] as int,
        name: json['name'] as String,
        unit: json['unit'] as String?,
        notes: json['notes'] as String?,
        isMain: json['is_main'] as bool? ?? false,
        quantity: (json['quantity'] as num).toDouble(),
      );

  final int ingredientId;
  final String name;
  final String? unit;
  final String? notes;
  final bool isMain;
  final double quantity;
}
