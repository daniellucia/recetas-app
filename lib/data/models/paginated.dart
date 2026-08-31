/// Envuelve la paginación estándar de Laravel (`data`/`links`/`meta`).
class Paginated<T> {
  const Paginated({
    required this.data,
    required this.currentPage,
    required this.lastPage,
  });

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final meta = json['meta'] as Map<String, dynamic>?;
    return Paginated(
      data: (json['data'] as List<dynamic>)
          .map((e) => fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: meta?['current_page'] as int? ?? 1,
      lastPage: meta?['last_page'] as int? ?? 1,
    );
  }

  final List<T> data;
  final int currentPage;
  final int lastPage;

  bool get hasNextPage => currentPage < lastPage;
}
