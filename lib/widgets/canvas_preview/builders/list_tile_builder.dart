import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';

class ListTileBuilder extends BaseWidgetBuilder {
  /// Resolves a leading/trailing property that can be either:
  ///   - A Map<String, dynamic>  → full WidgetNode (new format)
  ///   - A String like "Icons.home" → plain icon name (legacy format)
  Widget? _resolveSlot(BuildContext context, dynamic value, WidgetNode? hoveredNode) {
    if (value == null) return null;
    if (value is WidgetNode || value is Map<String, dynamic>) {
      return safeWidget(context, value, hoveredNode);
    }
    if (value is String) {
      // Legacy: treat as an icon name string — dispatch based on prefix
      final iconData = parseIconData(value);
      if (value.startsWith('FontAwesomeIcons.')) {
        return FaIcon(iconData);
      }
      return Icon(iconData as IconData? ?? Icons.widgets);
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    // title & subtitle can be either a plain String or a nested widget Map
    Widget? titleWidget = safeWidget(
      context,
      node.properties['title'],
      hoveredNode,
      fallback: null,
    );
    Widget? subtitleWidget = safeWidget(
      context,
      node.properties['subtitle'],
      hoveredNode,
      fallback: null,
    );

    return ListTile(
      leading: _resolveSlot(context, node.properties['leading'], hoveredNode),
      title: titleWidget,
      subtitle: subtitleWidget,
      trailing: _resolveSlot(context, node.properties['trailing'], hoveredNode),
      onTap: () {
        final navigateTo = node.properties['navigateTo'];
        if (navigateTo != null) {
          final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
          try {
            final target = provider.screens.firstWhere((s) => s.id == navigateTo);
            provider.selectScreen(target);
          } catch (_) {
            // Screen might have been deleted
          }
        }
      },
      selected: node.properties['selected'] ?? false,
      tileColor: parseColor(node.properties['tileColor'], context),
    );
  }
}
 