import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class WrapBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return Wrap(
      direction: parseAxis(node.properties['direction']) ?? Axis.horizontal,
      alignment: parseWrapAlignment(node.properties['alignment']) ?? WrapAlignment.start,
      spacing: (node.properties['spacing'] as num?)?.toDouble() ?? 0.0,
      runAlignment: parseWrapAlignment(node.properties['runAlignment']) ?? WrapAlignment.start,
      runSpacing: (node.properties['runSpacing'] as num?)?.toDouble() ?? 0.0,
      crossAxisAlignment: parseWrapCrossAxisAlignment(node.properties['crossAxisAlignment']) ?? WrapCrossAlignment.start,
      children: node.children.map((child) => WidgetBuilderFactory.buildWidget(context, child, hoveredNode)).toList(),
    );
  }



  WrapAlignment? parseWrapAlignment(dynamic value) {
    switch (value) {
      case 'start':
        return WrapAlignment.start;
      case 'end':
        return WrapAlignment.end;
      case 'center':
        return WrapAlignment.center;
      case 'spaceBetween':
        return WrapAlignment.spaceBetween;
      case 'spaceAround':
        return WrapAlignment.spaceAround;
      case 'spaceEvenly':
        return WrapAlignment.spaceEvenly;
      default:
        return null;
    }
  }

  WrapCrossAlignment? parseWrapCrossAxisAlignment(dynamic value) {
    switch (value) {
      case 'start':
        return WrapCrossAlignment.start;
      case 'end':
        return WrapCrossAlignment.end;
      case 'center':
        return WrapCrossAlignment.center;
      default:
        return null;
    }
  }
} 