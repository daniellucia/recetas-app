/// Un elemento de `GET /api/recipes` (lista/búsqueda).
class RecipeSummary {
  const RecipeSummary({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.baseServings,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.difficulty,
    required this.difficultyLabel,
    required this.categories,
    required this.tags,
    required this.averageRating,
    required this.ratingsCount,
    required this.isFavorited,
  });

  factory RecipeSummary.fromJson(Map<String, dynamic> json) => RecipeSummary(
        id: json['id'] as int,
        slug: json['slug'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        imageUrl: json['image_url'] as String?,
        baseServings: json['base_servings'] as int,
        prepTimeMinutes: json['prep_time_minutes'] as int?,
        cookTimeMinutes: json['cook_time_minutes'] as int?,
        difficulty: json['difficulty'] as String?,
        difficultyLabel: json['difficulty_label'] as String?,
        categories: (json['categories'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        tags: (json['tags'] as List<dynamic>? ?? [])
            .map((e) => e as String)
            .toList(),
        averageRating: (json['average_rating'] as num?)?.toDouble(),
        ratingsCount: json['ratings_count'] as int?,
        isFavorited: json['is_favorited'] as bool? ?? false,
      );

  final int id;
  final String slug;
  final String title;
  final String? description;
  final String? imageUrl;
  final int baseServings;
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final String? difficulty;
  final String? difficultyLabel;
  final List<String> categories;
  final List<String> tags;
  final double? averageRating;
  final int? ratingsCount;
  final bool isFavorited;

  RecipeSummary copyWith({bool? isFavorited}) => RecipeSummary(
        id: id,
        slug: slug,
        title: title,
        description: description,
        imageUrl: imageUrl,
        baseServings: baseServings,
        prepTimeMinutes: prepTimeMinutes,
        cookTimeMinutes: cookTimeMinutes,
        difficulty: difficulty,
        difficultyLabel: difficultyLabel,
        categories: categories,
        tags: tags,
        averageRating: averageRating,
        ratingsCount: ratingsCount,
        isFavorited: isFavorited ?? this.isFavorited,
      );
}
