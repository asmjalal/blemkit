import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class ToggleButtonsBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return ToggleButtons(
      isSelected: const [true, false, false],
      onPressed: (index) {},
      children: const [
        Icon(Icons.format_bold),
        Icon(Icons.format_italic),
        Icon(Icons.format_underlined),
      ],
    );
  }
}
