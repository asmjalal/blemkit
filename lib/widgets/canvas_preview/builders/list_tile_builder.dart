import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';

class ListTileBuilder extends BaseWidgetBuilder {
  /// Resolves a leading/trailing property that can be either:
  ///   - A Map<String, dynamic>  → full WidgetNode (new format)
  ///   - A String like "Icons.home" → plain icon name (legacy format)
  Widget? _resolveSlot(BuildContext context, dynamic value, WidgetNode? hoveredNode) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) {
      return WidgetBuilderFactory.buildWidget(
        context, WidgetNode.fromJson(value), hoveredNode);
    }
    if (value is String) {
      // Legacy: treat as an icon name string
      return Icon(parseIconData(value));
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return ListTile(
      leading: _resolveSlot(context, node.properties['leading'], hoveredNode),
      title: node.properties['title'] != null
          ? Text(node.properties['title'])
          : null,
      subtitle: node.properties['subtitle'] != null
          ? Text(node.properties['subtitle'])
          : null,
      trailing: _resolveSlot(context, node.properties['trailing'], hoveredNode),
      onTap: () {},
      selected: node.properties['selected'] ?? false,
      tileColor: parseColor(node.properties['tileColor']),
    );
  }
}
 