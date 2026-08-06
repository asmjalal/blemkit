import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../canvas_preview_mode.dart';
import 'supabase_query_wrapper_builder.dart';


class OutlinedButtonBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return OutlinedButton(
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
      style: OutlinedButton.styleFrom(
        foregroundColor: parseColor(node.properties['foregroundColor'], context),
        padding: parseEdgeInsets(node.properties['padding']),
      ),
      child: node.children.isNotEmpty ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode) : const SizedBox(),
    );
  }


} 