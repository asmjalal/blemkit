// Helpers shared by SynappKit-generated code. This file is copied verbatim
// into every exported project as lib/synapp/synapp_utils.dart, so it may only
// depend on the Flutter SDK.

/// Equality that treats `1`, `1.0` and `'1'` as equal.
bool looseEquals(dynamic a, dynamic b) {
  if (a is num && b is num) return a.toDouble() == b.toDouble();
  if (a is num || b is num) {
    final an = num.tryParse('$a');
    final bn = num.tryParse('$b');
    if (an != null && bn != null) return an.toDouble() == bn.toDouble();
  }
  return '${a ?? ''}' == '${b ?? ''}';
}

num castToNum(dynamic value) {
  if (value is num) return value;
  return num.tryParse('${value ?? ''}') ?? 0;
}

int castToInt(dynamic value) => castToNum(value).toInt();

double castToDouble(dynamic value) => castToNum(value).toDouble();

bool valueIsTruthy(dynamic value) => value == true || '$value' == 'true';

bool valueIsEmpty(dynamic value) {
  if (value == null) return true;
  if (value is String) return value.isEmpty;
  if (value is Iterable) return value.isEmpty;
  if (value is Map) return value.isEmpty;
  return false;
}

bool valueContains(dynamic container, dynamic item) {
  if (container is Iterable) return container.any((e) => looseEquals(e, item));
  return '${container ?? ''}'.contains('${item ?? ''}');
}

String valueToString(dynamic value) {
  if (value == null) return '';
  if (value is Iterable) return value.join(', ');
  return '$value';
}

/// Reads `$.a.b[0].c` (or `$.items[*].name` for a list) from decoded JSON.
dynamic getJsonField(dynamic data, String path) {
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
  return _walkJson(data, tokens);
}

dynamic _walkJson(dynamic node, List<String> tokens) {
  if (tokens.isEmpty) return node;
  final token = tokens.first;
  final rest = tokens.sublist(1);
  if (token == '[*]') {
    if (node is! List) return null;
    return node.map((item) => _walkJson(item, rest)).toList();
  }
  if (token.startsWith('[')) {
    final index = int.tryParse(token.substring(1, token.length - 1));
    if (node is! List || index == null || index < 0 || index >= node.length) return null;
    return _walkJson(node[index], rest);
  }
  if (node is Map) return _walkJson(node[token], rest);
  return null;
}

/// Turns a JSON value into a list of maps for list widgets.
List<Map<String, dynamic>> jsonRows(dynamic value) {
  if (value is List) {
    return value.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{'value': e}).toList();
  }
  if (value is Map) return [Map<String, dynamic>.from(value)];
  return const [];
}

/// Replaces `[name]` placeholders in API URLs, headers and bodies.
String fillTemplate(String template, Map<String, dynamic> variables) {
  return template.replaceAllMapped(RegExp(r'\[([a-zA-Z_][a-zA-Z0-9_]*)\]'), (m) {
    final value = variables[m.group(1)];
    return value == null ? m.group(0)! : '$value';
  });
}
