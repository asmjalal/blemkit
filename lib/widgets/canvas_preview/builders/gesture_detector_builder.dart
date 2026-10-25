import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../canvas_preview_mode.dart';
import 'supabase_query_wrapper_builder.dart';


class GestureDetectorBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return GestureDetector(
      onTap: () {
        if (!CanvasPreviewMode.of(context)) return;
        
        final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
        final rowData = SupabaseRowDataContext.of(context);
        if (rowData != null) {
          provider.activeRowData = rowData;
        }

        runTapActions(context, node);
      },
      onDoubleTap: () {},
      onLongPress: () {},
      child: node.children.isNotEmpty ? WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode) : const SizedBox(),
    );
  }


} 