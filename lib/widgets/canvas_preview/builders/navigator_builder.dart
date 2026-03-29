import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';


class NavigatorBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return Navigator(
      pages: node.children.map((child) {
        return MaterialPage(
          child: WidgetBuilderFactory.buildWidget(context, child, hoveredNode),
        );
      }).toList(),
      onPopPage: (route, result) => route.didPop(result),
    );
  }


} 