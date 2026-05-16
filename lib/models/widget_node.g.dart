// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget_node.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WidgetNode _$WidgetNodeFromJson(Map<String, dynamic> json) => WidgetNode(
  id: json['id'] as String?,
  type: json['type'] as String,
  children:
      (json['children'] as List<dynamic>?)
          ?.map((e) => WidgetNode.fromJson(e as Map<String, dynamic>))
          .toList(),
  properties: json['properties'] as Map<String, dynamic>?,
);

Map<String, dynamic> _$WidgetNodeToJson(WidgetNode instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'children': instance.children,
      'properties': instance.properties,
    };
