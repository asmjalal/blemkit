import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../models/widget_node.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../canvas_preview_mode.dart';

class IconButtonBuilder extends BaseWidgetBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    Widget? iconWidget;
    final dynamic iconProperty = node.properties['icon'];

    if (iconProperty is String) {
      // Use the same prefix-based dispatch as IconBuilder to handle FaIconData
      final iconData = parseIconData(iconProperty);
      if (iconProperty.startsWith('FontAwesomeIcons.')) {
        iconWidget = FaIcon(
          iconData,
          size: parseDouble(node.properties['size']),
          color: parseColor(node.properties['color'], context),
        );
      } else {
        iconWidget = Icon(
          iconData as IconData? ?? Icons.help,
          size: parseDouble(node.properties['size']),
          color: parseColor(node.properties['color'], context),
        );
      }
    } else if (iconProperty is WidgetNode || iconProperty is Map<String, dynamic>) {
      iconWidget = safeWidget(context, iconProperty, hoveredNode);
    } else {
      iconWidget = const Icon(Icons.help);
    }

    return IconButton(
      icon: iconWidget!,
      onPressed: () {
        if (!CanvasPreviewMode.of(context)) return;
        
        final navigateTo = node.properties['navigateTo'];
        if (navigateTo != null) {
          final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
          try {
            final target = provider.screens.firstWhere((s) => s.id == navigateTo);
            provider.selectScreen(target);
          } catch (_) {
            // Screen might have been deleted
          }
        }
      },
      // Size & color are already applied to the icon widget above — don't double-apply here
      iconSize: parseDouble(node.properties['size']) ?? 24.0,
    );
  }
}