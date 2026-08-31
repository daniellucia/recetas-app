import 'ingredient_line.dart';

/// El detalle completo de `GET /api/recipes/{slug}`, con las cantidades ya
/// escaladas a [servings].
class RecipeDetail {
  const RecipeDetail({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.baseServings,
    required this.servings,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.difficulty,
    required this.difficultyLabel,
    required this.categories,
    required this.tags,
    required this.sourceUrl,
    required this.sourceAuthor,
    required this.instructionsSteps,
    required this.instructionsText,
    required this.ingredients,
    required this.isFavorited,
    required this.myRating,
    required this.averageRating,
    required this.ratingsCount,
    required this.timesCooked,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    final rawSteps = json['instructions_steps'];
    return RecipeDetail(
      id: json['id'] as int,
      slug: json['slug'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      baseServings: json['base_servings'] as int,
      servings: json['servings'] as int,
      prepTimeMinutes: json['prep_time_minutes'] as int?,
      cookTimeMinutes: json['cook_time_minutes'] as int?,
      difficulty: json['difficulty'] as String?,
      difficultyLabel: json['difficulty_label'] as String?,
      categories: (json['categories'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      tags:
          (json['tags'] as List<dynamic>? ?? []).map((e) => e as String).toList(),
      sourceUrl: json['source_url'] as String?,
      sourceAuthor: json['source_author'] as String?,
      instructionsSteps: rawSteps is List
          ? rawSteps.map((e) => e.toString()).toList()
          : null,
      instructionsText: json['instructions_text'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>? ?? [])
          .map((e) => IngredientLine.fromJson(e as Map<String, dynamic>))
          .toList(),
      isFavorited: json['is_favorited'] as bool? ?? false,
      myRating: json['my_rating'] as int?,
      averageRating: (json['average_rating'] as num?)?.toDouble(),
      ratingsCount: json['ratings_count'] as int?,
      timesCooked: json['times_cooked'] as int? ?? 0,
    );
  }

  final int id;
  final String slug;
  final String title;
  final String? description;
  final String? imageUrl;
  final int baseServings;
  final int servings;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final String? difficulty;
  final String? difficultyLabel;
  final List<String> categories;
  final List<String> tags;
  final String? sourceUrl;
  final String? sourceAuthor;

  /// Si no es `null`, la receta tiene pasos numerados (candidato a modo
  /// cocina). Si es `null`, usar [instructionsText] como texto libre.
  final List<String>? instructionsSteps;
  final String? instructionsText;

  final List<IngredientLine> ingredients;
  final bool isFavorited;
  final int? myRating;
  final double? averageRating;
  final int? ratingsCount;
  final int timesCooked;

  bool get hasSteps => instructionsSteps != null && instructionsSteps!.isNotEmpty;

  RecipeDetail copyWith({
    bool? isFavorited,
    int? myRating,
    double? averageRating,
    int? ratingsCount,
    int? timesCooked,
  }) =>
      RecipeDetail(
        id: id,
        slug: slug,
        title: title,
        description: description,
        imageUrl: imageUrl,
        baseServings: baseServings,
        servings: servings,
        prepTimeMinutes: prepTimeMinutes,
        cookTimeMinutes: cookTimeMinutes,
        difficulty: difficulty,
        difficultyLabel: difficultyLabel,
        categories: categories,
        tags: tags,
        sourceUrl: sourceUrl,
        sourceAuthor: sourceAuthor,
        instructionsSteps: instructionsSteps,
        instructionsText: instructionsText,
        ingredients: ingredients,
        isFavorited: isFavorited ?? this.isFavorited,
        myRating: myRating ?? this.myRating,
        averageRating: averageRating ?? this.averageRating,
        ratingsCount: ratingsCount ?? this.ratingsCount,
        timesCooked: timesCooked ?? this.timesCooked,
      );
}
