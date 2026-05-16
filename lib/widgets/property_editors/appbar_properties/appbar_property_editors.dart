import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../../../models/widget_node.dart';
import '../section_header.dart';
import '../color_picker_field.dart';
import '../numeric_property_field.dart';
import 'package:designflutterkit/utils/color_utils.dart';

Widget _buildSectionHeaderWithIcon(String title) {
  return Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 4),
        Icon(Icons.info_outline, size: 14, color: Colors.white.withOpacity(0.3)),
        const Spacer(),
        const Icon(Icons.expand_more, size: 18, color: Colors.white38),
      ],
    ),
  );
}

List<Widget> buildAppBarPropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  final properties = node.properties;
  final editors = <Widget>[];

  editors.addAll([
    _buildSectionHeaderWithIcon('Visibility'),
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Conditional', style: TextStyle(color: Colors.white70, fontSize: 12)),
          Switch(
            value: properties['conditionalVisibility'] == true,
            onChanged: (val) {
              properties['conditionalVisibility'] = val;
              provider.updateNodeProperties(node, properties);
            },
            activeColor: Colors.deepPurpleAccent,
          ),
        ],
      ),
    ),
    const Divider(color: Colors.white10),

    _buildSectionHeaderWithIcon('Background Color'),
    ColorPickerField(
      label: 'Background Color',
      color: ColorUtils.parseColor(properties['backgroundColor'], Colors.blue),
      onColorChanged: (color) {
        properties['backgroundColor'] = color.value.toString();
        provider.updateNodeProperties(node, properties);
      },
    ),
    const SizedBox(height: 8),
    buildPropertyRow([
      buildNumericPropertyField(
        label: 'Elevation',
        value: (properties['elevation'] ?? 0).toString(),
        onChanged: (val) {
          properties['elevation'] = double.tryParse(val) ?? 0.0;
          provider.updateNodeProperties(node, properties);
        },
      ),
      Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Text('Default Button', style: TextStyle(color: Colors.white70, fontSize: 11)),
            Switch(
              value: properties['showDefaultButton'] == true,
              onChanged: (val) {
                properties['showDefaultButton'] = val;
                provider.updateNodeProperties(node, properties);
              },
              activeColor: Colors.deepPurpleAccent,
            ),
          ],
        ),
      ),
    ]),
    const Divider(color: Colors.white10),

    _buildSectionHeaderWithIcon('AppBar Behavior'),
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Collapsible (SliverAppBar)', style: TextStyle(color: Colors.white70, fontSize: 12)),
          Switch(
            value: properties['collapsible'] == true,
            onChanged: (val) {
              properties['collapsible'] = val;
              provider.updateNodeProperties(node, properties);
            },
            activeColor: Colors.deepPurpleAccent,
          ),
        ],
      ),
    ),
    const Divider(color: Colors.white10),

    _buildSectionHeaderWithIcon('Layout Properties'),
    buildNumericPropertyField(
      label: 'AppBar Height',
      unit: properties['appBarHeightUnit'] as String? ?? 'PX',
      value: (properties['expandedHeight'] ?? '').toString(),
      onChanged: (val) {
        properties['expandedHeight'] = double.tryParse(val) ?? 200.0;
        provider.updateNodeProperties(node, properties);
      },
      onUnitChanged: (newUnit) {
        properties['appBarHeightUnit'] = newUnit;
        provider.updateNodeProperties(node, properties);
      },
    ),
    const SizedBox(height: 8),
    buildNumericPropertyField(
      label: 'Toolbar Height',
      unit: properties['toolbarHeightUnit'] as String? ?? 'PX',
      value: (properties['toolbarHeight'] ?? '∞').toString(),
      onChanged: (val) {
        if (val == '∞') {
          properties['toolbarHeight'] = null;
        } else {
          properties['toolbarHeight'] = double.tryParse(val) ?? 56.0;
        }
        provider.updateNodeProperties(node, properties);
      },
      onUnitChanged: (newUnit) {
        properties['toolbarHeightUnit'] = newUnit;
        provider.updateNodeProperties(node, properties);
      },
    ),
    const SizedBox(height: 8),
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Add Bottom Section', style: TextStyle(color: Colors.white70, fontSize: 12)),
          Switch(
            value: properties['addBottomSection'] == true,
            onChanged: (val) {
              properties['addBottomSection'] = val;
              provider.updateNodeProperties(node, properties);
            },
            activeColor: Colors.deepPurpleAccent,
          ),
        ],
      ),
    ),
    const Divider(color: Colors.white10),

    _buildSectionHeaderWithIcon('Title Properties'),
    buildPropertyRow([
      Row(
        children: [
          const Text('Center Title', style: TextStyle(color: Colors.white70, fontSize: 11)),
          const Spacer(),
          Switch(
            value: properties['centerTitle'] == true,
            onChanged: (val) {
              properties['centerTitle'] = val;
              provider.updateNodeProperties(node, properties);
            },
            activeColor: Colors.deepPurpleAccent,
          ),
        ],
      ),
      Row(
        children: [
          const Text('Flexible Space', style: TextStyle(color: Colors.white70, fontSize: 11)),
          const Spacer(),
          Switch(
            value: properties['useFlexibleSpace'] == true,
            onChanged: (val) {
              properties['useFlexibleSpace'] = val;
              provider.updateNodeProperties(node, properties);
            },
            activeColor: Colors.deepPurpleAccent,
          ),
        ],
      ),
    ]),
    const Divider(color: Colors.white10),

    _buildSectionHeaderWithIcon('Background Properties'),
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Add Background Widget', style: TextStyle(color: Colors.white70, fontSize: 12)),
          Switch(
            value: properties['addBackgroundWidget'] == true,
            onChanged: (val) {
              properties['addBackgroundWidget'] = val;
              provider.updateNodeProperties(node, properties);
            },
            activeColor: Colors.deepPurpleAccent,
          ),
        ],
      ),
    ),
  ]);

  return editors;
}
 