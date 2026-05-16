import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';

class AppBarBuilder extends BaseWidgetBuilder {
  final WidgetBuilderFactory _widgetBuilderFactory;

  AppBarBuilder(this._widgetBuilderFactory);

  @override
  PreferredSizeWidget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    Widget? titleWidget;
    final dynamic titleProperty = node.properties['title'];
    print('AppBarBuilder: Processing title property: value=$titleProperty, type=${titleProperty?.runtimeType}');

    if (titleProperty is String) {
      titleWidget = Text(titleProperty);
    } else if (titleProperty is WidgetNode) {
      titleWidget = WidgetBuilderFactory.buildWidget(context, titleProperty, hoveredNode);
    } else if (titleProperty is Map<String, dynamic>) {
      try {
        final WidgetNode titleNode = WidgetNode.fromJson(titleProperty);
        titleWidget = WidgetBuilderFactory.buildWidget(context, titleNode, hoveredNode);
      } catch (e) {
        print('AppBarBuilder: Error building title from Map: $e. Falling back to Text widget.');
        titleWidget = const Text('Error: Invalid Title Node');
      }
    } else {
      titleWidget = const Text('Default AppBar Title'); // Fallback for unexpected types
    }

    return AppBar(
      title: titleWidget,
      backgroundColor: parseColor(node.properties['backgroundColor'], context),
      elevation: (node.properties['elevation'] as num?)?.toDouble(),
      centerTitle: node.properties['centerTitle'] == true,
      toolbarHeight: (node.properties['toolbarHeight'] as num?)?.toDouble(),
      leading: node.properties['leading'] != null
          ? safeWidget(context, node.properties['leading'], hoveredNode)
          : null,
      actions: (node.properties['actions'] as List<dynamic>? ?? []).map((action) {
        return safeWidget(context, action, hoveredNode) ?? const SizedBox();
      }).toList(),
      bottom: node.properties['bottom'] != null
          ? _buildPreferredSizeWidgetFromNode(context, node.properties['bottom'], hoveredNode)
          : null,
    );
  }

  PreferredSizeWidget _buildPreferredSizeWidgetFromNode(BuildContext context, dynamic property, WidgetNode? hoveredNode) {
    final builtWidget = safeWidget(context, property, hoveredNode);
    if (builtWidget is PreferredSizeWidget) {
      return builtWidget;
    } else {
      return PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: builtWidget ?? const SizedBox(),
      );
    }
  }
} 