import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class TabBarViewBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    // TabBarView also requires a TickerProvider, similar to TabBar.
    // We'll return a placeholder here.
    return Container(
      color: Colors.orange.withOpacity(0.3),
      child: Center(
        child: Text('TabBarView Placeholder (requires TickerProvider)'),
      ),
    );
  }
} 