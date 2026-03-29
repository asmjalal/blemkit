import 'package:flutter/material.dart';

class WidgetPalette extends StatelessWidget {
  final void Function(String type)? onWidgetAdd;
  const WidgetPalette({super.key, this.onWidgetAdd});

  @override
  Widget build(BuildContext context) {
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
                            data: widgetInfo['type'] as String,
                            feedback: Material(
                              color: Colors.transparent,
                              child: Opacity(
                                opacity: 0.7,
                                child: _PaletteTile(
                                  icon: widgetInfo['icon'] as IconData,
                                  label: widgetInfo['type'] as String,
                                  onTap: onWidgetAdd == null ? null : () => onWidgetAdd!(widgetInfo['type'] as String),
                                ),
                              ),
                            ),
                            child: _PaletteTile(
                              icon: widgetInfo['icon'] as IconData,
                              label: widgetInfo['type'] as String,
                              onTap: onWidgetAdd == null ? null : () => onWidgetAdd!(widgetInfo['type'] as String),
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
  }
}

class _PaletteTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _PaletteTile({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade800, width: 1.2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade900,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 25, color: Colors.white70),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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