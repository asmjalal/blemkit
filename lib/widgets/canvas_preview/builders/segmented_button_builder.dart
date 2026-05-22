import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class SegmentedButtonBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return SegmentedButton<int>(
      segments: const [
        ButtonSegment<int>(value: 0, label: Text('Day'), icon: Icon(Icons.calendar_view_day)),
        ButtonSegment<int>(value: 1, label: Text('Week'), icon: Icon(Icons.calendar_view_week)),
        ButtonSegment<int>(value: 2, label: Text('Month'), icon: Icon(Icons.calendar_view_month)),
      ],
      selected: const {0},
      onSelectionChanged: (Set<int> newSelection) {},
    );
  }
}
