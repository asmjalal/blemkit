import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class TimePickerBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final label = node.properties['label']?.toString() ?? 'Select Time';
    return AbsorbPointer(
      child: InkWell(
        onTap: () {},
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            suffixIcon: const Icon(Icons.access_time),
          ),
          child: Text(label),
        ),
      ),
    );
  }
}
