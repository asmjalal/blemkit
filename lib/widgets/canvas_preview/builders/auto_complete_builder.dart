import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class AutoCompleteBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final hintText = node.properties['hintText']?.toString() ?? 'Type to search...';
    
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        suffixIcon: const Icon(Icons.arrow_drop_down),
        border: const OutlineInputBorder(),
      ),
      readOnly: true,
    );
  }
}
