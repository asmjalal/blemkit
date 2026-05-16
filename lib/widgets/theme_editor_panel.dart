import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/widget_tree_provider.dart';
import '../utils/color_utils.dart';
import 'property_editors/color_picker_field.dart';

class ThemeEditorPanel extends StatelessWidget {
  const ThemeEditorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WidgetTreeProvider>(
      builder: (context, provider, child) {
        final theme = provider.themeProperties;

        return ListView(
          children: [
            const Text(
              'Global Theme',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Customize the look and feel of your entire app.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Colors'),
            const SizedBox(height: 12),
            ColorPickerField(
              label: 'Primary Color',
              color: ColorUtils.parseColor(theme['primaryColor'], Colors.indigo),
              onColorChanged: (color) {
                provider.updateThemeProperties({
                  'primaryColor': '0x${color.value.toRadixString(16).toUpperCase()}',
                });
              },
            ),
            const SizedBox(height: 16),
            ColorPickerField(
              label: 'Accent Color',
              color: ColorUtils.parseColor(theme['accentColor'], Colors.indigoAccent),
              onColorChanged: (color) {
                provider.updateThemeProperties({
                  'accentColor': '0x${color.value.toRadixString(16).toUpperCase()}',
                });
              },
            ),
            const SizedBox(height: 16),
            ColorPickerField(
              label: 'Background Color',
              color: ColorUtils.parseColor(theme['backgroundColor'], Colors.white),
              onColorChanged: (color) {
                provider.updateThemeProperties({
                  'backgroundColor': '0x${color.value.toRadixString(16).toUpperCase()}',
                });
              },
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Typography'),
            const SizedBox(height: 12),
            _buildFontFamilyDropdown(context, provider, theme['fontFamily'] ?? 'Roboto'),
            const SizedBox(height: 24),
            _buildSectionHeader('Settings'),
            SwitchListTile(
              title: const Text('Use Material 3', style: TextStyle(color: Colors.white, fontSize: 14)),
              value: theme['useMaterial3'] ?? true,
              activeColor: const Color(0xFF0fadd5),
              onChanged: (value) {
                provider.updateThemeProperties({'useMaterial3': value});
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Colors.indigo.shade400,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildFontFamilyDropdown(BuildContext context, WidgetTreeProvider provider, String selectedFont) {
    final fonts = ['Roboto', 'Open Sans', 'Lato', 'Montserrat', 'Inter', 'Poppins'];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Font Family', style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF181A20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: fonts.contains(selectedFont) ? selectedFont : 'Roboto',
              dropdownColor: const Color(0xFF23263a),
              isExpanded: true,
              style: const TextStyle(color: Colors.white),
              items: fonts.map((font) {
                return DropdownMenuItem(
                  value: font,
                  child: Text(font),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  provider.updateThemeProperties({'fontFamily': value});
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}
