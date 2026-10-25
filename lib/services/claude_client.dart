import 'dart:convert';

import 'package:http/http.dart' as http;

/// Calls the Claude Messages API over raw HTTP (Dart has no official
/// Anthropic SDK). Used by the AI builder with the user's own API key.
class ClaudeClient {
  static const String endpoint = 'https://api.anthropic.com/v1/messages';
  static const String model = 'claude-opus-5-5';

  /// The request body, shared by the direct call and the AI proxy.
  static Map<String, dynamic> buildBody({
    required String system,
    required List<Map<String, String>> history,
    required String prompt,
    String? imageBase64,
    String? imageMediaType,
  }) {
    final messages = <Map<String, dynamic>>[
      for (final m in history)
        if ((m['content'] ?? '').isNotEmpty) {'role': m['role'] == 'user' ? 'user' : 'assistant', 'content': m['content']},
    ];
    // The conversation must start with a user turn.
    while (messages.isNotEmpty && messages.first['role'] != 'user') {
      messages.removeAt(0);
    }
    messages.add({
      'role': 'user',
      'content': [
        if (imageBase64 != null)
          {
            'type': 'image',
            'source': {'type': 'base64', 'media_type': imageMediaType ?? 'image/png', 'data': imageBase64},
          },
        {'type': 'text', 'text': prompt},
      ],
    });
    return {
      'model': model,
      'max_tokens': 16000,
      'system': system,
      'messages': messages,
      // Thinking is always on for this model; effort sets its depth.
      'output_config': {'effort': 'medium'},
      // Re-run on Anthropic's recommended model if a safety classifier declines.
      'fallbacks': 'default',
    };
  }

  static Map<String, String> headers(String apiKey) => {
        'content-type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2026-10-21',
        'anthropic-beta': 'server-side-fallback-2026-07-01',
        // Required for calls made directly from the browser with the user's key.
        'anthropic-dangerous-direct-browser-access': 'true',
      };

  /// Returns the concatenated text of the response.
  static Future<String> complete({required String apiKey, required Map<String, dynamic> body}) async {
    final response = await http.post(Uri.parse(endpoint), headers: headers(apiKey), body: jsonEncode(body));
    return parseResponse(response.statusCode, response.body);
  }

  static String parseResponse(int statusCode, String responseBody) {
    final decoded = jsonDecode(responseBody) as Map<String, dynamic>;
    if (statusCode != 200) {
      final error = decoded['error'] as Map?;
      final type = error?['type'] ?? 'error';
      if (statusCode == 401) throw Exception('Claude rejected the API key (401). Check the key in the AI panel.');
      if (statusCode == 429) throw Exception('Claude rate limit reached (429). Wait a moment and try again.');
      throw Exception('Claude request failed ($statusCode $type): ${error?['message'] ?? responseBody}');
    }
    final stopReason = decoded['stop_reason'];
    if (stopReason == 'refusal') {
      final details = decoded['stop_details'] as Map?;
      throw Exception('Claude declined this request${details?['explanation'] != null ? ': ${details!['explanation']}' : '.'}');
    }
    final text = (decoded['content'] as List? ?? const [])
        .whereType<Map>()
        .where((block) => block['type'] == 'text')
        .map((block) => block['text'] as String? ?? '')
        .join();
    if (stopReason == 'max_tokens' && text.isEmpty) {
      throw Exception('Claude ran out of output tokens before answering. Try a smaller request.');
    }
    return text;
  }
}
