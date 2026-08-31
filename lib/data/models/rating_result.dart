/// Respuesta de `POST /api/recipes/{slug}/rate`.
class RatingResult {
  const RatingResult({
    required this.myRating,
    required this.averageRating,
    required this.ratingsCount,
  });

  factory RatingResult.fromJson(Map<String, dynamic> json) => RatingResult(
        myRating: json['my_rating'] as int,
        averageRating: (json['average_rating'] as num).toDouble(),
        ratingsCount: json['ratings_count'] as int,
      );

  final int myRating;
  final double averageRating;
  final int ratingsCount;
}
