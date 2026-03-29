import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';

class FormFieldBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: node.properties['labelText'] as String?,
        hintText: node.properties['hintText'] as String?,
        border: OutlineInputBorder(),
      ),
      initialValue: node.properties['initialValue'] as String?,
      keyboardType: parseTextInputType(node.properties['keyboardType']),
    );
  }

  TextInputType? parseTextInputType(dynamic value) {
    switch (value) {
      case 'text':
        return TextInputType.text;
      case 'multiline':
        return TextInputType.multiline;
      case 'number':
        return TextInputType.number;
      case 'phone':
        return TextInputType.phone;
      case 'datetime':
        return TextInputType.datetime;
      case 'emailAddress':
        return TextInputType.emailAddress;
      case 'url':
        return TextInputType.url;
      case 'visiblePassword':
        return TextInputType.visiblePassword;
      default:
        return null;
    }
  }
} 