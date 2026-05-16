import 'package:provider/provider.dart';
import '../providers/widget_tree_provider.dart';
import 'package:flutter/material.dart';

class WidgetPalette extends StatelessWidget {
  final void Function(String type)? onWidgetAdd;
  final void Function(String type, Map<String, dynamic> themedWidget)? onThemedWidgetAdd;

  const WidgetPalette({super.key, this.onWidgetAdd, this.onThemedWidgetAdd});

  @override
  Widget build(BuildContext context) {
    return Consumer<WidgetTreeProvider>(
      builder: (context, provider, child) {
        final themedWidgets = provider.themedWidgets;
        
        final categories = [
          if (themedWidgets.isNotEmpty)
            {
              'name': 'Theme Widgets',
              'widgets': themedWidgets.map((w) => {
                'type': 'ThemedWidget',
                'id': w['id'],
                'label': w['name'],
                'icon': _getIconForType(w['type']),
                'data': w,
              }).toList(),
            },
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

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Widget Palette', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView(
                children: categories.map((category) {
                  return ExpansionTile(
                    initiallyExpanded: category['name'] == 'Theme Widgets',
                    title: Text(
                      category['name'] as String,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        child: GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1,
                          children: [
                            for (final widgetInfo in category['widgets'] as List<Map<String, dynamic>>)
                              Draggable<String>(
                                data: widgetInfo['type'] == 'ThemedWidget' 
                                    ? 'ThemedWidget:${widgetInfo['id']}' 
                                    : widgetInfo['type'] as String,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: Opacity(
                                    opacity: 0.7,
                                    child: _PaletteTile(
                                      icon: widgetInfo['icon'] as IconData,
                                      label: widgetInfo['label'] ?? widgetInfo['type'] as String,
                                      isThemed: widgetInfo['type'] == 'ThemedWidget',
                                    ),
                                  ),
                                ),
                                child: _PaletteTile(
                                  icon: widgetInfo['icon'] as IconData,
                                  label: widgetInfo['label'] ?? widgetInfo['type'] as String,
                                  isThemed: widgetInfo['type'] == 'ThemedWidget',
                                  onTap: () {
                                    if (widgetInfo['type'] == 'ThemedWidget') {
                                      if (onThemedWidgetAdd != null) onThemedWidgetAdd!(widgetInfo['id'], widgetInfo['data']);
                                    } else {
                                      if (onWidgetAdd != null) onWidgetAdd!(widgetInfo['type'] as String);
                                    }
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
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
}

class _PaletteTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isThemed;

  const _PaletteTile({required this.icon, required this.label, this.onTap, this.isThemed = false});

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(
          color: isThemed ? Colors.indigoAccent.withValues(alpha: 0.5) : Colors.grey.shade800, 
          width: isThemed ? 1.5 : 1.2
        ),
        borderRadius: BorderRadius.circular(10),
        color: isThemed ? Colors.indigo.withValues(alpha: 0.1) : Colors.grey.shade900,
      ),
      child: Stack(
        children: [
          if (isThemed)
            Positioned(
              top: 4,
              right: 4,
              child: Icon(Icons.auto_awesome, size: 8, color: Colors.indigoAccent),
            ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 22, color: isThemed ? Colors.indigoAccent : Colors.white70),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 8, 
                    color: isThemed ? Colors.white : Colors.white70, 
                    fontWeight: isThemed ? FontWeight.bold : FontWeight.w500
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: tile,
      );
    }
    return tile;
  }
}
 