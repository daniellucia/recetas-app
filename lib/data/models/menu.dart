/// Referencia ligera a una receta dentro de un item de menú.
class MenuRecipeRef {
  const MenuRecipeRef({
    required this.id,
    required this.slug,
    required this.title,
    required this.imageUrl,
  });

  factory MenuRecipeRef.fromJson(Map<String, dynamic> json) => MenuRecipeRef(
        id: json['id'] as int,
        slug: json['slug'] as String,
        title: json['title'] as String,
        imageUrl: json['image_url'] as String?,
      );

  final int id;
  final String slug;
  final String title;
  final String? imageUrl;
}

/// `day_of_week` ∈ monday..sunday, `meal_type` ∈ lunch|dinner. Puede haber
/// varios items para el mismo día+comida (primer plato + segundo).
class MenuItem {
  const MenuItem({
    required this.id,
    required this.dayOfWeek,
    required this.dayLabel,
    required this.mealType,
    required this.mealLabel,
    required this.recipe,
    required this.cookedAt,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'] as int,
        dayOfWeek: json['day_of_week'] as String,
        dayLabel: json['day_label'] as String,
        mealType: json['meal_type'] as String,
        mealLabel: json['meal_label'] as String,
        recipe:
            MenuRecipeRef.fromJson(json['recipe'] as Map<String, dynamic>),
        cookedAt: json['cook_answer'],
      );

  final int id;
  final String dayOfWeek;
  final String dayLabel;
  final String mealType;
  final String mealLabel;
  final MenuRecipeRef recipe;

  /// Valor de `cook_answer` tal cual lo da la API (su forma exacta no está
  /// documentada); se usa solo como señal de "ya cocinado" cuando no es
  /// `null`, sin asumir más estructura.
  final Object? cookedAt;

  bool get isCooked => cookedAt != null;
}

class Menu {
  const Menu({
    required this.id,
    required this.slug,
    required this.name,
    required this.servings,
    required this.isActive,
    required this.activeWeekStart,
    required this.items,
  });

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
        id: json['id'] as int,
        slug: json['slug'] as String,
        name: json['name'] as String,
        servings: json['servings'] as int,
        isActive: json['is_active'] as bool? ?? false,
        activeWeekStart: json['active_week_start'] as String?,
        items: (json['items'] as List<dynamic>? ?? [])
            .map((e) => MenuItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final int id;
  final String slug;
  final String name;
  final int servings;
  final bool isActive;
  final String? activeWeekStart;
  final List<MenuItem> items;
}
