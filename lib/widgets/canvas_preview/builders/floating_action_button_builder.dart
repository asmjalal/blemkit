import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../canvas_preview_mode.dart';
import 'supabase_query_wrapper_builder.dart';

class FloatingActionButtonBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final props = node.properties;

    final bgColor = parseColor(props['backgroundColor'], context);
    final fgColor = parseColor(props['foregroundColor'], context);
    final elevation = parseDouble(props['elevation']) ?? 6.0;
    final iconName = props['icon'] as String? ?? 'Icons.add';
    final iconSizeVal = parseDouble(props['iconSize']) ?? 24.0;
    final label = props['label'] as String? ?? '';
    final shapeStr = props['shape'] as String? ?? 'circle';
    final fabSize = props['fabSize'] as String? ?? 'regular';
    final isMini = fabSize == 'mini' || fabSize == 'small';

    void handlePress() {
      if (!CanvasPreviewMode.of(context)) return;

      final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
      final rowData = SupabaseRowDataContext.of(context);
      if (rowData != null) {
        provider.activeRowData = rowData;
      }

      final navigateTo = props['navigateTo'];
      if (navigateTo != null) {
        try {
          final target = provider.screens.firstWhere((s) => s.id == navigateTo);
          provider.selectScreen(target);
        } catch (_) {}
      }
    }

    // Resolve icon
    final IconData iconData = parseIconData(iconName) as IconData? ?? Icons.add;
    final iconWidget = Icon(iconData, size: iconSizeVal, color: fgColor);

    // Resolve shape
    ShapeBorder? shape;
    switch (shapeStr) {
      case 'roundedSquare':
        shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
        break;
      case 'extended':
        shape = const StadiumBorder();
        break;
      case 'circle':
      default:
        shape = const CircleBorder();
        break;
    }

    // Extended FAB (label + icon)
    if (shapeStr == 'extended' && label.isNotEmpty) {
      return FloatingActionButton.extended(
        onPressed: handlePress,
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        elevation: elevation,
        icon: iconWidget,
        label: Text(
          label,
          style: TextStyle(color: fgColor),
        ),
        shape: shape,
      );
    }

    // Mini / Small FAB
    if (isMini) {
      return FloatingActionButton.small(
        onPressed: handlePress,
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        elevation: elevation,
        shape: shape,
        child: iconWidget,
      );
    }

    // Large FAB
    if (fabSize == 'large') {
      return FloatingActionButton.large(
        onPressed: handlePress,
        backgroundColor: bgColor,
        foregroundColor: fgColor,
        elevation: elevation,
        shape: shape,
        child: iconWidget,
      );
    }

    // Regular FAB (default)
    return FloatingActionButton(
      onPressed: handlePress,
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: elevation,
      shape: shape,
      child: iconWidget,
    );
  }
}