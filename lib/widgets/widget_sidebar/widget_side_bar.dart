import 'package:designflutterkit/widgets/widget_sidebar/premium_searchbar.dart';
import 'package:designflutterkit/widgets/widget_sidebar/recently_used_section.dart';
import 'package:designflutterkit/widgets/widget_sidebar/sidebar_tabbar.dart';
import 'package:designflutterkit/widgets/widget_sidebar/widget_category_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/widget_node.dart';
import '../../providers/widget_tree_provider.dart';
import '../widget_tree/widget_tree_editor.dart';
import 'collapse_widget_tree.dart';
import '../theme_editor_panel.dart';
import '../data_source_panel.dart';

class WidgetSidebar extends StatefulWidget {
  final int selectedTab;
  final ValueChanged<int> onTabSelected;
  final void Function(String type)? onWidgetAdd;
  const WidgetSidebar({super.key, required this.selectedTab, required this.onTabSelected, this.onWidgetAdd});

  @override
  State<WidgetSidebar> createState() => _WidgetSidebarState();
}

class _WidgetSidebarState extends State<WidgetSidebar> {
  int selectedCategory = 0;
  String search = '';
  List<Map<String, dynamic>> recentlyUsed = [
    {'icon': Icons.text_fields, 'label': 'Text'},
    {'icon': Icons.crop_square, 'label': 'Container'},
    {'icon': Icons.view_column, 'label': 'Row'},
    {'icon': Icons.view_agenda, 'label': 'Column'},
    {'icon': Icons.image, 'label': 'Image'},
    {'icon': Icons.smart_button, 'label': 'Button'},
  ];
  final Map<WidgetNode, bool> _expanded = {};

  // Widget categories (copied from WidgetPalette)
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Layout',
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
      'name': 'Basic',
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
      'name': 'Material',
      'widgets': [
        {'type': 'AppBar', 'icon': Icons.space_bar},
        {'type': 'FAB', 'icon': Icons.add_circle},
        {'type': 'Drawer', 'icon': Icons.menu},
        {'type': 'EndDrawer', 'icon': Icons.menu_open},
      ],
    },
    {
      'name': 'Input',
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

  void _addWidget(BuildContext context, String type, {WidgetNode? parent}) {
    // Add to widget tree
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    final WidgetNode newNode = WidgetTreeEditor.createWidgetNodeWithDefaults(type);
    if (parent != null) {
      provider.addChild(parent, newNode);
    } else if (provider.selectedNode != null) {
      provider.addChild(provider.selectedNode!, newNode);
    } else if (provider.rootNode == null) {
      provider.setRootNode(newNode);
    } else {
      provider.addChild(provider.rootNode!, newNode);
    }
    // Update recently used
    setState(() {
      recentlyUsed.removeWhere((w) => w['label'] == type);
      final icon = _findIconForType(type);
      recentlyUsed.insert(0, {'icon': icon, 'label': type});
      if (recentlyUsed.length > 8) recentlyUsed = recentlyUsed.sublist(0, 8);
    });
  }

  IconData _findIconForType(String type) {
    for (final cat in categories) {
      for (final w in cat['widgets']) {
        if (w['type'] == type) return w['icon'];
      }
    }
    return Icons.widgets;
  }

  void _showAddWidgetDialog(BuildContext context, WidgetNode parent) async {
    final cats = categories;
    TextEditingController searchController = TextEditingController();
    ValueNotifier<String> searchValue = ValueNotifier('');
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF23263a),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Widget', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search widgets...',
                      hintStyle: TextStyle(color: Colors.white54),
                      prefixIcon: Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF181A20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    ),
                    onChanged: (val) => searchValue.value = val.trim().toLowerCase(),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: ValueListenableBuilder<String>(
                      valueListenable: searchValue,
                      builder: (context, search, _) {
                        return ListView(
                          shrinkWrap: true,
                          children: [
                            for (final category in cats)
                              _buildCategorySection(category, parent, search),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategorySection(Map<String, dynamic> category, WidgetNode parent, String search) {
    final widgets = (category['widgets'] as List<Map<String, dynamic>>)
        .where((w) => search.isEmpty || w['type'].toString().toLowerCase().contains(search))
        .toList();
    if (widgets.isEmpty) return const SizedBox.shrink();
    return Theme(
      data: ThemeData.dark().copyWith(
        dividerColor: Colors.white10,
        unselectedWidgetColor: Colors.white70,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6366f1),
          surface: Color(0xFF23263a),
        ),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        backgroundColor: const Color(0xFF23263a),
        collapsedBackgroundColor: const Color(0xFF23263a),
        title: Text(category['name'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 4, bottom: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final widgetInfo in widgets)
                  ElevatedButton.icon(
                    icon: Icon(widgetInfo['icon'] as IconData, color: Colors.white),
                    label: Text(widgetInfo['type'] as String, style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF181A20),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      _addWidget(context, widgetInfo['type'] as String, parent: parent);
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1e293b),
        border: Border(right: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        children: [
          SidebarTabBar(
            selectedTab: widget.selectedTab,
            onTabSelected: widget.onTabSelected,
            isCollapsed: false,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (widget.selectedTab == 0) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PremiumSearchBar(
              isCollapsed: false,
              onChanged: (val) => setState(() => search = val),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RecentlyUsedSection(recentlyUsed: recentlyUsed),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: WidgetCategoriesSection(
              categories: categories,
              selectedCategory: selectedCategory,
              onCategorySelected: (i) => setState(() => selectedCategory = i),
              search: search,
              onWidgetAdd: (type) => _addWidget(context, type),
            ),
          ),
        ],
      );
    } else if (widget.selectedTab == 1) {
      return CollapsibleWidgetTree(
        onAdd: (parent) => _showAddWidgetDialog(context, parent),
        expanded: _expanded,
        onExpandToggle: (node) {
          setState(() {
            _expanded[node] = !(_expanded[node] ?? true);
          });
        },
      );
    } else if (widget.selectedTab == 2) {
      return const ThemeEditorPanel();
    } else if (widget.selectedTab == 3) {
      return const DataSourcePanel();
    }
    return const SizedBox.shrink();
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isActive = widget.selectedTab == index;
    return InkWell(
      onTap: index >= 0 ? () => widget.onTabSelected(index) : null,
      child: Container(
        height: 48,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF171F33) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 24,
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF0066FF) : Colors.transparent,
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(3)),
              ),
            ),
            const SizedBox(width: 21),
            Icon(
              icon,
              size: 20,
              color: isActive ? const Color(0xFFADC7FF) : const Color(0xFF424656),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isActive ? const Color(0xFFADC7FF) : const Color(0xFF424656),
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SidebarWidgetTreeNode extends StatelessWidget {
  final WidgetNode node;
  final WidgetNode? selectedNode;
  final void Function(WidgetNode) onSelect;
  final void Function(WidgetNode parent) onAdd;
  final void Function(WidgetNode) onDelete;
  final int depth;
  final Map<WidgetNode, bool> expanded;
  final void Function(WidgetNode node)? onExpandToggle;
  final void Function(WidgetNode? node)? onHover;
  final String? customTitle;
  const SidebarWidgetTreeNode({
    super.key,
    required this.node,
    required this.selectedNode,
    required this.onSelect,
    required this.onAdd,
    required this.onDelete,
    required this.depth,
    required this.expanded,
    this.onExpandToggle,
    this.onHover,
    this.customTitle,
  });

  bool get isExpanded => expanded[node] ?? true;
  bool get hasChildren => node.children.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final isSelected = selectedNode == node;
    final hoveredNode = Provider.of<WidgetTreeProvider>(context).hoveredNode;
    final isHovered = hoveredNode != null && identical(node, hoveredNode);
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    final isScreen = node.type == 'Scaffold';
    final canDeleteScreen = isScreen && provider.screens.length > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MouseRegion(
          onEnter: (_) => onHover?.call(node),
          onExit: (_) => onHover?.call(null),
          child: ReorderableDelayedDragStartListener(
            index: depth, // Note: This index is a bit tricky in nested lists, but for the handle it's used locally
            child: Container(
              margin: const EdgeInsets.only(bottom: 2),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF6366f1).withOpacity(0.15) : (isHovered ? Colors.white.withOpacity(0.05) : null),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  // Vertical guide lines based on depth
                  for (int i = 0; i < depth; i++)
                    Container(
                      width: 1,
                      height: 24,
                      margin: const EdgeInsets.only(right: 15),
                      color: Colors.white.withOpacity(0.1),
                    ),
                  Icon(_iconForType(node.type), color: isSelected ? const Color(0xFF6366f1) : Colors.white54, size: 14),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onSelect(node),
                      child: Text(
                        customTitle ?? node.type,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (isSelected || isHovered)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, size: 14, color: Colors.white54),
                          onPressed: () => onAdd(node),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Add widget',
                        ),
                        const SizedBox(width: 8),
                        if ((isScreen && canDeleteScreen) || !isScreen)
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 14, color: Colors.redAccent),
                            onPressed: () => onDelete(node),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            tooltip: 'Delete widget',
                          ),
                      ],
                    ),
                  if (hasChildren)
                    GestureDetector(
                      onTap: () => onExpandToggle?.call(node),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Icon(
                          isExpanded ? Icons.arrow_drop_down : Icons.arrow_right,
                          size: 18,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (hasChildren && isExpanded)
          ReorderableListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            onReorder: (oldIndex, newIndex) {
              provider.reorderNode(node, oldIndex, newIndex > oldIndex ? newIndex - 1 : newIndex);
            },
            children: [
              for (int i = 0; i < node.children.length; i++)
                SidebarWidgetTreeNode(
                  key: ValueKey(node.children[i].id),
                  node: node.children[i],
                  selectedNode: selectedNode,
                  onSelect: onSelect,
                  onAdd: onAdd,
                  onDelete: onDelete,
                  depth: depth + 1,
                  expanded: expanded,
                  onExpandToggle: onExpandToggle,
                  onHover: onHover,
                ),
            ],
          ),
      ],
    );
  }

  void onAddWithMenu(BuildContext context, WidgetNode parent, String type) {
    final sidebarState = context.findAncestorStateOfType<_WidgetSidebarState>();
    if (sidebarState != null) {
      sidebarState._addWidget(context, type, parent: parent);
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'Container':
        return Icons.crop_square;
      case 'Row':
        return Icons.view_column;
      case 'Column':
        return Icons.view_agenda;
      case 'Text':
        return Icons.text_fields;
      case 'ElevatedButton':
        return Icons.smart_button;
      case 'TextField':
        return Icons.input;
      default:
        return Icons.widgets;
    }
  }
}