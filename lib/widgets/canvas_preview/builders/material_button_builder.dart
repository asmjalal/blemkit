import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../canvas_preview_mode.dart';
import 'supabase_query_wrapper_builder.dart';


class MaterialButtonBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final color = parseColor(node.properties['color'], context);
    final textColor = parseColor(node.properties['textColor'], context);
    final disabledColor = parseColor(node.properties['disabledColor'], context);
    final splashColor = parseColor(node.properties['splashColor'], context);
    final highlightColor = parseColor(node.properties['highlightColor'], context);
    final padding = parseEdgeInsets(node.properties['padding']);

    final elevationRaw = node.properties['elevation'];
    final double? elevation = elevationRaw != null
        ? double.tryParse(elevationRaw.toString())
        : null;

    final minWidthRaw = node.properties['minWidth'];
    final double? minWidth = minWidthRaw != null
        ? double.tryParse(minWidthRaw.toString())
        : null;

    final heightRaw = node.properties['height'];
    final double? height = heightRaw != null
        ? double.tryParse(heightRaw.toString())
        : null;

    // Shape / border radius
    final borderRadiusRaw = node.properties['borderRadius'];
    final double? borderRadius = borderRadiusRaw != null
        ? double.tryParse(borderRadiusRaw.toString())
        : null;

    ShapeBorder? shape;
    if (borderRadius != null) {
      shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      );
    }

    return MaterialButton(
      onPressed: () {
        if (!CanvasPreviewMode.of(context)) return;
        
        final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
        final rowData = SupabaseRowDataContext.of(context);
        if (rowData != null) {
          provider.activeRowData = rowData;
        }

        final navigateTo = node.properties['navigateTo'];
        if (navigateTo != null) {
          try {
            final target = provider.screens.firstWhere((s) => s.id == navigateTo);
            provider.selectScreen(target);
          } catch (_) {
            // Screen might have been deleted
          }
        }
      },
      color: color,
      textColor: textColor,
      disabledColor: disabledColor,
      splashColor: splashColor,
      highlightColor: highlightColor,
      padding: padding,
      elevation: elevation,
      minWidth: minWidth,
      height: height,
      shape: shape,
      child: node.children.isNotEmpty
          ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode)
          : Text(safeString(node.properties['text'], fallback: 'Material Button')),
    );
  }
}
