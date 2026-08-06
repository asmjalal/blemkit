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
        if (childJson is Map) {
          children.add(WidgetNode.fromJson(Map<String, dynamic>.from(childJson)));
        }
      }
    }
    
    final Map<String, dynamic> properties = {};
    if (json['properties'] != null && json['properties'] is Map) {
      final rawProps = Map<String, dynamic>.from(json['properties'] as Map);
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
    if (value is Map) {
      if (value.containsKey('type') && value.containsKey('children')) {
        return WidgetNode.fromJson(Map<String, dynamic>.from(value));
      }
      // It's a map but not a widget (e.g. style config)
      return value.map((k, v) => MapEntry(k.toString(), _normalizeProperty(v)));
    } else if (value is List) {
      return value.map((item) => _normalizeProperty(item)).toList();
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

  Map<String, dynamic>? get backendQuery {
    if (properties['backendQuery'] == null) return null;
    return Map<String, dynamic>.from(properties['backendQuery'] as Map);
  }

  set backendQuery(Map<String, dynamic>? value) {
    if (value == null) {
      properties.remove('backendQuery');
    } else {
      properties['backendQuery'] = value;
    }
  }

  Map<String, dynamic>? get dataBinding {
    if (properties['dataBinding'] == null) return null;
    return Map<String, dynamic>.from(properties['dataBinding'] as Map);
  }

  set dataBinding(Map<String, dynamic>? value) {
    if (value == null) {
      properties.remove('dataBinding');
    } else {
      properties['dataBinding'] = value;
    }
  }
}