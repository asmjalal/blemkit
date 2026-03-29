import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class MaterialPageRouteBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    // MaterialPageRoute is typically used within a Navigator and doesn't render directly.
    // This builder is a placeholder for completeness.
    return Container(
      color: Colors.blue.withOpacity(0.3),
      child: Center(
        child: Text('MaterialPageRoute Placeholder'),
      ),
    );
  }
} 