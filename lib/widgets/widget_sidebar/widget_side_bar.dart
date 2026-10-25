import 'package:designflutterkit/widgets/widget_sidebar/premium_searchbar.dart';
import 'package:designflutterkit/widgets/widget_sidebar/recently_used_section.dart';
import 'package:designflutterkit/widgets/widget_sidebar/sidebar_tabbar.dart';
import 'package:designflutterkit/widgets/widget_sidebar/widget_category_section.dart';
import 'package:flutter/material.dart';
import 'palette_browser.dart';
import '../../ui/editor_widgets.dart';
import '../../models/project_logic.dart';
import '../../ui/editor_theme.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/widget_node.dart';
import '../../providers/widget_tree_provider.dart';
import '../widget_tree/widget_tree_editor.dart';
import 'collapse_widget_tree.dart';
import '../theme_editor_panel.dart';
import '../data_source_panel.dart';
import '../../screens/profile_screen.dart';
import '../../screens/login_screen.dart';

class WidgetSidebar extends StatefulWidget {
  final int selectedTab;
  final ValueChanged<int> onTabSelected;
  final void Function(String type)? onWidgetAdd;
  const WidgetSidebar({super.key, required this.selectedTab, required this.onTabSelected, this.onWidgetAdd});

  /// Built-in palette, grouped by category. Each entry needs a canvas builder,
  /// a generator and defaults (see test/generators/palette_widgets_test.dart).
  static const List<Map<String, dynamic>> paletteCategories = [
    {
      'name': 'Layout Elements',
      'widgets': [
        {'type': 'Row', 'icon': Icons.view_column},
        {'type': 'Column', 'icon': Icons.view_agenda},
        {'type': 'Container', 'icon': Icons.crop_square},
        {'type': 'ListView', 'icon': Icons.list},
        {'type': 'GridView', 'icon': Icons.grid_on},
        {'type': 'ExpansionTile', 'icon': Icons.expand_more},
        {'type': 'Stack', 'icon': Icons.layers},
        {'type': 'Card', 'icon': Icons.credit_card},
        {'type': 'Divider', 'icon': Icons.horizontal_rule},
        {'type': 'VerticalDivider', 'icon': Icons.vertical_align_center},
        {'type': 'TabBar', 'icon': Icons.tab},
        {'type': 'PageView', 'icon': Icons.view_carousel},
        {'type': 'Carousel', 'icon': Icons.view_carousel},
        {'type': 'Expandable', 'icon': Icons.expand},
        {'type': 'Wrap', 'icon': Icons.wrap_text},
        {'type': 'DataTable', 'icon': Icons.table_chart},
        {'type': 'Flex', 'icon': Icons.line_weight},
        {'type': 'SizedBox', 'icon': Icons.space_bar},
        {'type': 'Padding', 'icon': Icons.padding},
        {'type': 'Center', 'icon': Icons.center_focus_strong},
        {'type': 'Align', 'icon': Icons.align_horizontal_center},
        {'type': 'Spacer', 'icon': Icons.space_dashboard},
        {'type': 'Expanded', 'icon': Icons.open_in_full},
        {'type': 'Flexible', 'icon': Icons.fit_screen},
        {'type': 'SingleChildScrollView', 'icon': Icons.swap_vert},
        {'type': 'SafeArea', 'icon': Icons.security},
        {'type': 'Positioned', 'icon': Icons.place},
        {'type': 'AspectRatio', 'icon': Icons.aspect_ratio},
        {'type': 'ConstrainedBox', 'icon': Icons.crop_free},
        {'type': 'IntrinsicHeight', 'icon': Icons.height},
        {'type': 'IntrinsicWidth', 'icon': Icons.width_full},
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
        {'type': 'SelectableText', 'icon': Icons.text_snippet},
        {'type': 'SvgImage', 'icon': Icons.image_search},
        {'type': 'NetworkImage', 'icon': Icons.cloud_download},
        {'type': 'Avatar', 'icon': Icons.account_circle},
        {'type': 'Badge', 'icon': Icons.badge},
        {'type': 'Chip', 'icon': Icons.label},
        {'type': 'Tooltip', 'icon': Icons.info},
      ],
    },
    {
      'name': 'Page Elements',
      'widgets': [
        {'type': 'AppBar', 'icon': Icons.space_bar},
        {'type': 'FAB', 'icon': Icons.add_circle},
        {'type': 'Drawer', 'icon': Icons.menu},
        {'type': 'EndDrawer', 'icon': Icons.menu_open},
        {'type': 'BottomNavigationBar', 'icon': Icons.navigation},
        {'type': 'NavigationRail', 'icon': Icons.view_sidebar},
        {'type': 'BottomSheet', 'icon': Icons.keyboard_arrow_up},
        {'type': 'TabBarView', 'icon': Icons.tab},
        {'type': 'Scaffold', 'icon': Icons.dashboard},
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
        {'type': 'DatePicker', 'icon': Icons.calendar_today},
        {'type': 'TimePicker', 'icon': Icons.access_time},
        {'type': 'RangeSlider', 'icon': Icons.tune},
        {'type': 'SearchField', 'icon': Icons.search},
        {'type': 'AutoComplete', 'icon': Icons.auto_fix_high},
        {'type': 'ToggleButtons', 'icon': Icons.toggle_on},
        {'type': 'SegmentedButton', 'icon': Icons.view_week},
      ],
    },
    {
      'name': 'Feedback & State',
      'widgets': [
        {'type': 'CircularProgressIndicator', 'icon': Icons.refresh},
        {'type': 'LinearProgressIndicator', 'icon': Icons.trending_flat},
        {'type': 'SnackBar', 'icon': Icons.message},
        {'type': 'Dialog', 'icon': Icons.chat},
        {'type': 'AlertDialog', 'icon': Icons.warning},
        {'type': 'LoadingOverlay', 'icon': Icons.hourglass_empty},
      ]
    },
    {
      'name': 'Animation',
      'widgets': [
        {'type': 'AnimatedContainer', 'icon': Icons.animation},
        {'type': 'Hero', 'icon': Icons.flight},
        {'type': 'AnimatedOpacity', 'icon': Icons.opacity},
        {'type': 'AnimatedSwitcher', 'icon': Icons.swap_horiz},
        {'type': 'FadeTransition', 'icon': Icons.blur_on},
      ]
    },
  ];

  static List<String> get paletteTypes => [
        for (final category in paletteCategories)
          for (final widget in category['widgets'] as List) widget['type'] as String,
      ];

  @override
  State<WidgetSidebar> createState() => _WidgetSidebarState();
}

class _WidgetSidebarState extends State<WidgetSidebar> {
  int selectedCategory = 0;
  String search = '';
  final List<String> _recent = ['Text', 'Container', 'Column', 'Row', 'Image', 'ElevatedButton'];
  List<Map<String, dynamic>> recentlyUsed = [
    {'icon': Icons.text_fields, 'label': 'Text'},
    {'icon': Icons.crop_square, 'label': 'Container'},
    {'icon': Icons.view_column, 'label': 'Row'},
    {'icon': Icons.view_agenda, 'label': 'Column'},
    {'icon': Icons.image, 'label': 'Image'},
    {'icon': Icons.smart_button, 'label': 'Button'},
  ];
  final Map<WidgetNode, bool> _expanded = {};

  List<Map<String, dynamic>> _getDynamicCategories(BuildContext context, {bool listen = true}) {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: listen);
    final themedWidgets = provider.themedWidgets;

    return [
      if (themedWidgets.isNotEmpty)
        {
          'name': 'Theme Widgets',
          'widgets': themedWidgets.map((w) => {
            'type': 'ThemedWidget:${w['id']}',
            'label': w['name'],
            'icon': _getIconForType(w['type']),
            'data': w,
          }).toList(),
        },
      if (provider.components.isNotEmpty)
        {
          'name': 'Components',
          'widgets': [
            for (final c in provider.components)
              {'type': 'Component:${c.id}', 'label': PageLogic.componentName(c.properties) ?? 'Component', 'icon': Icons.extension_outlined},
          ],
        },
      if (provider.logic.customCode.any((c) => c.kind == 'widget'))
        {
          'name': 'Custom Code',
          'widgets': [
            for (final c in provider.logic.customCode.where((c) => c.kind == 'widget'))
              {'type': 'CustomWidget:${c.name}', 'label': c.name, 'icon': Icons.code_rounded},
          ],
        },
      ...WidgetSidebar.paletteCategories,
    ];
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Container': return Icons.crop_square;
      case 'Card': return Icons.credit_card;
      case 'Text': return Icons.text_fields;
      case 'Button': return Icons.smart_button;
      case 'TextField': return Icons.edit;
      case 'Switch': return Icons.toggle_on;
      case 'Checkbox': return Icons.check_box;
      default: return Icons.widgets;
    }
  }

  void _addWidget(BuildContext context, String type, {WidgetNode? parent}) {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    final newNode = WidgetTreeEditor.createFromPaletteType(type);

    if (parent != null) {
      provider.addChild(parent, newNode);
    } else if (provider.selectedNode != null) {
      provider.addChild(provider.selectedNode!, newNode);
    } else if (provider.rootNode == null) {
      provider.setRootNode(newNode);
    } else {
      provider.addChild(provider.rootNode!, newNode);
    }
    
    setState(() {
      _recent.remove(type);
      _recent.insert(0, type);
      if (_recent.length > 6) _recent.removeLast();
    });
  }

  void _showAddWidgetDialog(BuildContext context, WidgetNode parent) async {
    final cats = _getDynamicCategories(context, listen: false);
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
          primary: Color(0xFF0fadd5),
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
    final user = FirebaseAuth.instance.currentUser;
    return Container(
      decoration: const BoxDecoration(color: EditorColors.surface),
      child: Column(
        children: [
          SidebarTabBar(
            selectedTab: widget.selectedTab,
            onTabSelected: widget.onTabSelected,
            isCollapsed: false,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 0),
              child: _buildContent(),
            ),
          ),
          // ── Bottom user footer ──────────────────────────────────────
          Container(
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: EditorColors.border))),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: user == null
                ? InkWell(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.login_rounded, color: EditorColors.accent, size: 18),
                          const SizedBox(width: 10),
                          const Text('Sign in to save to the cloud', style: TextStyle(color: EditorColors.textMuted, fontSize: 12.5, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Icon(Icons.chevron_right, color: Colors.white.withValues(alpha: 0.3), size: 16),
                        ],
                      ),
                    ),
                  )
                : Row(
                    children: [
                      // Avatar
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ProfileScreen()),
                          );
                        },
                        child: Tooltip(
                          message: 'View Profile',
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: user.photoURL != null
                                ? NetworkImage(user.photoURL!)
                                : null,
                            backgroundColor: const Color(0xFF0fadd5),
                            child: user.photoURL == null || user.photoURL!.isEmpty
                                ? Text(
                                    (user.displayName?.isNotEmpty == true
                                            ? user.displayName![0]
                                            : user.email?[0] ?? 'U')
                                        .toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Name + email
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProfileScreen()),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                user.displayName ?? 'User',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                user.email ?? '',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4),
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Sign-out icon
                      Tooltip(
                        message: 'Sign Out',
                        child: IconButton(
                          icon: const Icon(Icons.logout_rounded,
                              color: Colors.white38, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _confirmSignOut(context),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign Out',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildContent() {
    if (widget.selectedTab == 0) {
      return PaletteBrowser(
        categories: _getDynamicCategories(context),
        recent: _recent,
        onAdd: (type) => _addWidget(context, type),
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
      return _buildPagesTab();
    } else if (widget.selectedTab == 3) {
      return const ThemeEditorPanel();
    } else if (widget.selectedTab == 4) {
      return const DataSourcePanel();
    }
    return const SizedBox.shrink();
  }

  Widget _buildPagesTab() {
    final provider = Provider.of<WidgetTreeProvider>(context);

    Widget header(String title, String tooltip, VoidCallback onAdd) => Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 6),
          child: Row(children: [
            Expanded(child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: EditorColors.textFaint))),
            EditorIconButton(icon: Icons.add_rounded, tooltip: tooltip, size: 17, onPressed: onAdd),
          ]),
        );

    Widget row(WidgetNode node, {required bool isComponent}) {
      final selected = provider.selectedScreen?.id == node.id;
      final name = isComponent ? (PageLogic.componentName(node.properties) ?? 'Component') : '${node.properties['pageName'] ?? 'Page'}';
      final badges = <Widget>[
        if (!isComponent && provider.logic.homePageId == node.id) const Icon(Icons.home_rounded, size: 13, color: EditorColors.accent),
        if (!isComponent && provider.logic.loginPageId == node.id) const Icon(Icons.lock_outline_rounded, size: 13, color: EditorColors.warning),
      ];
      return EditorListTile(
        icon: isComponent ? Icons.extension_outlined : Icons.web_asset_rounded,
        iconColor: isComponent ? EditorColors.violet : null,
        title: name,
        subtitle: isComponent ? '${PageLogic.pageParams(node.properties).length} parameters' : null,
        selected: selected,
        onTap: () => provider.selectScreen(node),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          ...badges,
          PopupMenuButton<String>(
            tooltip: 'More',
            icon: const Icon(Icons.more_horiz_rounded, size: 16, color: EditorColors.textFaint),
            onSelected: (v) {
              switch (v) {
                case 'rename':
                  isComponent ? _renameComponent(context, node) : _showRenameDialog(context, node);
                  break;
                case 'duplicate':
                  provider.duplicateScreen(node);
                  break;
                case 'home':
                  provider.updateLogic((l) => l.homePageId = node.id);
                  break;
                case 'delete':
                  isComponent ? provider.removeComponent(node) : provider.removeScreen(node);
                  break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'rename', height: 36, child: Text('Rename')),
              if (!isComponent) const PopupMenuItem(value: 'duplicate', height: 36, child: Text('Duplicate')),
              if (!isComponent) const PopupMenuItem(value: 'home', height: 36, child: Text('Set as home page')),
              if (isComponent || provider.screens.length > 1)
                const PopupMenuItem(value: 'delete', height: 36, child: Text('Delete', style: TextStyle(color: EditorColors.danger))),
            ],
          ),
        ]),
      );
    }

    return ListView(
      children: [
        header('Pages', 'Add page', () {
          final newPage = WidgetTreeEditor.createWidgetNodeWithDefaults('Scaffold');
          newPage.properties['pageName'] = 'Page ${provider.screens.length + 1}';
          provider.addScreen(newPage);
        }),
        for (final screen in provider.screens) row(screen, isComponent: false),
        const SizedBox(height: 14),
        header('Components', 'New component', () {
          final component = provider.addComponent('Component ${provider.components.length + 1}');
          provider.selectScreen(component);
        }),
        if (provider.components.isEmpty)
          const Padding(
            padding: EdgeInsets.fromLTRB(4, 0, 4, 8),
            child: Text('Reusable blocks with parameters, like a ProductCard. Edit once, every instance updates.',
                style: TextStyle(fontSize: 11.5, height: 1.4, color: EditorColors.textFaint)),
          ),
        for (final component in provider.components) row(component, isComponent: true),
      ],
    );
  }

  Future<void> _renameComponent(BuildContext context, WidgetNode component) async {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    final controller = TextEditingController(text: PageLogic.componentName(component.properties) ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Rename component'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, controller.text.trim()), child: const Text('Rename')),
        ],
      ),
    );
    if (name != null && name.isNotEmpty) provider.setNodeProperty(component, 'componentName', name);
  }


  void _showRenameDialog(BuildContext context, WidgetNode screen) {
    final controller = TextEditingController(text: screen.properties['pageName'] as String? ?? 'Page');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('Rename Page', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter page name',
              hintStyle: TextStyle(color: Colors.white38),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            TextButton(
              onPressed: () {
                Provider.of<WidgetTreeProvider>(context, listen: false).renameScreen(screen, controller.text);
                Navigator.pop(context);
              },
              child: const Text('Rename', style: TextStyle(color: Color(0xFF0fadd5))),
            ),
          ],
        );
      },
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
  final int index;
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
    required this.index,
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
            index: index,
            child: Container(
              margin: const EdgeInsets.only(bottom: 2),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0fadd5).withOpacity(0.15) : (isHovered ? Colors.white.withOpacity(0.05) : null),
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
                  Icon(_iconForType(node.type), color: isSelected ? const Color(0xFF0fadd5) : Colors.white54, size: 14),
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
                  index: i,
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