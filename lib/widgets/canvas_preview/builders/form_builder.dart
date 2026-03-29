import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class FormBuilder extends BaseWidgetBuilder {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return Form(
      key: _formKey,
      child: Column(
        children: node.children.map((child) => WidgetBuilderFactory.buildWidget(context, child, hoveredNode)).toList(),
      ),
    );
  }


} 