import 'package:designflutterkit/widgets/widget_tree/widget_tree_node.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/widget_node.dart';
import '../../providers/widget_tree_provider.dart';

// TODO: Integrate custom overlay menu system for widget add (+) button. Implementation will be in lib/widgets/custom_overlay_menu/.

class WidgetTreeEditor extends StatefulWidget {
  final void Function(String type)? onWidgetAdd;
  const WidgetTreeEditor({super.key, this.onWidgetAdd});

  static WidgetNode createWidgetNodeWithDefaults(String type) {
    switch (type) {
      case 'Container':
        return WidgetNode(type: 'Container', properties: {
          'width': 100.0,
          'height': 100.0,
          'color': Colors.transparent.value.toString(),
          'borderRadius': 0.0,
          'alignment': 'center',
          'padding': 0.0,
          'margin': 0.0,
          'borderColor': Colors.black.value.toString(),
          'borderWidth': 0.0,
          'shadowColor': Colors.black26.value.toString(),
          'shadowBlur': 0.0,
          'shadowX': 0.0,
          'shadowY': 0.0,
        });
      case 'Row':
        return WidgetNode(type: 'Row', properties: {
          'mainAxisAlignment': 'start',
          'mainAxisSize': 'max',
          'crossAxisAlignment': 'center',
          'verticalDirection': 'down',
          'textDirection': 'ltr',
          'scrollable': false,
        });
      case 'Column':
        return WidgetNode(type: 'Column', properties: {
          'mainAxisAlignment': 'start',
          'mainAxisSize': 'max',
          'crossAxisAlignment': 'center',
          'verticalDirection': 'down',
          'textDirection': 'ltr',
        });
      case 'Text':
        return WidgetNode(type: 'Text', properties: {
          'text': 'Text',
          'fontSize': 14.0,
          'color': Colors.black.value.toString(),
          'fontWeight': 'normal',
        });
      case 'ElevatedButton':
        return WidgetNode(type: 'ElevatedButton', properties: {
          'text': 'Button',
        });
      case 'TextField':
        return WidgetNode(type: 'TextField', properties: {
          'hintText': '',
          'labelText': '',
        });
      case 'AppBar':
        return WidgetNode(type: 'AppBar', properties: {
          'title': WidgetNode(type: 'Text', properties: {'text': 'App Bar'}),
          'backgroundColor': Colors.blue.value.toString(),
          'elevation': 0.0,
          'showDefaultButton': false,
          'collapsible': false,
          'pinned': false,
          'floating': false,
          'snap': false,
          'expandedHeight': 200.0,
          'collapsedHeight': 56.0,
          'toolbarHeight': 56.0,
          'addBottomSection': false,
          'centerTitle': false,
          'useFlexibleSpace': false,
          'addBackgroundWidget': false,
          'leading': WidgetNode(type: 'Icon', properties: {'icon': 'menu'}),
          'actions': [],
        });
      case 'Image':
        return WidgetNode(type: 'Image', properties: {
          'src': '',
          'width': 100.0,
          'height': 100.0,
          'fit': 'cover',
          'borderRadius': 0.0,
        });
      case 'ListView':
        return WidgetNode(type: 'ListView', properties: {
          'scrollDirection': 'vertical',
          'padding': 0.0,
          'shrinkWrap': false,
        });
      case 'GridView':
        return WidgetNode(type: 'GridView', properties: {
          'crossAxisCount': 2,
          'mainAxisSpacing': 0.0,
          'crossAxisSpacing': 0.0,
          'childAspectRatio': 1.0,
        });
      case 'ExpansionTile':
        return WidgetNode(type: 'ExpansionTile', properties: {
          'title': 'Expansion Tile',
          'initiallyExpanded': false,
        });
      case 'RichText':
        return WidgetNode(type: 'RichText', properties: {
          'text': 'Rich Text',
          'fontSize': 14.0,
          'color': Colors.black.value.toString(),
          'fontWeight': 'normal',
        });
      case 'CircleImage':
        return WidgetNode(type: 'CircleImage', properties: {
          'src': '',
          'radius': 50.0,
        });
      case 'Icon':
        return WidgetNode(type: 'Icon', properties: {
          'icon': 'settings',
          'size': 24.0,
          'color': Colors.black.value.toString(),
        });
      case 'Button':
        return WidgetNode(type: 'Button', properties: {
          'text': 'Button',
          'onPressed': true,
        });
      case 'IconButton':
        return WidgetNode(type: 'IconButton', properties: {
          'icon': WidgetNode(type: 'Icon', properties: {'icon': 'add'}),
          'size': 24.0,
          'color': Colors.black.value.toString(),
        });
      case 'ListTile':
        return WidgetNode(type: 'ListTile', properties: {
          'title': WidgetNode(type: 'Text', properties: {'text': 'List Tile'}),
          'subtitle': WidgetNode(type: 'Text', properties: {'text': 'Subtitle'}),
          'leading': WidgetNode(type: 'Icon', properties: {'icon': 'info'}),
          'trailing': WidgetNode(type: 'Icon', properties: {'icon': 'arrow_forward'}),
        });
      case 'SlidableListTile':
        return WidgetNode(type: 'SlidableListTile', properties: {
          'title': 'Slidable List Tile',
          'subtitle': '',
        });
      case 'FAB':
        return WidgetNode(type: 'FloatingActionButton', properties: {
          'icon': WidgetNode(type: 'Icon', properties: {'icon': 'add'}),
          'backgroundColor': Colors.blue.value.toString(),
        });
      case 'Drawer':
        return WidgetNode(type: 'Drawer', properties: {
          'elevation': 16.0,
          'child': WidgetNode(type: 'ListView', children: [
            WidgetNode(type: 'ListTile', properties: {'title': WidgetNode(type: 'Text', properties: {'text': 'Drawer Item 1'})}),
            WidgetNode(type: 'ListTile', properties: {'title': WidgetNode(type: 'Text', properties: {'text': 'Drawer Item 2'})}),
          ]),
        });
      case 'EndDrawer':
        return WidgetNode(type: 'EndDrawer', properties: {
          'elevation': 16.0,
        });
      case 'DropDown':
        return WidgetNode(type: 'DropDown', properties: {
          'hint': 'Select an option',
          'items': [],
        });
      case 'Checkbox':
        return WidgetNode(type: 'Checkbox', properties: {
          'value': false,
          'label': 'Checkbox',
        });
      case 'CheckboxListTile':
        return WidgetNode(type: 'CheckboxListTile', properties: {
          'title': 'Checkbox List Tile',
          'value': false,
        });
      case 'Switch':
        return WidgetNode(type: 'Switch', properties: {
          'value': false,
          'label': 'Switch',
        });
      case 'SwitchListTile':
        return WidgetNode(type: 'SwitchListTile', properties: {
          'title': 'Switch List Tile',
          'value': false,
        });
      case 'RadioButton':
        return WidgetNode(type: 'RadioButton', properties: {
          'value': false,
          'label': 'Radio Button',
        });
      case 'PinCode':
        return WidgetNode(type: 'PinCode', properties: {
          'length': 4,
          'obscureText': true,
        });
      case 'Slider':
        return WidgetNode(type: 'Slider', properties: {
          'value': 0.0,
          'min': 0.0,
          'max': 1.0,
        });
      case 'Card':
        return WidgetNode(type: 'Card', properties: {
          'elevation': 4.0,
          'margin': 8.0,
          'color': Colors.white.value.toString(),
        });
      case 'BottomNavigationBar':
        return WidgetNode(type: 'BottomNavigationBar', properties: {
          'items': [
            WidgetNode(type: 'BottomNavigationBarItem', properties: {'icon': WidgetNode(type: 'Icon', properties: {'icon': 'home'}), 'label': 'Home'}),
            WidgetNode(type: 'BottomNavigationBarItem', properties: {'icon': WidgetNode(type: 'Icon', properties: {'icon': 'shopping_cart'}), 'label': 'Cart'}),
            WidgetNode(type: 'BottomNavigationBarItem', properties: {'icon': WidgetNode(type: 'Icon', properties: {'icon': 'person'}), 'label': 'Profile'}),
          ],
        });
      case 'Scaffold':
        return WidgetNode(type: 'Scaffold', properties: {
          'appBar': WidgetNode(type: 'AppBar', properties: {'title': WidgetNode(type: 'Text', properties: {'text': 'App Bar'})}),
          'body': WidgetNode(type: 'Container', properties: {'color': Colors.white.value.toString(), 'height': 200.0, 'width': 200.0}),
        });
      case 'SingleChildScrollView':
        return WidgetNode(type: 'SingleChildScrollView', properties: {
          'scrollDirection': 'vertical',
          'padding': 0.0,
        });
      case 'Stack':
        return WidgetNode(type: 'Stack', properties: {
          'alignment': 'topLeft',
          'fit': 'loose',
        });
      case 'Positioned':
        return WidgetNode(type: 'Positioned', properties: {
          'left': 0.0,
          'top': 0.0,
          'right': 0.0,
          'bottom': 0.0,
        });
      default:
        return WidgetNode(type: type);
    }
  }

  @override
  State<WidgetTreeEditor> createState() => _WidgetTreeEditorState();
}

class _WidgetTreeEditorState extends State<WidgetTreeEditor> {
  String _search = '';
  final Map<WidgetNode, bool> _expanded = {};
  
  @override
  void initState() {
    super.initState();
    // Initialize expansion state for the root nodes to be expanded by default
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
      if (provider.rootNode != null) {
        _initializeExpansionState(provider.rootNode!);
      }
    });
  }
  
  void _initializeExpansionState(WidgetNode node) {
    // Expand the first few levels by default
    _expanded[node] = true;
    
    // Recursively expand children up to depth 3
    void expandChildren(WidgetNode parent, int depth) {
      if (depth < 3) {
        for (var child in parent.children) {
          _expanded[child] = true;
          expandChildren(child, depth + 1);
        }
      }
    }
    
    expandChildren(node, 0);
    setState(() {});
  }
  
  @override
  void didUpdateWidget(WidgetTreeEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the root node changes, reinitialize expansion state
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    final currentRootNode = provider.rootNode;
    if (currentRootNode != null) {
      _expanded.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeExpansionState(currentRootNode);
      });
    }
  }

  // This map defines which properties of a widget type should be treated as nested widgets
  // and displayed in the widget tree.
  static const Map<String, List<String>> _widgetPropertiesToDisplay = {
    'Scaffold': ['appBar', 'floatingActionButton', 'drawer', 'endDrawer', 'bottomNavigationBar'],
    'AppBar': ['leading', 'title', 'actions'],
    'FloatingActionButton': ['child'],
    'Card': ['child'],
    'Drawer': ['child'],
    'ListTile': ['leading', 'title', 'subtitle', 'trailing'],
    'IconButton': ['icon'],
    'Chip': ['label', 'avatar', 'deleteIcon'],
    'CircleAvatar': ['child'],
    'BottomNavigationBar': ['items'],
    'BottomNavigationBarItem': ['icon'],
    'Container': ['child'],
    'Center': ['child'],
    'Padding': ['child'],
    'Expanded': ['child'],
    'Flexible': ['child'],
    'SizedBox': ['child'],
    'SingleChildScrollView': ['child'],
    'TextField': ['prefixIcon', 'suffixIcon'],
    'ElevatedButton': ['child'],
    'TextButton': ['child'],
    'OutlinedButton': ['child'],
    'InkWell': ['child'],
    'GestureDetector': ['child'],
    'Positioned': ['child'],
    'Align': ['child'],
    // Add other widget types and their properties that hold nested widgets
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text('Widget Tree', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add New Screen',
                  onPressed: () {
                    final newScreen = WidgetNode(
                      type: 'Scaffold',
                      properties: {'className': 'NewScreen'},
                      children: [
                        WidgetNode(
                          type: 'AppBar',
                          properties: {'title': 'App Bar'},
                          children: [],
                        ),
                        WidgetNode(
                          type: 'Column',
                          properties: {},
                          children: [],
                        ),
                      ],
                    );
                    Provider.of<WidgetTreeProvider>(context, listen: false).addScreen(newScreen);
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search for widget...',
                prefixIcon: Icon(Icons.search),
                isDense: true,
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _search = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: Consumer<WidgetTreeProvider>(
              builder: (context, provider, child) {
                if (provider.screens.isEmpty) {
                  // Always show a Scaffold as the root node if no screens
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    provider.setRootNode(WidgetNode(type: 'Scaffold', properties: {'className': 'MyScreen'}, children: []));
                  });
                  return const SizedBox.shrink();
                }
                // Show all screens at the top level
                return ListView(
                  children: [
                    for (final screen in provider.screens)
                      WidgetTreeNode(
                        node: screen,
                        selectedNode: provider.selectedNode,
                        onSelect: provider.selectNode,
                        onAdd: (parent) => _showAddWidgetDialog(context, parent),
                        onDelete: (node) {
                          // Prevent deleting the last screen
                          if (provider.screens.length > 1) {
                            provider.removeScreen(node);
                          }
                        },
                        expanded: _expanded,
                        search: _search,
                        depth: 0, 
                        onDuplicate: (WidgetNode node) {
                          final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
                          final duplicatedNode = _duplicateNode(node);
                          // Find parent and add the duplicated node
                          final parent = _findParentInScreens(provider.screens, node);
                          if (parent != null) {
                            provider.addChild(parent, duplicatedNode);
                            provider.selectNode(duplicatedNode);
                          }
                        },
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddWidgetDialog(BuildContext context, WidgetNode parent) async {
    final categories = [
      {
        'name': 'Commonly Used Elements',
        'widgets': [
          {'type': 'Text', 'icon': Icons.text_fields},
          {'type': 'Column', 'icon': Icons.view_agenda},
          {'type': 'Row', 'icon': Icons.view_column},
          {'type': 'Container', 'icon': Icons.crop_square},
          {'type': 'Image', 'icon': Icons.image},
          {'type': 'Button', 'icon': Icons.smart_button},
        ],
      },
      {
        'name': 'Layout Elements',
        'widgets': [
          {'type': 'Row', 'icon': Icons.view_column},
          {'type': 'Column', 'icon': Icons.view_agenda},
          {'type': 'Container', 'icon': Icons.crop_square},
          {'type': 'ListView', 'icon': Icons.list},
          {'type': 'GridView', 'icon': Icons.grid_on},
          {'type': 'ExpansionTile', 'icon': Icons.expand_more},
        ],
      },
      {
        'name': 'Base Elements',
        'widgets': [
          {'type': 'Text', 'icon': Icons.text_fields},
          {'type': 'RichText', 'icon': Icons.description},
          {'type': 'Image', 'icon': Icons.image},
          {'type': 'CircleImage', 'icon': Icons.account_circle},
          {'type': 'Icon', 'icon': Icons.settings},
          {'type': 'Button', 'icon': Icons.smart_button},
          {'type': 'IconButton', 'icon': Icons.add_circle_outline},
          {'type': 'ListTile', 'icon': Icons.list_alt},
          {'type': 'SlidableListTile', 'icon': Icons.swipe},
        ],
      },
      {
        'name': 'Page Elements',
        'widgets': [
          {'type': 'AppBar', 'icon': Icons.space_bar},
          {'type': 'FAB', 'icon': Icons.add_circle},
          {'type': 'Drawer', 'icon': Icons.menu},
          {'type': 'EndDrawer', 'icon': Icons.menu_open},
        ],
      },
      {
        'name': 'Form Elements',
        'widgets': [
          {'type': 'TextField', 'icon': Icons.edit},
          {'type': 'DropDown', 'icon': Icons.arrow_drop_down_circle},
          {'type': 'Checkbox', 'icon': Icons.check_box},
          {'type': 'CheckboxListTile', 'icon': Icons.checklist},
          {'type': 'Switch', 'icon': Icons.toggle_on},
          {'type': 'SwitchListTile', 'icon': Icons.toggle_off},
          {'type': 'RadioButton', 'icon': Icons.radio_button_checked},
          {'type': 'PinCode', 'icon': Icons.password},
          {'type': 'Slider', 'icon': Icons.tune},
          {'type': 'RatingBar', 'icon': Icons.star},
          {'type': 'CreditCardForm', 'icon': Icons.credit_card},
          {'type': 'CounterButton', 'icon': Icons.exposure_plus_2},
          {'type': 'ChoiceChips', 'icon': Icons.check_box_outline_blank},
          {'type': 'PlacePicker', 'icon': Icons.place},
          {'type': 'FormValidation', 'icon': Icons.verified_user},
          {'type': 'CheckboxGroup', 'icon': Icons.checklist_rtl},
          {'type': 'Signature', 'icon': Icons.edit_attributes},
        ],
      },
    ];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Widget'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final category in categories)
                    ExpansionTile(
                      title: Text(category['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final widgetInfo in category['widgets'] as List<Map<String, dynamic>>)
                              ElevatedButton.icon(
                                icon: Icon(widgetInfo['icon'] as IconData),
                                label: Text(widgetInfo['type'] as String),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade200,
                                  foregroundColor: Colors.black87,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                onPressed: () {
                                  final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
                                  final newNode = WidgetTreeEditor.createWidgetNodeWithDefaults(widgetInfo['type'] as String);
                                  provider.addChild(parent, newNode);
                                  Navigator.of(context).pop();
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper to extract widget nodes from properties
  List<WidgetNode> _extractWidgetNodesFromProperties(WidgetNode node) {
    final List<WidgetNode> extractedNodes = [];
    final List<String>? propertiesToDisplay = _widgetPropertiesToDisplay[node.type];

    if (propertiesToDisplay != null) {
      for (final propName in propertiesToDisplay) {
        final dynamic propValue = node.properties[propName];
        if (propValue is WidgetNode) {
          // Create a wrapper node to show property name in the tree
          extractedNodes.add(WidgetNode(
            id: '${node.id}_prop_$propName', // Unique ID for property node
            type: '${propName[0].toUpperCase()}${propName.substring(1)}: ${propValue.type}', // e.g., AppBar: AppBar
            children: [propValue], // The actual widget node is a child of this wrapper
            properties: {},
          ));
        } else if (propValue is List<dynamic>) {
          for (int i = 0; i < propValue.length; i++) {
            final item = propValue[i];
            if (item is WidgetNode) {
              extractedNodes.add(WidgetNode(
                id: '${node.id}_prop_${propName}_$i', // Unique ID for list item property node
                type: '${propName[0].toUpperCase()}${propName.substring(1)}[$i]: ${item.type}', // e.g., Actions[0]: IconButton
                children: [item],
                properties: {},
              ));
            }
          }
        }
      }
    }
    return extractedNodes;
  }

  Widget _buildTreeNode(
    WidgetNode node,
    WidgetNode? selectedNode,
    void Function(WidgetNode) onSelect,
    void Function(WidgetNode parent) onAdd,
    void Function(WidgetNode) onDelete,
    void Function(WidgetNode) onDuplicate,
    Map<WidgetNode, bool> expanded,
    String search,
    int depth,
  ) {
    // Combine direct children and extracted property nodes
    final List<WidgetNode> combinedChildren = [...node.children, ..._extractWidgetNodesFromProperties(node)];
    print('Node: ${node.type}, ID: ${node.id}, Combined Children Count: ${combinedChildren.length}');
    for (var child in combinedChildren) {
      print('  Combined Child: ${child.type}, ID: ${child.id}');
    }

    // Create a new WidgetNode for display in the tree that includes properties as children
    final displayNode = WidgetNode(
      id: node.id,
      type: node.type,
      properties: node.properties,
      children: combinedChildren, // This is the key: pass combined children to the new node
    );
    print('Display Node: ${displayNode.type}, ID: ${displayNode.id}, Children Count: ${displayNode.children.length}');

    return WidgetTreeNode(
      node: displayNode, // Use the displayNode here
      selectedNode: selectedNode,
      onSelect: onSelect,
      onAdd: onAdd,
      onDelete: onDelete,
      onDuplicate: onDuplicate,
      expanded: expanded,
      search: search,
      depth: depth,
    );
  }

  WidgetNode? _findParent(WidgetNode root, WidgetNode target) {
    if (root.children.contains(target)) {
      return root;
    }
    for (var child in root.children) {
      final parent = _findParent(child, target);
      if (parent != null) {
        return parent;
      }
    }
    return null;
  }

  // Helper method to find parent across all screens
  WidgetNode? _findParentInScreens(List<WidgetNode> screens, WidgetNode target) {
    for (var screen in screens) {
      if (screen == target) {
        return null; // Target is a screen itself
      }
      final parent = _findParent(screen, target);
      if (parent != null) {
        return parent;
      }
    }
    return null;
  }

  // Helper method to duplicate a node with all its children
  WidgetNode _duplicateNode(WidgetNode original) {
    return WidgetNode(
      type: original.type,
      properties: Map<String, dynamic>.from(original.properties),
      children: original.children.map((child) => _duplicateNode(child)).toList(),
    );
  }
}