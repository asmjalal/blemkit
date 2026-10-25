/// Minimal JSON path reader for API responses: `$`, `$.a.b`, `$.items[0].name`,
/// `$.items[*].name` (collects a list). The same logic is emitted into
/// exported projects as `getJsonField` (see `logic_codegen.dart`).
class JsonPath {
  static dynamic read(dynamic data, String path) {
    var p = path.trim();
    if (p.isEmpty || p == r'$') return data;
    if (p.startsWith(r'$')) p = p.substring(1);
    if (p.startsWith('.')) p = p.substring(1);

    final tokens = <String>[];
    for (final part in p.split('.')) {
      final match = RegExp(r'^([^\[]*)((?:\[[^\]]+\])*)$').firstMatch(part);
      if (match == null) return null;
      if (match.group(1)!.isNotEmpty) tokens.add(match.group(1)!);
      for (final idx in RegExp(r'\[([^\]]+)\]').allMatches(match.group(2)!)) {
        tokens.add('[${idx.group(1)}]');
      }
    }
    return _walk(data, tokens);
  }

  static dynamic _walk(dynamic node, List<String> tokens) {
    if (tokens.isEmpty) return node;
    final token = tokens.first;
    final rest = tokens.sublist(1);
    if (token == '[*]') {
      if (node is! List) return null;
      return node.map((item) => _walk(item, rest)).toList();
    }
    if (token.startsWith('[')) {
      final index = int.tryParse(token.substring(1, token.length - 1));
      if (node is! List || index == null || index < 0 || index >= node.length) return null;
      return _walk(node[index], rest);
    }
    if (node is Map) return _walk(node[token], rest);
    return null;
  }
}
