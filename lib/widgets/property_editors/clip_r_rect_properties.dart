import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/widget_node.dart';
import '../../providers/widget_tree_provider.dart';

List<Widget> buildClipRRectPropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  return [
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Border Radius', 
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70)
        ),
        Slider(
          value: (node.properties['borderRadius'] as num?)?.toDouble() ?? 0.0,
          min: 0,
          max: 150,
          divisions: 150,
          label: ((node.properties['borderRadius'] as num?)?.toDouble() ?? 0.0).toStringAsFixed(1),
          onChanged: (val) {
            provider.updateNodeProperties(node, {
              ...node.properties, 
              'borderRadius': val,
            });
          },
        ),
      ],
    ),
  ];
}
