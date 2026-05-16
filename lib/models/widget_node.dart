import 'package:flutter/cupertino.dart';
import 'package:json_annotation/json_annotation.dart';

part 'widget_node.g.dart';

@JsonSerializable()
class WidgetNode {
  String id;
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

  factory WidgetNode.fromJson(Map<String, dynamic> json) {
    // Manually handle the mapping to ensure nested widgets in properties 
    // are converted to WidgetNode objects, not left as raw Maps.
    final String id = json['id'] ?? UniqueKey().toString();
    final String type = json['type'] ?? 'Unknown';
    
    final List<WidgetNode> children = [];
    if (json['children'] != null) {
      for (var childJson in json['children']) {
        children.add(WidgetNode.fromJson(childJson as Map<String, dynamic>));
      }
    }
    
    final Map<String, dynamic> properties = {};
    if (json['properties'] != null) {
      final rawProps = json['properties'] as Map<String, dynamic>;
      rawProps.forEach((key, value) {
        properties[key] = _normalizeProperty(value);
      });
    }
    
    return WidgetNode(
      id: id,
      type: type,
      children: children,
      properties: properties,
    );
  }

  static dynamic _normalizeProperty(dynamic value) {
    if (value is Map<String, dynamic> && value.containsKey('type')) {
      return WidgetNode.fromJson(value);
    } else if (value is List) {
      return value.map((item) => _normalizeProperty(item)).toList();
    } else if (value is Map<String, dynamic>) {
      // It's a map but not a widget (e.g. style config)
      return value.map((k, v) => MapEntry(k, _normalizeProperty(v)));
    }
    return value;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'children': children.map((c) => c.toJson()).toList(),
      'properties': properties.map((k, v) => MapEntry(k, _toJsonValue(v))),
    };
  }

  static dynamic _toJsonValue(dynamic value) {
    if (value is WidgetNode) {
      return value.toJson();
    } else if (value is List) {
      return value.map((i) => _toJsonValue(i)).toList();
    } else if (value is Map<String, dynamic>) {
      return value.map((k, v) => MapEntry(k, _toJsonValue(v)));
    }
    return value;
  }

  WidgetNode copy() {
    return WidgetNode.fromJson(toJson());
  }
}