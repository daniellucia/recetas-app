/// Respuesta 200 de `POST /api/recipes/import`. Los fallos (422) llegan
/// como [ApiException] con el mensaje ya traducido por el servidor.
class ImportResult {
  const ImportResult({
    required this.imported,
    required this.skipped,
    required this.message,
  });

  factory ImportResult.fromJson(Map<String, dynamic> json) => ImportResult(
        imported: (json['imported'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        skipped: (json['skipped'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toList(),
        message: json['message'] as String?,
      );

  final List<String> imported;
  final List<String> skipped;
  final String? message;
}
