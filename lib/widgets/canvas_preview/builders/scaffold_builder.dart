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
    if (node.properties['appBar'] is Map<String, dynamic>) {
      final appBarNode = WidgetNode.fromJson(node.properties['appBar']);
      appBarWidget = WidgetBuilderFactory.buildWidget(context, appBarNode, hoveredNode);
    } else if (node.properties['appBar'] is WidgetNode) { // Handle direct WidgetNode if it somehow gets here
      appBarWidget = WidgetBuilderFactory.buildWidget(context, node.properties['appBar'] as WidgetNode, hoveredNode);
    }

    // Handle FloatingActionButton from properties
    final dynamic fabProperty = node.properties['floatingActionButton'];
    print('ScaffoldBuilder: FloatingActionButton property: value=$fabProperty, type=${fabProperty?.runtimeType}');
    if (fabProperty is Map<String, dynamic>) {
      try {
        final fabNode = WidgetNode.fromJson(fabProperty);
        floatingActionButtonWidget = WidgetBuilderFactory.buildWidget(context, fabNode, hoveredNode);
      } catch (e) {
        print('ScaffoldBuilder: Error building FloatingActionButton from Map: $e. Falling back to null.');
        floatingActionButtonWidget = null;
      }
    } else if (fabProperty is WidgetNode) {
      floatingActionButtonWidget = WidgetBuilderFactory.buildWidget(context, fabProperty as WidgetNode, hoveredNode);
    }

    // Handle Drawer from properties
    if (node.properties['drawer'] is Map<String, dynamic>) {
      final drawerNode = WidgetNode.fromJson(node.properties['drawer']);
      drawerWidget = WidgetBuilderFactory.buildWidget(context, drawerNode, hoveredNode);
    } else if (node.properties['drawer'] is WidgetNode) {
      drawerWidget = WidgetBuilderFactory.buildWidget(context, node.properties['drawer'] as WidgetNode, hoveredNode);
    }

    // Handle EndDrawer from properties
    if (node.properties['endDrawer'] is Map<String, dynamic>) {
      final endDrawerNode = WidgetNode.fromJson(node.properties['endDrawer']);
      endDrawerWidget = WidgetBuilderFactory.buildWidget(context, endDrawerNode, hoveredNode);
    } else if (node.properties['endDrawer'] is WidgetNode) {
      endDrawerWidget = WidgetBuilderFactory.buildWidget(context, node.properties['endDrawer'] as WidgetNode, hoveredNode);
    }

    // Handle BottomNavigationBar from properties
    if (node.properties['bottomNavigationBar'] is Map<String, dynamic>) {
      final bottomNavNode = WidgetNode.fromJson(node.properties['bottomNavigationBar']);
      bottomNavigationBarWidget = WidgetBuilderFactory.buildWidget(context, bottomNavNode, hoveredNode);
    } else if (node.properties['bottomNavigationBar'] is WidgetNode) {
      bottomNavigationBarWidget = WidgetBuilderFactory.buildWidget(context, node.properties['bottomNavigationBar'] as WidgetNode, hoveredNode);
    }

    // Remaining children are assumed to be part of the body
    List<Widget> bodyChildren = [];
    for (var child in node.children) {
      bodyChildren.add(WidgetBuilderFactory.buildWidget(context, child, hoveredNode));
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
      backgroundColor: parseColor(node.properties['backgroundColor']),
      appBar: appBarWidget is PreferredSizeWidget ? appBarWidget : null, // AppBar must be PreferredSizeWidget
      body: bodyWidget,
      floatingActionButton: floatingActionButtonWidget,
      drawer: drawerWidget,
      endDrawer: endDrawerWidget,
      bottomNavigationBar: bottomNavigationBarWidget,
    );
  }
}
 