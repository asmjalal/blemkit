import 'package:designflutterkit/widgets/property_editors/edge_insets_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../providers/widget_tree_provider.dart';
import '../models/widget_node.dart';
import 'property_editors/container_properties/container_property_editors.dart';
import 'property_editors/text_properties/text_property_editors.dart';
import 'property_editors/row_column_properties/row_column_property_editors.dart';
import 'property_editors/button_properties/button_property_editors.dart';
import 'property_editors/image_properties/image_property_editors.dart';
import 'property_editors/icon_properties/icon_property_editors.dart';
import 'property_editors/input_properties/input_property_editors.dart';
import 'property_editors/radio_properties/radio_property_editors.dart';
import 'property_editors/switch_properties/switch_property_editors.dart';
import 'property_editors/slider_properties/slider_property_editors.dart';
import 'property_editors/progress_properties/progress_property_editors.dart';
import 'property_editors/card_properties/card_property_editors.dart';
import 'property_editors/list_properties/list_property_editors.dart';
import 'property_editors/grid_properties/grid_property_editors.dart';
import 'property_editors/tab_properties/tab_property_editors.dart';
import 'property_editors/appbar_properties/appbar_property_editors.dart';
import 'property_editors/drawer_properties/drawer_property_editors.dart';
import 'property_editors/bottom_nav_properties/bottom_nav_property_editors.dart';
import 'property_editors/floating_action_properties/floating_action_property_editors.dart';
import 'property_editors/dialog_properties/dialog_property_editors.dart';
import 'property_editors/snackbar_properties/snackbar_property_editors.dart';
import 'property_editors/tooltip_properties/tooltip_property_editors.dart';
import 'property_editors/expansion_properties/expansion_property_editors.dart';
import 'property_editors/padding_properties.dart';
import 'property_editors/circle_avatar_properties/circle_avatar_property_editors.dart';
import '../utils/color_utils.dart';
import 'property_editors/color_picker_field.dart';

class PropertiesPanel extends StatelessWidget {
   PropertiesPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WidgetTreeProvider>(
      builder: (context, provider, child) {
        final selectedNode = provider.selectedNode;
        if (selectedNode == null) {
          return const Center(
            child: Text(
              'Select a widget to edit its properties',
              style: TextStyle(color: Color(0xFF94A3B8)),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    Text(
                      '${selectedNode.type} Properties',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.info_outline, size: 14, color: Colors.white.withOpacity(0.3)),
                    const Spacer(),
                    const Icon(Icons.expand_more, size: 18, color: Colors.white38),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  children: _buildPropertyEditors(context, selectedNode),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildPropertyEditors(BuildContext context, WidgetNode node) {
    final editors = _getSpecificEditors(context, node);
    editors.add(const Divider(height: 32));
    editors.add(_buildDataBindingSection(context, node));
    return editors;
  }

  List<Widget> _getSpecificEditors(BuildContext context, WidgetNode node) {
    switch (node.type) {
      case 'Scaffold':
        final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
        final properties = node.properties;
        return [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: TextEditingController(text: properties['className'] ?? ''),
              decoration: const InputDecoration(
                labelText: 'Page Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                properties['className'] = value;
                provider.updateNodeProperties(node, properties);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: TextEditingController(text: properties['description'] ?? ''),
              decoration: const InputDecoration(
                labelText: 'Page Description',
                border: OutlineInputBorder(),
              ),
              minLines: 1,
              maxLines: 3,
              onChanged: (value) {
                properties['description'] = value;
                provider.updateNodeProperties(node, properties);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                const Text(
                  'Background Color:',
                  style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white70),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () async {
                    Color initialColor = ColorUtils.parseColor(properties['backgroundColor'], Colors.blue);
                    Color tempColor = initialColor;
                    TextEditingController hexController = TextEditingController(text: '#${initialColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}');
                    TextEditingController rController = TextEditingController(text: tempColor.red.toString());
                    TextEditingController gController = TextEditingController(text: tempColor.green.toString());
                    TextEditingController bController = TextEditingController(text: tempColor.blue.toString());
                    TextEditingController aController = TextEditingController(text: (tempColor.opacity * 100).round().toString());
                    void updateControllers(Color color) {
                      hexController.text = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                      rController.text = color.red.toString();
                      gController.text = color.green.toString();
                      bController.text = color.blue.toString();
                      aController.text = (color.opacity * 100).round().toString();
                    }
                    Color? picked = await showDialog<Color>(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Pick Background Color'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ColorPicker(
                                pickerColor: tempColor,
                                onColorChanged: (color) {
                                  tempColor = color;
                                  updateControllers(color);
                                },
                                enableAlpha: true,
                                showLabel: false,
                              ),
                              const SizedBox(height: 12),
                              TextField(
                                controller: hexController,
                                decoration: const InputDecoration(
                                  labelText: 'HEX',
                                  prefixText: '#',
                                  border: OutlineInputBorder(),
                                ),
                                maxLength: 8,
                                onChanged: (value) {
                                  final hex = value.replaceAll('#', '').replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
                                  if (hex.length == 6 || hex.length == 8) {
                                    try {
                                      tempColor = Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
                                      updateControllers(tempColor);
                                    } catch (_) {}
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Flexible(
                                    child: TextField(
                                      controller: rController,
                                      decoration: const InputDecoration(labelText: 'R', border: OutlineInputBorder()),
                                      keyboardType: TextInputType.number,
                                      maxLength: 3,
                                      onChanged: (value) {
                                        int r = int.tryParse(value) ?? tempColor.red;
                                        r = r.clamp(0, 255);
                                        tempColor = tempColor.withRed(r);
                                        updateControllers(tempColor);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: TextField(
                                      controller: gController,
                                      decoration: const InputDecoration(labelText: 'G', border: OutlineInputBorder()),
                                      keyboardType: TextInputType.number,
                                      maxLength: 3,
                                      onChanged: (value) {
                                        int g = int.tryParse(value) ?? tempColor.green;
                                        g = g.clamp(0, 255);
                                        tempColor = tempColor.withGreen(g);
                                        updateControllers(tempColor);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: TextField(
                                      controller: bController,
                                      decoration: const InputDecoration(labelText: 'B', border: OutlineInputBorder()),
                                      keyboardType: TextInputType.number,
                                      maxLength: 3,
                                      onChanged: (value) {
                                        int b = int.tryParse(value) ?? tempColor.blue;
                                        b = b.clamp(0, 255);
                                        tempColor = tempColor.withBlue(b);
                                        updateControllers(tempColor);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: TextField(
                                      controller: aController,
                                      decoration: const InputDecoration(labelText: 'A', border: OutlineInputBorder()),
                                      keyboardType: TextInputType.number,
                                      maxLength: 3,
                                      onChanged: (value) {
                                        int a = int.tryParse(value) ?? (tempColor.opacity * 100).round();
                                        a = a.clamp(0, 100);
                                        tempColor = tempColor.withAlpha(((a / 100) * 255).round());
                                        updateControllers(tempColor);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(tempColor),
                              child: const Text('Select'),
                            ),
                          ],
                        );
                      },
                    );
                    if (picked != null) {
                      properties['backgroundColor'] = picked.value.toString();
                      provider.updateNodeProperties(node, properties);
                    }
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: (properties['backgroundColor'] != null && int.tryParse(properties['backgroundColor'].toString()) != null)
                          ? Color(int.parse(properties['backgroundColor'].toString()))
                          : Colors.white,
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SwitchListTile(
            title: const Text(
              'Safe Area',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            value: properties['safeArea'] == true,
            onChanged: (value) {
              properties['safeArea'] = value;
              provider.updateNodeProperties(node, properties);
            },
          ),
        ];
      case 'Container':
        return buildContainerPropertyEditors(context, node);
      case 'Text':
        return buildTextPropertyEditors(context, node);
      case 'Row':
        return buildRowPropertyEditors(context, node);
      case 'Column':
        return buildColumnPropertyEditors(context, node);
      case 'ElevatedButton':
      case 'TextButton':
      case 'OutlinedButton':
      case 'Button':
        return buildButtonPropertyEditors(context, node);
      case 'Image':
        return buildImagePropertyEditors(context, node);
      case 'CircleImage':
        return buildCircleImagePropertyEditors(context, node);
      case 'CircleAvatar':
        return buildCircleAvatarPropertyEditors(context, node);
      case 'ListTile':
        return buildListTilePropertyEditors(context, node);
      case 'Icon':
        return buildIconPropertyEditors(context, node);
      case 'IconButton':
        return buildIconButtonPropertyEditors(context, node);
      case 'TextField':
        return buildTextFieldPropertyEditors(context, node);
      case 'Radio':
        return buildRadioPropertyEditors(context, node);
      case 'Switch':
        return buildSwitchPropertyEditors(context, node);
      case 'Slider':
        return buildSliderPropertyEditors(context, node);
      case 'ProgressIndicator':
        return buildProgressPropertyEditors(context, node);
      case 'Card':
        return buildCardPropertyEditors(context, node);
      case 'ListView':
        return buildListPropertyEditors(context, node);
      case 'GridView':
        return buildGridPropertyEditors(context, node);
      case 'TabBar':
        return buildTabPropertyEditors(context, node);
      case 'AppBar':
        return buildAppBarPropertyEditors(context, node);
      case 'Drawer':
        return buildDrawerPropertyEditors(context, node);
      case 'BottomNavigationBar':
        return buildBottomNavPropertyEditors(context, node);
      case 'FloatingActionButton':
      case 'FAB':
        return buildFloatingActionPropertyEditors(context, node);
      case 'Dialog':
        return buildDialogPropertyEditors(context, node);
      case 'SnackBar':
        return buildSnackBarPropertyEditors(context, node);
      case 'Tooltip':
        return buildTooltipPropertyEditors(context, node);
      case 'ExpansionTile':
        return buildExpansionPropertyEditors(context, node);
      case 'Padding':
        final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
        final pTop = (node.properties['paddingTop'] is num) ? node.properties['paddingTop'].toDouble() : 0.0;
        final pRight = (node.properties['paddingRight'] is num) ? node.properties['paddingRight'].toDouble() : 0.0;
        final pBottom = (node.properties['paddingBottom'] is num) ? node.properties['paddingBottom'].toDouble() : 0.0;
        final pLeft = (node.properties['paddingLeft'] is num) ? node.properties['paddingLeft'].toDouble() : 0.0;
        final linked = node.properties['paddingLinked'] == true;
        return [
          VisualEdgeInsetsEditor(
            label: 'Padding',
            top: pTop,
            right: pRight,
            bottom: pBottom,
            left: pLeft,
            linked: linked,
            onChanged: (insets) {
              provider.updateNodeProperties(node, {
                ...node.properties,
                'paddingTop': insets.top,
                'paddingRight': insets.right,
                'paddingBottom': insets.bottom,
                'paddingLeft': insets.left,
              });
            },
            onLinkChanged: (isLinked) {
              provider.updateNodeProperties(node, {
                ...node.properties,
                'paddingLinked': isLinked,
              });
            },
          ),
        ];
      default:
        return [
          const Text('No property editor available for this widget.')
        ];
    }
  }

  Widget _buildDataBindingSection(BuildContext context, WidgetNode node) {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    final binding = node.properties['dataBinding'] as Map<String, dynamic>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.link, size: 16, color: Color(0xFF0fadd5)),
            const SizedBox(width: 8),
            Text(
              'DATA BINDING',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.indigo.shade400,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text(
          'Bind properties to API response fields.',
          style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
        ),
        const SizedBox(height: 16),
        _buildBindingField(
          context: context,
          label: 'Data Source Field',
          hint: 'e.g. users[0].name',
          value: binding['field'] ?? '',
          onChanged: (val) {
            final Map<String, dynamic> newBinding = {...binding, 'field': val};
            final Map<String, dynamic> newProps = {...node.properties, 'dataBinding': newBinding};
            provider.updateNodeProperties(node, newProps);
          },
        ),
      ],
    );
  }

  Widget _buildBindingField({
    required BuildContext context,
    required String label,
    required String hint,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: TextEditingController(text: value)..selection = TextSelection.fromPosition(TextPosition(offset: value.length)),
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();