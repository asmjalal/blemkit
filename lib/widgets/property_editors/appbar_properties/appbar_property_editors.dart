import 'package:designflutterkit/widgets/properties_panel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../../../models/widget_node.dart';
import '../text_field.dart';
import '../section_header.dart';
import '../color_picker_field.dart';
import '../slider_field.dart';
import 'package:designflutterkit/utils/color_utils.dart';


List<Widget> buildAppBarPropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  final properties = node.properties;
  final editors = <Widget>[];

  if (node.type == 'Scaffold') {
    editors.add(buildTextField(
      'Class Name',
      properties['className'] as String? ?? 'MyScreen',
      (value) {
        properties['className'] = value ?? 'MyScreen';
        provider.updateNodeProperties(node, properties);
      },
    ));
  }

  editors.addAll([
    buildSectionHeader('App Bar'),
    buildTextField(
      'Title',
      properties['title'] as String? ?? 'App Title',
      (value) {
        properties['title'] = (value == null) ? 'App Title' : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    ColorPickerField(
      label: 'Background Color',
      color: ColorUtils.parseColor(properties['backgroundColor'], Colors.blue),
      onColorChanged: (color) {
        properties['backgroundColor'] = color.value.toString();
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSliderField(
      'Elevation',
      (properties['elevation'] is num && properties['elevation'] != null) ? properties['elevation'].toDouble() : 0.0,
      0.0,
      24.0,
      (value) {
        properties['elevation'] = (value == null || value.isNaN) ? 0.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    SwitchListTile(
      title: const Text('Show Default Button'),
      value: properties['showDefaultButton'] == true,
      onChanged: (value) {
        properties['showDefaultButton'] = value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSectionHeader('AppBar Behavior'),
    SwitchListTile(
      title: const Text('Collapsible (SliverAppBar)'),
      value: properties['collapsible'] == true,
      onChanged: (value) {
        properties['collapsible'] = value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    SwitchListTile(
      title: const Text('Pinned'),
      value: properties['pinned'] == true,
      onChanged: (value) {
        properties['pinned'] = value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    SwitchListTile(
      title: const Text('Floating'),
      value: properties['floating'] == true,
      onChanged: (value) {
        properties['floating'] = value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    SwitchListTile(
      title: const Text('Snap'),
      value: properties['snap'] == true,
      onChanged: (value) {
        properties['snap'] = value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSectionHeader('Layout Properties'),
    buildSliderField(
      'Expanded Height',
      (properties['expandedHeight'] is num && properties['expandedHeight'] != null) ? properties['expandedHeight'].toDouble() : 200.0,
      56.0,
      400.0,
      (value) {
        properties['expandedHeight'] = (value == null || value.isNaN) ? 200.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSliderField(
      'Collapsed Height',
      (properties['collapsedHeight'] is num && properties['collapsedHeight'] != null) ? properties['collapsedHeight'].toDouble() : 56.0,
      32.0,
      200.0,
      (value) {
        properties['collapsedHeight'] = (value == null || value.isNaN) ? 56.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSliderField(
      'Toolbar Height',
      (properties['toolbarHeight'] is num && properties['toolbarHeight'] != null) ? properties['toolbarHeight'].toDouble() : 56.0,
      32.0,
      200.0,
      (value) {
        properties['toolbarHeight'] = (value == null || value.isNaN) ? 56.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    SwitchListTile(
      title: const Text('Add Bottom Section'),
      value: properties['addBottomSection'] == true,
      onChanged: (value) {
        properties['addBottomSection'] = value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSectionHeader('Title Properties'),
    SwitchListTile(
      title: const Text('Center Title'),
      value: properties['centerTitle'] == true,
      onChanged: (value) {
        properties['centerTitle'] = value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    SwitchListTile(
      title: const Text('Use Flexible Space'),
      value: properties['useFlexibleSpace'] == true,
      onChanged: (value) {
        properties['useFlexibleSpace'] = value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSectionHeader('Background Properties'),
    SwitchListTile(
      title: const Text('Add Background Widget'),
      value: properties['addBackgroundWidget'] == true,
      onChanged: (value) {
        properties['addBackgroundWidget'] = value;
        provider.updateNodeProperties(node, properties);
      },
    ),
  ]);

  return editors;
} 