import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';

class ScaffoldBuilder extends BaseWidgetBuilder {
  final WidgetBuilderFactory _widgetBuilderFactory;

  ScaffoldBuilder(this._widgetBuilderFactory);

  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    Widget? appBarWidget;
    Widget? bodyWidget;
    Widget? floatingActionButtonWidget;
    Widget? drawerWidget;
    Widget? endDrawerWidget;
    Widget? bottomNavigationBarWidget;

    // Handle AppBar from properties
    if (node.properties['appBar'] is WidgetNode) {
      final appBarNode = node.properties['appBar'] as WidgetNode;
      final bool isVisible = appBarNode.properties['conditionalVisibility'] != true;
      if (isVisible) {
        appBarWidget = WidgetBuilderFactory.buildWidget(context, appBarNode, hoveredNode);
      }
    }

    // Handle FloatingActionButton from properties
    final dynamic fabProperty = node.properties['floatingActionButton'];
    if (fabProperty is WidgetNode) {
      floatingActionButtonWidget = WidgetBuilderFactory.buildWidget(context, fabProperty, hoveredNode);
    }

    // Handle Drawer from properties
    if (node.properties['drawer'] is WidgetNode) {
      drawerWidget = WidgetBuilderFactory.buildWidget(context, node.properties['drawer'] as WidgetNode, hoveredNode);
    }

    // Handle EndDrawer from properties
    if (node.properties['endDrawer'] is WidgetNode) {
      endDrawerWidget = WidgetBuilderFactory.buildWidget(context, node.properties['endDrawer'] as WidgetNode, hoveredNode);
    }

    // Handle BottomNavigationBar from properties
    if (node.properties['bottomNavigationBar'] is WidgetNode) {
      bottomNavigationBarWidget = WidgetBuilderFactory.buildWidget(context, node.properties['bottomNavigationBar'] as WidgetNode, hoveredNode);
    }

    // Remaining children are assumed to be part of the body
    // Rescue any BottomNavigationBar or AppBar that AI mistakenly put in children
    List<Widget> bodyChildren = [];
    for (var child in node.children) {
      if ((child.type == 'BottomNavigationBar') && bottomNavigationBarWidget == null) {
        bottomNavigationBarWidget = WidgetBuilderFactory.buildWidget(context, child, hoveredNode);
      } else if (child.type == 'AppBar' && appBarWidget == null) {
        appBarWidget = WidgetBuilderFactory.buildWidget(context, child, hoveredNode);
      } else {
        bodyChildren.add(WidgetBuilderFactory.buildWidget(context, child, hoveredNode));
      }
    }

    if (bodyChildren.isEmpty) {
      bodyWidget = const SizedBox();
    } else if (bodyChildren.length == 1) {
      bodyWidget = bodyChildren.first;
    } else {
      bodyWidget = Column(
        children: bodyChildren,
      );
    }

    return Scaffold(
      backgroundColor: parseColor(node.properties['backgroundColor'], context),
      appBar: appBarWidget is PreferredSizeWidget ? appBarWidget : null, // AppBar must be PreferredSizeWidget
      body: bodyWidget,
      floatingActionButton: floatingActionButtonWidget,
      drawer: drawerWidget,
      endDrawer: endDrawerWidget,
      bottomNavigationBar: bottomNavigationBarWidget,
    );
  }
}
 