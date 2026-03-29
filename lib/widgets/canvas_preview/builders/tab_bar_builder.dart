import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class TabBarBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    // TabBar requires a TickerProvider, which is typically provided by a State object
    // that mixes in SingleTickerProviderStateMixin or TickerProviderStateMixin.
    // For the canvas preview, we'll return a placeholder.
    return Container(
      color: Colors.purple.withOpacity(0.3),
      child: Center(
        child: Text('TabBar Placeholder (requires TickerProvider)'),
      ),
    );
  }
} 