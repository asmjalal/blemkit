import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../canvas_preview_mode.dart';
import 'supabase_query_wrapper_builder.dart';


class ElevatedButtonBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final props = node.properties;

    final fillColor = parseColor(props['fillColor'], context) ?? 
                      parseColor(props['backgroundColor'], context);
    final foregroundColor = parseColor(props['foregroundColor'], context);
    final borderRadius = parseDouble(props['borderRadius']) ?? 4.0;
    final borderColor = parseColor(props['borderColor'], context);
    final borderWidth = parseDouble(props['borderWidth']) ?? 0.0;
    final elevation = parseDouble(props['buttonElevation']) ?? 2.0;
    final padding = parseEdgeInsets(props['padding']);
    final fontSize = parseDouble(props['fontSize']) ?? 16.0;
    final fontWeight = parseFontWeight(props['fontWeight']);

    Widget child;
    if (node.children.isNotEmpty) {
      child = WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode);
    } else {
      final text = safeString(props['text'], fallback: 'Button');
      child = Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight,
        ),
      );
    }

    Widget button = ElevatedButton(
      onPressed: () {
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
          } catch (_) {
            // Screen might have been deleted
          }
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: fillColor,
        foregroundColor: foregroundColor,
        elevation: elevation,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          side: borderWidth > 0 && borderColor != null
              ? BorderSide(color: borderColor, width: borderWidth)
              : BorderSide.none,
        ),
      ),
      child: child,
    );

    final width = parseDouble(props['width']);
    final height = parseDouble(props['height']);
    if (width != null || height != null) {
      button = SizedBox(
        width: width,
        height: height,
        child: button,
      );
    }

    return button;
  }
} 