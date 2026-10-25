import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../logic/json_path.dart';
import '../../../models/widget_node.dart';
import '../../../providers/widget_tree_provider.dart';
import '../../../runtime/preview_runtime.dart';
import '../../../services/api_service.dart';

/// Fetches a project API call for a widget bound with `apiQuery` and hands
/// the rows at `listPath` to [builder]. Results are cached per configuration
/// so the canvas does not refetch on every rebuild.
class ApiQueryWrapper extends StatefulWidget {
  final WidgetNode node;
  final Widget Function(BuildContext context, List<Map<String, dynamic>> rows) builder;

  const ApiQueryWrapper({super.key, required this.node, required this.builder});

  static final Map<String, Future<List<Map<String, dynamic>>>> _cache = {};

  static void clearCache() => _cache.clear();

  @override
  State<ApiQueryWrapper> createState() => _ApiQueryWrapperState();
}

class _ApiQueryWrapperState extends State<ApiQueryWrapper> {
  Future<List<Map<String, dynamic>>> _load(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    final query = Map<String, dynamic>.from(widget.node.properties['apiQuery'] as Map);
    final call = provider.logic.apiCallById(query['apiCallId'] as String?);
    if (call == null) return Future.value(const []);
    final variables = <String, dynamic>{};
    for (final v in call.variables) {
      variables[v.name] = PreviewRuntime.resolve(context, (query['variables'] as Map?)?[v.name]) ?? v.defaultValue;
    }
    final key = jsonEncode({'call': call.toJson(), 'vars': variables, 'path': query['listPath']});
    return ApiQueryWrapper._cache.putIfAbsent(key, () async {
      final result = await ApiCallRunner.run(call, variables);
      final data = JsonPath.read(result.body, query['listPath'] as String? ?? r'$');
      if (data is List) return data.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{'value': e}).toList();
      if (data is Map) return [Map<String, dynamic>.from(data)];
      return const <Map<String, dynamic>>[];
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _load(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
        }
        return widget.builder(context, snapshot.data ?? const []);
      },
    );
  }
}
