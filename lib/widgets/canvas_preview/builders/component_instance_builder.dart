import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/project_logic.dart';
import '../../../models/widget_node.dart';
import '../../../providers/widget_tree_provider.dart';
import '../../../runtime/preview_runtime.dart';
import '../../../ui/editor_theme.dart';
import '../canvas_preview_mode.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';

/// Values and callbacks an instance passes to its component, resolved in the
/// instance's context.
class ComponentScope extends InheritedWidget {
  final Map<String, dynamic> args;
  final Map<String, List> callbacks;
  final BuildContext parentContext;

  const ComponentScope({super.key, required this.args, required this.callbacks, required this.parentContext, required super.child});

  static ComponentScope? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<ComponentScope>();

  @override
  bool updateShouldNotify(ComponentScope oldWidget) => true;
}

/// Renders a `ComponentInstance` node: the shared component tree with this
/// instance's arguments. Clicks select the instance, not the master's widgets.
class ComponentInstanceBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    final component = provider.componentById(node.properties['componentId'] as String?);
    if (component == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        color: const Color(0x22F87171),
        child: const Text('Missing component', style: TextStyle(color: EditorColors.danger)),
      );
    }
    final given = Map<String, dynamic>.from(node.properties['args'] as Map? ?? {});
    final args = <String, dynamic>{};
    final callbacks = <String, List>{};
    for (final p in PageLogic.pageParams(component.properties)) {
      if (p.type == VarTypes.action) {
        callbacks[p.name] = given[p.name] is List ? given[p.name] as List : const [];
      } else {
        args[p.name] = given.containsKey(p.name) ? PreviewRuntime.resolve(context, given[p.name]) : PreviewRuntime.defaultFor(p);
      }
    }
    final live = CanvasPreviewMode.of(context);
    final content = ComponentScope(
      args: args,
      callbacks: callbacks,
      parentContext: context,
      child: Builder(builder: (c) => WidgetBuilderFactory.buildWidget(c, component, null)),
    );
    // While editing, the instance is one selectable block.
    return live ? content : IgnorePointer(child: CanvasPreviewMode(isLivePreview: true, child: content));
  }
}
