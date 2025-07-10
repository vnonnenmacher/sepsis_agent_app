import 'dart:convert';
import 'package:http/http.dart' as http;

class TagService {
  static const String _baseUrl = 'http://localhost:8000/api/agent';

  /// Fetch all tags
  Future<List<dynamic>> fetchTags({
    String? category,
    String? documentId,
    String? search,
    String? ordering,
  }) async {
    final queryParameters = <String, String>{};

    if (category != null) queryParameters['category'] = category;
    if (documentId != null) queryParameters['document_id'] = documentId;
    if (search != null) queryParameters['search'] = search;
    if (ordering != null) queryParameters['ordering'] = ordering;

    final uri = Uri.parse('$_baseUrl/tags/').replace(queryParameters: queryParameters);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List<dynamic>;
    } else {
      throw Exception('Failed to fetch tags: ${response.statusCode}');
    }
  }

  /// Update a tag condition by ID
  Future<void> updateTagCondition({
    required int id,
    required String fieldPath,
    required String operator,
    required dynamic value,
  }) async {
    final uri = Uri.parse('$_baseUrl/tag-conditions/$id/');

    final response = await http.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'field_path': fieldPath,
        'operator': operator,
        'value': value,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update tag condition: ${response.statusCode}');
    }
  }
}