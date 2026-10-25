import 'package:designflutterkit/widgets/canvas_preview/builders/supabase_query_wrapper_builder.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../canvas_preview_mode.dart';

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

    // Resolve leading
    final leadingIconStr = node.properties['leadingIcon'];
    Color? leadingColor = parseColor(node.properties['leadingIconColor'], context);
    Widget? finalLeading;
    
    if (leadingIconStr != null && leadingIconStr.toString().trim().isNotEmpty) {
      String iconName = leadingIconStr.toString().trim();
      if (!iconName.startsWith('Icons.') && !iconName.startsWith('FontAwesomeIcons.')) {
        iconName = 'Icons.$iconName';
      }
      final iconData = parseIconData(iconName);
      if (iconName.startsWith('FontAwesomeIcons.')) {
         finalLeading = FaIcon(iconData, color: leadingColor);
      } else {
         finalLeading = Icon(iconData as IconData?, color: leadingColor);
      }
    } else {
       finalLeading = _resolveSlot(context, node.properties['leading'], hoveredNode);
    }

    // Resolve trailing
    final trailingIconStr = node.properties['trailingIcon'];
    Color? trailingColor = parseColor(node.properties['trailingIconColor'], context);
    Widget? finalTrailing;
    
    if (trailingIconStr != null && trailingIconStr.toString().trim().isNotEmpty) {
      String iconName = trailingIconStr.toString().trim();
      if (!iconName.startsWith('Icons.') && !iconName.startsWith('FontAwesomeIcons.')) {
        iconName = 'Icons.$iconName';
      }
      final iconData = parseIconData(iconName);
      Widget iconWidget;
      if (iconName.startsWith('FontAwesomeIcons.')) {
         iconWidget = FaIcon(iconData, color: trailingColor);
      } else {
         iconWidget = Icon(iconData as IconData?, color: trailingColor);
      }

      final trailingNavigateTo = node.properties['trailingNavigateTo'];
      if (trailingNavigateTo != null) {
        finalTrailing = IconButton(
          icon: iconWidget,
          onPressed: () {
            if (!CanvasPreviewMode.of(context)) return;
            final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
            final rowData = SupabaseRowDataContext.of(context);
            if (rowData != null) {
              provider.activeRowData = rowData;
            }
            try {
              final target = provider.screens.firstWhere((s) => s.id == trailingNavigateTo);
              provider.selectScreen(target);
            } catch (_) {}
          },
        );
      } else {
        finalTrailing = iconWidget;
      }
    } else {
       finalTrailing = _resolveSlot(context, node.properties['trailing'], hoveredNode);
    }

    return ListTile(
      leading: finalLeading,
      title: titleWidget,
      subtitle: subtitleWidget,
      trailing: finalTrailing,
      onTap: () {
        if (!CanvasPreviewMode.of(context)) return;
        
        final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
        final rowData = SupabaseRowDataContext.of(context);
        if (rowData != null) {
          provider.activeRowData = rowData;
        }

        runTapActions(context, node);
      },
      selected: node.properties['selected'] ?? false,
      tileColor: parseColor(node.properties['tileColor'], context),
    );
  }
}
 