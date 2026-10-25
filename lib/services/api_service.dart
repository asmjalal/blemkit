import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/project_logic.dart';

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

/// Result of running a project API call from the editor (test tab and
/// canvas preview).
class ApiCallResult {
  final int statusCode;
  final dynamic body;
  final String rawBody;
  final String? error;
  final Duration elapsed;

  const ApiCallResult({required this.statusCode, this.body, this.rawBody = '', this.error, this.elapsed = Duration.zero});

  bool get succeeded => error == null && statusCode >= 200 && statusCode < 300;
}

class ApiCallRunner {
  /// Replaces `[name]` placeholders with [variables].
  static String fill(String template, Map<String, dynamic> variables) {
    return template.replaceAllMapped(RegExp(r'\[([a-zA-Z_][a-zA-Z0-9_]*)\]'), (m) {
      final value = variables[m.group(1)];
      return value == null ? m.group(0)! : value.toString();
    });
  }

  static Future<ApiCallResult> run(ApiCallDef call, Map<String, dynamic> variables) async {
    final watch = Stopwatch()..start();
    try {
      final uri = Uri.parse(fill(call.url, variables));
      final headers = call.headers.map((k, v) => MapEntry(k, fill(v, variables)));
      String? body;
      if (call.bodyType == 'json') {
        headers.putIfAbsent('Content-Type', () => 'application/json');
        body = fill(call.body, variables);
      } else if (call.bodyType == 'form') {
        headers.putIfAbsent('Content-Type', () => 'application/x-www-form-urlencoded');
        body = fill(call.body, variables);
      }
      final request = http.Request(call.method.toUpperCase(), uri)..headers.addAll(headers);
      if (body != null && call.method.toUpperCase() != 'GET') request.body = body;
      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);
      dynamic decoded;
      try {
        decoded = json.decode(response.body);
      } catch (_) {
        decoded = response.body;
      }
      return ApiCallResult(statusCode: response.statusCode, body: decoded, rawBody: response.body, elapsed: watch.elapsed);
    } catch (e) {
      return ApiCallResult(statusCode: 0, error: e.toString(), elapsed: watch.elapsed);
    }
  }
}
