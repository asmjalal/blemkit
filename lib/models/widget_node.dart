import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'widget_node.g.dart';

@JsonSerializable()
class WidgetNode {
  final String id;
  final String type;
  final List<WidgetNode> children;
  Map<String, dynamic> properties;

  WidgetNode({
    String? id,
    required this.type,
    List<WidgetNode>? children,
    Map<String, dynamic>? properties,
  })  : id = id ?? UniqueKey().toString(),
        children = children ?? [],
        properties = properties ?? {};

  factory WidgetNode.fromJson(Map<String, dynamic> json) =>
      _$WidgetNodeFromJson(json);

  Map<String, dynamic> toJson() => _$WidgetNodeToJson(this);

  WidgetNode copy() {
    return WidgetNode(
      type: type,
      children: children.map((child) => child.copy()).toList(),
      properties: Map<String, dynamic>.from(properties),
    );
  }
} 