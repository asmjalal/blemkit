import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<dynamic> fetchData({
    required String url,
    String? apiKey,
    Map<String, String>? headers,
  }) async {
    try {
      final finalHeaders = {
        'Content-Type': 'application/json',
        if (apiKey != null) 'apikey': apiKey,
        if (apiKey != null) 'Authorization': 'Bearer $apiKey',
        ...?headers,
      };

      final response = await http.get(Uri.parse(url), headers: finalHeaders);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    } catch (e) {
      print('Api Service Error: $e');
      rethrow;
    }
  }

  // Helper for Supabase specifically
  static String buildSupabaseUrl(String projectUrl, String table) {
    return '$projectUrl/rest/v1/$table?select=*';
  }
}
