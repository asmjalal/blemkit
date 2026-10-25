import 'package:designflutterkit/widgets/property_editors/edge_insets_editor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../models/supabase_connection_model.dart';
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
import 'property_editors/clip_r_rect_properties.dart';
import 'property_editors/circle_avatar_properties/circle_avatar_property_editors.dart';
import '../utils/color_utils.dart';
import 'property_editors/action_flow_editor.dart';
import 'logic/widget_logic_panel.dart';
import '../ui/editor_theme.dart';
import '../ui/editor_widgets.dart';

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

        final isPage = provider.screens.any((s) => s.id == selectedNode.id);
        final isComponent = provider.isComponentRoot(selectedNode);
        final actionCount = [
          'actions', 'onLongPress', 'onDoubleTap', 'onChanged', 'onSubmitted', 'onPageLoad'
        ].fold<int>(0, (n, k) => n + ((selectedNode.properties[k] as List?)?.length ?? 0));

        final header = Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 10, 10),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(color: EditorColors.accentSoft, borderRadius: BorderRadius.circular(8)),
                child: Icon(isComponent ? Icons.extension_outlined : isPage ? Icons.web_asset_rounded : Icons.widgets_outlined, size: 16, color: EditorColors.accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isComponent
                          ? '${selectedNode.properties['componentName'] ?? 'Component'}'
                          : isPage
                              ? '${selectedNode.properties['pageName'] ?? 'Page'}'
                              : selectedNode.type,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: EditorColors.text),
                    ),
                    Text(
                      isComponent ? 'Component · ${selectedNode.type}' : isPage ? 'Page · ${selectedNode.type}' : 'Widget',
                      style: const TextStyle(fontSize: 11.5, color: EditorColors.textFaint),
                    ),
                  ],
                ),
              ),
              EditorIconButton(
                icon: Icons.close_rounded,
                tooltip: 'Deselect',
                size: 16,
                onPressed: () => provider.selectNode(null),
              ),
            ],
          ),
        );

        Widget tab(IconData icon, String label, {int count = 0}) => Tab(
              height: 34,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 14),
                  const SizedBox(width: 5),
                  Text(label),
                  if (count > 0) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(color: EditorColors.accentSoft, borderRadius: BorderRadius.circular(6)),
                      child: Text('$count', style: const TextStyle(fontSize: 10.5, color: EditorColors.accent)),
                    ),
                  ],
                ],
              ),
            );

        return DefaultTabController(
          key: ValueKey(selectedNode.id),
          length: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: EditorColors.background,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: EditorColors.border),
                ),
                child: TabBar(
                  indicator: BoxDecoration(color: EditorColors.surfaceHover, borderRadius: BorderRadius.circular(7)),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelPadding: EdgeInsets.zero,
                  tabs: [
                    tab(Icons.tune_rounded, 'Properties'),
                    tab(Icons.bolt_rounded, 'Actions', count: actionCount),
                    tab(Icons.account_tree_outlined, 'Logic'),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  children: [
                    ListView(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
                      children: _buildPropertyEditors(context, selectedNode),
                    ),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: ActionFlowEditor(node: selectedNode)),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 8), child: WidgetLogicPanel(node: selectedNode)),
                  ],
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
            child: EditorField(
              label: 'Page name',
              child: EditorTextInput(
                value: '${properties['pageName'] ?? ''}',
                hint: 'e.g. Home',
                onChanged: (value) => provider.renameScreen(node, value),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: EditorField(
              label: 'Description',
              child: EditorTextInput(
                value: '${properties['description'] ?? ''}',
                hint: 'What this page is for',
                maxLines: 3,
                onChanged: (value) => provider.setNodeProperty(node, 'description', value),
              ),
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
      case 'ClipRRect':
        return buildClipRRectPropertyEditors(context, node);
      default:
        return [
          const Text('No property editor available for this widget.')
        ];
    }
  }

  Widget _buildDataBindingSection(BuildContext context, WidgetNode node) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final activeConnection = provider.activeConnection;

    if (activeConnection == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link, size: 16, color: Color(0xFF0FADD5)),
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
          const Card(
            color: Color(0xFF1E293B),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'No database connected. Please connect a Supabase project in the Data Sources tab to enable backend data binding.',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ),
          )
        ],
      );
    }

    final hasQueries = provider.queries.isNotEmpty;
    if (!hasQueries) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link, size: 16, color: Color(0xFF0FADD5)),
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
          const Card(
            color: Color(0xFF1E293B),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'No queries defined. Create a backend query under the Data Sources tab first.',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ),
          )
        ],
      );
    }

    // Determine if widget is a container that supports query attachments
    final isContainer = ['ListView', 'GridView', 'Column', 'Row', 'Container'].contains(node.type);
    final attachedQuery = node.backendQuery;

    // Determine bindable properties for this specific node
    final bindableProps = <String, String>{}; // Map of propertyKey -> Label
    if (node.type == 'Text') {
      bindableProps['text'] = 'Text Content';
    } else if (node.type == 'Image' || node.type == 'CircleImage') {
      bindableProps['src'] = 'Image Source URL';
    } else if (node.type == 'CircleAvatar') {
      bindableProps['url'] = 'Avatar Image URL';
    } else if (node.type == 'ListTile' ||
               node.type == 'CheckboxListTile' ||
               node.type == 'SwitchListTile' ||
               node.type == 'RadioListTile' ||
               node.type == 'SlidableListTile') {
      bindableProps['title'] = 'Title Text';
      bindableProps['subtitle'] = 'Subtitle Text';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.link, size: 16, color: Color(0xFF0FADD5)),
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

        // 1. Query Attachment (for containers)
        if (isContainer) ...[
          const Text('Attach Backend Query', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: attachedQuery?['queryId'],
            dropdownColor: const Color(0xFF1E293B),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: const Color(0xFF181A20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('No Query Attached', style: TextStyle(color: Colors.white30)),
              ),
              ...provider.queries.map((q) => DropdownMenuItem<String>(
                    value: q.id,
                    child: Text(q.name, style: const TextStyle(color: Colors.white)),
                  )),
            ],
            onChanged: (val) {
              if (val == null) {
                node.backendQuery = null;
              } else {
                node.backendQuery = {
                  'queryId': val,
                  'variableName': 'itemsList',
                };
              }
              provider.notify();
            },
          ),
          const SizedBox(height: 16),
        ],

        // 2. Property Binding (Text, Image, etc.)
        if (bindableProps.isNotEmpty) ...[
          const Text('Property Bindings', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...bindableProps.entries.map((entry) {
            final propKey = entry.key;
            final propLabel = entry.value;
            final boundConfig = node.dataBinding?[propKey];

            return Card(
              color: const Color(0xFF1E293B),
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(propLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        const Spacer(),
                        if (boundConfig != null)
                          IconButton(
                            icon: const Icon(Icons.link_off, color: Colors.redAccent, size: 16),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              final currentBindings = node.dataBinding ?? {};
                              currentBindings.remove(propKey);
                              node.dataBinding = currentBindings.isEmpty ? null : currentBindings;
                              provider.notify();
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Choose Query Dropdown
                    DropdownButtonFormField<String>(
                      value: boundConfig?['queryId'],
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: InputDecoration(
                        labelText: 'Source Query',
                        labelStyle: const TextStyle(color: Colors.white54, fontSize: 11),
                        isDense: true,
                        filled: true,
                        fillColor: const Color(0xFF181A20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Unbound / Static', style: TextStyle(color: Colors.white24)),
                        ),
                        ...provider.queries.map((q) => DropdownMenuItem<String>(
                              value: q.id,
                              child: Text(q.name, style: const TextStyle(color: Colors.white)),
                            )),
                      ],
                      onChanged: (qId) {
                        if (qId == null) {
                          final currentBindings = node.dataBinding ?? {};
                          currentBindings.remove(propKey);
                          node.dataBinding = currentBindings.isEmpty ? null : currentBindings;
                        } else {
                          final currentBindings = node.dataBinding ?? {};
                          currentBindings[propKey] = {
                            'source': 'backendQuery',
                            'queryId': qId,
                            'field': currentBindings[propKey]?['field'] ?? '',
                            'rowIndex': 0,
                          };
                          node.dataBinding = currentBindings;
                        }
                        provider.notify();
                      },
                    ),
                    
                    if (boundConfig?['queryId'] != null) ...[
                      const SizedBox(height: 8),
                      // Choose Column Dropdown
                      Builder(
                        builder: (context) {
                          final qId = boundConfig['queryId'] as String;
                          final queryObj = provider.queries.where((q) => q.id == qId).firstOrNull;
                          if (queryObj == null) return const SizedBox();

                          final tableSchema = activeConnection.tables.firstWhere(
                            (t) => t.name == queryObj.tableName,
                            orElse: () => SupabaseTable(name: '', columns: []),
                          );
                          final cols = tableSchema.columns.map((c) => c.name).toList();

                          return DropdownButtonFormField<String>(
                            value: cols.contains(boundConfig['field']) ? boundConfig['field'] : null,
                            dropdownColor: const Color(0xFF1E293B),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            decoration: InputDecoration(
                              labelText: 'Column / Field',
                              labelStyle: const TextStyle(color: Colors.white54, fontSize: 11),
                              isDense: true,
                              filled: true,
                              fillColor: const Color(0xFF181A20),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                            ),
                            items: cols.map((colName) => DropdownMenuItem<String>(
                                  value: colName,
                                  child: Text(colName, style: const TextStyle(color: Colors.white)),
                                )).toList(),
                            onChanged: (fieldVal) {
                              if (fieldVal != null) {
                                final currentBindings = node.dataBinding ?? {};
                                currentBindings[propKey] = {
                                  ...currentBindings[propKey] as Map,
                                  'field': fieldVal,
                                };
                                node.dataBinding = currentBindings;
                                provider.notify();
                              }
                            },
                          );
                        },
                      ),
                    ]
                  ],
                ),
              ),
            );
          }).toList(),
        ] else if (!isContainer) ...[
          const Card(
            color: Color(0xFF1E293B),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'This widget does not have bindable properties (e.g. Text Content or Image URL). Try selecting a Text or Image widget.',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
            ),
          )
        ]
      ],
    );
  }
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();