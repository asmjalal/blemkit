import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/widget_tree_provider.dart';
import '../../../models/widget_node.dart';
import '../../properties_panel.dart';
import '../slider_field.dart';
import '../dropdown_field.dart';
import '../color_picker_field.dart';
import '../section_header.dart';
import '../edge_insets_editor.dart';
import 'dart:math';
import 'package:designflutterkit/utils/color_utils.dart';
import '../numeric_property_field.dart';


class _ContainerPaddingMarginEditor extends StatefulWidget {
  final Map<String, dynamic> properties;
  final void Function(Map<String, dynamic>) onChanged;
  final String label;
  final String prefix; // 'padding' or 'margin'
  const _ContainerPaddingMarginEditor({
    required this.properties,
    required this.onChanged,
    required this.label,
    required this.prefix,
  });
  @override
  State<_ContainerPaddingMarginEditor> createState() => _ContainerPaddingMarginEditorState();
}

class _ContainerPaddingMarginEditorState extends State<_ContainerPaddingMarginEditor> {
  bool get isOverall => widget.properties['${widget.prefix}Mode'] != 'independent';
  set isOverall(bool v) => widget.onChanged({...widget.properties, '${widget.prefix}Mode': v ? 'overall' : 'independent'});

  double get overallValue {
    return [
      widget.properties['${widget.prefix}Top'],
      widget.properties['${widget.prefix}Bottom'],
      widget.properties['${widget.prefix}Left'],
      widget.properties['${widget.prefix}Right'],
    ].whereType<num>().isNotEmpty
        ? [
            widget.properties['${widget.prefix}Top'] ?? 0.0,
            widget.properties['${widget.prefix}Bottom'] ?? 0.0,
            widget.properties['${widget.prefix}Left'] ?? 0.0,
            widget.properties['${widget.prefix}Right'] ?? 0.0,
          ].map((v) => v.toDouble()).reduce((a, b) => a + b) /
            4.0
        : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            ToggleButtons(
              isSelected: [isOverall, !isOverall],
              onPressed: (idx) {
                setState(() {
                  isOverall = idx == 0;
                  if (isOverall) {
                    // Set all sides to the average
                    final avg = overallValue;
                    widget.onChanged({
                      ...widget.properties,
                      '${widget.prefix}Top': avg,
                      '${widget.prefix}Bottom': avg,
                      '${widget.prefix}Left': avg,
                      '${widget.prefix}Right': avg,
                    });
                  }
                });
              },
              children: const [
                Icon(Icons.crop_square),
                Icon(Icons.crop_din),
              ],
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (isOverall)
          Row(
            children: [
              const Text('All Sides:'),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: TextEditingController(text: overallValue.toStringAsFixed(1)),
                  onChanged: (v) {
                    final val = double.tryParse(v) ?? 0.0;
                    widget.onChanged({
                      ...widget.properties,
                      '${widget.prefix}Top': val,
                      '${widget.prefix}Bottom': val,
                      '${widget.prefix}Left': val,
                      '${widget.prefix}Right': val,
                    });
                  },
                ),
              ),
            ],
          )
        else
          EdgeInsetsEditor(
            label: widget.label,
            top: (widget.properties['${widget.prefix}Top'] is num && widget.properties['${widget.prefix}Top'] != null) ? widget.properties['${widget.prefix}Top'].toDouble() : 0.0,
            bottom: (widget.properties['${widget.prefix}Bottom'] is num && widget.properties['${widget.prefix}Bottom'] != null) ? widget.properties['${widget.prefix}Bottom'].toDouble() : 0.0,
            left: (widget.properties['${widget.prefix}Left'] is num && widget.properties['${widget.prefix}Left'] != null) ? widget.properties['${widget.prefix}Left'].toDouble() : 0.0,
            right: (widget.properties['${widget.prefix}Right'] is num && widget.properties['${widget.prefix}Right'] != null) ? widget.properties['${widget.prefix}Right'].toDouble() : 0.0,
            onChanged: (vals) {
              widget.onChanged({
                ...widget.properties,
                '${widget.prefix}Top': vals['top'] ?? 0.0,
                '${widget.prefix}Bottom': vals['bottom'] ?? 0.0,
                '${widget.prefix}Left': vals['left'] ?? 0.0,
                '${widget.prefix}Right': vals['right'] ?? 0.0,
              });
            },
          ),
      ],
    );
  }
}

class _BackgroundStyleEditor extends StatefulWidget {
  final Map<String, dynamic> properties;
  final void Function(Map<String, dynamic>) onChanged;

  const _BackgroundStyleEditor({
    Key? key,
    required this.properties,
    required this.onChanged,
  }) : super(key: key);

  @override
  State<_BackgroundStyleEditor> createState() => _BackgroundStyleEditorState();
}

class _BackgroundStyleEditorState extends State<_BackgroundStyleEditor> {
  bool get isGradient => widget.properties['backgroundType'] == 'gradient' || widget.properties['gradient'] != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Background Type', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.white70)),
            DropdownButton<String>(
              value: isGradient ? 'gradient' : 'solid',
              isDense: true,
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(value: 'solid', child: Text('Solid')),
                DropdownMenuItem(value: 'gradient', child: Text('Gradient')),
              ],
              onChanged: (val) {
                if (val != null) {
                  final newProps = Map<String, dynamic>.from(widget.properties);
                  newProps['backgroundType'] = val;
                  if (val == 'solid') {
                    newProps.remove('gradient');
                  } else {
                    newProps['gradient'] = {
                      'colors': [Colors.blue.value.toString(), Colors.pink.value.toString()],
                      'begin': 'Alignment.centerLeft',
                      'end': 'Alignment.centerRight',
                    };
                  }
                  widget.onChanged(newProps);
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!isGradient)
          ColorPickerField(
            label: 'Background Color',
            color: ColorUtils.parseColor(widget.properties['color'], Colors.transparent),
            onColorChanged: (color) {
              final newProps = Map<String, dynamic>.from(widget.properties);
              newProps['color'] = color.value.toString();
              widget.onChanged(newProps);
            },
          )
        else ...[
          ColorPickerField(
            label: 'Gradient Color 1',
            color: ColorUtils.parseColor(widget.properties['gradient']?['colors']?[0], Colors.blue),
            onColorChanged: (color) {
              final newProps = Map<String, dynamic>.from(widget.properties);
              final grad = Map<String, dynamic>.from(newProps['gradient'] ?? {});
              final colors = List<dynamic>.from(grad['colors'] ?? [Colors.blue.value.toString(), Colors.pink.value.toString()]);
              if (colors.isNotEmpty) colors[0] = color.value.toString();
              grad['colors'] = colors;
              newProps['gradient'] = grad;
              widget.onChanged(newProps);
            },
          ),
          const SizedBox(height: 8),
          ColorPickerField(
            label: 'Gradient Color 2',
            color: () {
              final colors = (widget.properties['gradient']?['colors'] as List?) ?? const [];
              final dynamic colorValue = colors.length > 1 ? colors[1] : null;
              return ColorUtils.parseColor(colorValue, Colors.pink);
            }(),
            onColorChanged: (color) {
              final newProps = Map<String, dynamic>.from(widget.properties);
              final grad = Map<String, dynamic>.from(newProps['gradient'] ?? {});
              final colors = List<dynamic>.from(grad['colors'] ?? [Colors.blue.value.toString(), Colors.pink.value.toString()]);
              if (colors.length > 1) {
                colors[1] = color.value.toString();
              } else {
                colors.add(color.value.toString());
              }
              grad['colors'] = colors;
              newProps['gradient'] = grad;
              widget.onChanged(newProps);
            },
          ),
        ]
      ],
    );
  }
}

List<Widget> buildContainerPropertyEditors(BuildContext context, WidgetNode node) {
  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
  final properties = node.properties;
  final editors = <Widget>[];

  editors.addAll([
    buildSectionHeader('Layout'),
    buildPropertyRow([
      buildNumericPropertyField(
        label: 'Width',
        value: (properties['width'] ?? 100.0).toStringAsFixed(0),
        onChanged: (value) {
          properties['width'] = double.tryParse(value) ?? 100.0;
          provider.updateNodeProperties(node, properties);
        },
      ),
      buildNumericPropertyField(
        label: 'Height',
        value: (properties['height'] ?? 100.0).toStringAsFixed(0),
        onChanged: (value) {
          properties['height'] = double.tryParse(value) ?? 100.0;
          provider.updateNodeProperties(node, properties);
        },
      ),
    ]),
    buildPropertyRow([
      buildNumericPropertyField(
        label: 'Min W',
        value: (properties['minWidth'] ?? '').toString(),
        onChanged: (value) {
          properties['minWidth'] = double.tryParse(value);
          provider.updateNodeProperties(node, properties);
        },
      ),
      buildNumericPropertyField(
        label: 'Min H',
        value: (properties['minHeight'] ?? '').toString(),
        onChanged: (value) {
          properties['minHeight'] = double.tryParse(value);
          provider.updateNodeProperties(node, properties);
        },
      ),
    ]),
    buildSliderField(
      'Radius',
      (properties['borderRadius'] is num && properties['borderRadius'] != null) ? properties['borderRadius'].toDouble() : 0.0,
      0.0,
      64.0,
      (value) {
        properties['borderRadius'] = (value == null || value.isNaN) ? 0.0 : value;
        provider.updateNodeProperties(node, properties);
      },
    ),
    buildSectionHeader('Alignment'),
    buildDropdownField(
      'Alignment',
      properties['alignment'] as String? ?? 'center',
      ['topLeft', 'topCenter', 'topRight', 'centerLeft', 'center', 'centerRight', 'bottomLeft', 'bottomCenter', 'bottomRight'],
      (value) {
        properties['alignment'] = value ?? 'center';
        provider.updateNodeProperties(node, properties);
      },
    ),
    EdgeInsetsEditor(
      label: 'Padding',
      top: (properties['paddingTop'] is num) ? properties['paddingTop'].toDouble() : 0.0,
      right: (properties['paddingRight'] is num) ? properties['paddingRight'].toDouble() : 0.0,
      bottom: (properties['paddingBottom'] is num) ? properties['paddingBottom'].toDouble() : 0.0,
      left: (properties['paddingLeft'] is num) ? properties['paddingLeft'].toDouble() : 0.0,
      onChanged: (vals) {
        provider.updateNodeProperties(node, {
          ...properties,
          'paddingTop': vals['top'] ?? 0.0,
          'paddingRight': vals['right'] ?? 0.0,
          'paddingBottom': vals['bottom'] ?? 0.0,
          'paddingLeft': vals['left'] ?? 0.0,
        });
      },
    ),
    EdgeInsetsEditor(
      label: 'Margin',
      top: (properties['marginTop'] is num) ? properties['marginTop'].toDouble() : 0.0,
      right: (properties['marginRight'] is num) ? properties['marginRight'].toDouble() : 0.0,
      bottom: (properties['marginBottom'] is num) ? properties['marginBottom'].toDouble() : 0.0,
      left: (properties['marginLeft'] is num) ? properties['marginLeft'].toDouble() : 0.0,
      onChanged: (vals) {
        provider.updateNodeProperties(node, {
          ...properties,
          'marginTop': vals['top'] ?? 0.0,
          'marginRight': vals['right'] ?? 0.0,
          'marginBottom': vals['bottom'] ?? 0.0,
          'marginLeft': vals['left'] ?? 0.0,
        });
      },
    ),
    const SizedBox(height: 16),
    buildSectionHeader('Style'),
    _BackgroundStyleEditor(
      properties: properties,
      onChanged: (newProps) {
        provider.updateNodeProperties(node, newProps);
      },
    ),
    buildSectionHeader('Border'),
    buildPropertyRow([
      ColorPickerField(
        label: 'Color',
        color: ColorUtils.parseColor(properties['borderColor'], Colors.black),
        onColorChanged: (color) {
          properties['borderColor'] = color.value.toString();
          provider.updateNodeProperties(node, properties);
        },
      ),
      buildSliderField('Width', (properties['borderWidth'] is num && properties['borderWidth'] != null) ? properties['borderWidth'].toDouble() : 0.0, 0.0, 16.0, (value) {
        properties['borderWidth'] = (value == null || value.isNaN) ? 0.0 : value;
        provider.updateNodeProperties(node, properties);
      }),
    ]),
    buildSectionHeader('Box Shadow'),
    buildPropertyRow([
      ColorPickerField(
        label: 'Shadow',
        color: ColorUtils.parseColor(properties['shadowColor'], Colors.black26),
        onColorChanged: (color) {
          properties['shadowColor'] = color.value.toString();
          provider.updateNodeProperties(node, properties);
        },
      ),
      buildSliderField('Blur', (properties['shadowBlur'] is num && properties['shadowBlur'] != null) ? properties['shadowBlur'].toDouble() : 0.0, 0.0, 32.0, (value) {
        properties['shadowBlur'] = (value == null || value.isNaN) ? 0.0 : value;
        provider.updateNodeProperties(node, properties);
      }),
    ]),
    buildPropertyRow([
      buildSliderField('X', (properties['shadowX'] is num && properties['shadowX'] != null) ? properties['shadowX'].toDouble() : 0.0, -32.0, 32.0, (value) {
        properties['shadowX'] = (value == null || value.isNaN) ? 0.0 : value;
        provider.updateNodeProperties(node, properties);
      }),
      buildSliderField('Y', (properties['shadowY'] is num && properties['shadowY'] != null) ? properties['shadowY'].toDouble() : 0.0, -32.0, 32.0, (value) {
        properties['shadowY'] = (value == null || value.isNaN) ? 0.0 : value;
        provider.updateNodeProperties(node, properties);
      }),
    ]),
  ]);

  return editors;
} 