import 'package:flutter/material.dart';
import '../ui/editor_widgets.dart';
import '../ui/editor_theme.dart';
import 'package:provider/provider.dart';
import '../providers/widget_tree_provider.dart';

class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _tabs = [
    {'icon': Icons.palette_outlined, 'label': 'Colors'},
    {'icon': Icons.text_fields_outlined, 'label': 'Typography'},
    {'icon': Icons.token_outlined, 'label': 'Design Tokens'},
    {'icon': Icons.widgets_outlined, 'label': 'Theme Widgets'},
  ];

  Map<String, dynamic>? _editingWidget;

  void _showCreateWidgetDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateThemeWidgetDialog(
        onCreated: (name, type) {
          final newWidget = {
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'name': name,
            'type': type,
            'properties': {},
          };
          Provider.of<WidgetTreeProvider>(context, listen: false).addThemedWidget(newWidget);
          setState(() => _editingWidget = newWidget);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_editingWidget != null) {
      return _buildEditorView();
    }

    return Scaffold(
      backgroundColor: EditorColors.surface,
      appBar: AppBar(
        backgroundColor: EditorColors.surface,
        elevation: 0,
        title: const Text('Theme Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: _generatePalette,
            icon: const Icon(Icons.auto_awesome, size: 18, color: Colors.indigoAccent),
            label: const Text('Palette from brand color', style: TextStyle(color: Colors.indigoAccent)),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.check, size: 18, color: Colors.greenAccent),
            label: const Text('Save & Exit', style: TextStyle(color: Colors.greenAccent)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 240,
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Colors.white10)),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    itemCount: _tabs.length,
                    itemBuilder: (context, index) {
                      final tab = _tabs[index];
                      final isSelected = _selectedTab == index;
                      return ListTile(
                        selected: isSelected,
                        onTap: () => setState(() => _selectedTab = index),
                        leading: Icon(tab['icon'], color: isSelected ? Colors.indigoAccent : Colors.white54),
                        title: Text(
                          tab['label'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white54,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selectedTileColor: Colors.indigoAccent.withOpacity(0.1),
                      );
                    },
                  ),
                ),
                if (_selectedTab == 3)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton.icon(
                      onPressed: _showCreateWidgetDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Widget'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigoAccent,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Content Area
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildEditorView() {
    final widget = _editingWidget!;
    return Scaffold(
      backgroundColor: EditorColors.background,
      appBar: AppBar(
        backgroundColor: EditorColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Create Themed ${widget['type']}', style: const TextStyle(color: Colors.white, fontSize: 18)),
            Text(widget['name'], style: const TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => setState(() => _editingWidget = null),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ElevatedButton(
              onPressed: () {
                Provider.of<WidgetTreeProvider>(context, listen: false)
                    .updateThemedWidget(_editingWidget!['id'], _editingWidget!['properties']);
                setState(() => _editingWidget = null);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Save'),
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          // Preview Canvas
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white10),
              ),
              child: Center(
                child: _buildThemedWidgetPreview(widget),
              ),
            ),
          ),
          // Properties Panel (Simplified)
          Container(
            width: 320,
            decoration: const BoxDecoration(
              color: EditorColors.surface,
              border: Border(left: BorderSide(color: Colors.white10)),
            ),
            child: _buildThemedPropertiesPanel(widget),
          ),
        ],
      ),
    );
  }

  Widget _buildThemedWidgetPreview(Map<String, dynamic> widget) {
    final props = widget['properties'] ?? {};
    final bgColorStr = props['fillColor'] ?? '0xFFFFFFFF';
    final radius = double.tryParse(props['borderRadius']?.toString() ?? '12') ?? 12.0;
    
    if (widget['type'] == 'Container') {
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          color: Color(int.parse(bgColorStr)),
          borderRadius: BorderRadius.circular(radius),
          boxShadow: [
            if (props['elevation'] != null && double.parse(props['elevation'].toString()) > 0)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: double.parse(props['elevation'].toString()) * 2,
                offset: Offset(0, double.parse(props['elevation'].toString())),
              ),
          ],
        ),
      );
    }
    return const Icon(Icons.widgets, color: Colors.white, size: 64);
  }

  Widget _buildThemedPropertiesPanel(Map<String, dynamic> widget) {
    final props = widget['properties'] ?? {};
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('${widget['type']} Properties', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        _buildPropertyRow('Fill Color', props['fillColor'] ?? '0xFFFFFFFF', (val) {
          setState(() => widget['properties']['fillColor'] = val);
        }),
        _buildPropertyRow('Border Radius', props['borderRadius']?.toString() ?? '12', (val) {
          setState(() => widget['properties']['borderRadius'] = val);
        }),
        _buildPropertyRow('Elevation', props['elevation']?.toString() ?? '0', (val) {
          setState(() => widget['properties']['elevation'] = val);
        }),
      ],
    );
  }

  Widget _buildPropertyRow(String label, String value, Function(String) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              final controller = TextEditingController(text: value);
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: EditorColors.surfaceRaised,
                  title: Text('Edit $label', style: const TextStyle(color: Colors.white)),
                  content: TextField(
                    controller: controller,
                    autofocus: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(hintText: label, hintStyle: const TextStyle(color: Colors.white38)),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(onPressed: () {
                      onChanged(controller.text);
                      Navigator.pop(context);
                    }, child: const Text('Update')),
                  ],
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(value, style: const TextStyle(color: Colors.white)),
                  const Icon(Icons.edit, color: Colors.white24, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return _buildColorsView();
      case 1:
        return _buildTypographyView();
      case 2:
        return _buildDesignTokensView();
      case 3:
        return _buildThemeWidgetsView();
      default:
        return const Center(child: Text('Coming Soon', style: TextStyle(color: Colors.white)));
    }
  }

  Widget _buildColorsView() {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final theme = provider.themeProperties;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Colors', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Define the visual DNA of your application with global color tokens.', style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 32),
          
          _buildColorSection('Brand Colors', [
            'primaryColor', 'secondaryColor', 'tertiaryColor', 'alternateColor'
          ], provider),
          
          const SizedBox(height: 32),
          _buildColorSection('Utility Colors', [
            'backgroundColor', 'scaffoldBackgroundColor', 'primaryText', 'secondaryText'
          ], provider),
          
          const SizedBox(height: 32),
          _buildColorSection('Semantic Colors', [
            'successColor', 'errorColor', 'warningColor', 'infoColor'
          ], provider),

          const SizedBox(height: 32),
          _buildColorSection('Dark Mode', [
            'dark_primaryColor', 'dark_scaffoldBackgroundColor', 'dark_backgroundColor', 'dark_primaryText', 'dark_secondaryText'
          ], provider),
          const SizedBox(height: 10),
          const Text('Used when the exported app runs in dark mode. Preview it with the sun/moon button above the canvas.',
              style: TextStyle(color: Colors.white38, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildColorSection(String title, List<String> keys, WidgetTreeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: keys.map((key) => _buildColorCard(key, provider)).toList(),
        ),
      ],
    );
  }

  Widget _buildColorCard(String key, WidgetTreeProvider provider) {
    final colorHex = '${provider.themeProperties[key] ?? _darkDefaults[key] ?? '0xFF000000'}';
    final color = Color(int.tryParse(colorHex) ?? 0xFF000000);
    final label = key.replaceAll('dark_', '').replaceAll('Color', '').replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}').trim();

    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: EditorColors.surfaceRaised,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label[0].toUpperCase() + label.substring(1), style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _pickColor(key, provider),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Text('#', style: TextStyle(color: Colors.white24, fontSize: 12)),
                  const SizedBox(width: 4),
                  Text(colorHex.substring(2).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pickColor(String key, WidgetTreeProvider provider) async {
    // For now, let's just use a simple mock color picker or text input
    // In a real app, you'd use flutter_colorpicker
    final controller = TextEditingController(text: '${provider.themeProperties[key] ?? _darkDefaults[key] ?? '0xFF000000'}'.substring(2).toUpperCase());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: EditorColors.surfaceRaised,
        title: Text('Edit ${key}', style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'HEX (e.g. FF6366F1)',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final hex = controller.text.trim();
              if (RegExp(r'^[0-9A-Fa-f]{6,8}$').hasMatch(hex)) {
                final fullHex = hex.length == 6 ? '0xFF$hex' : '0x$hex';
                provider.updateThemeProperties({key: fullHex});
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildTypographyView() {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final theme = provider.themeProperties;
    final List<String> textStyleKeys = [
      'displayLarge', 'displayMedium', 'displaySmall',
      'headlineLarge', 'headlineMedium', 'headlineSmall',
      'titleLarge', 'titleMedium', 'titleSmall',
      'labelLarge', 'bodyLarge', 'bodyMedium', 'bodySmall'
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Typography & Icons', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Manage your project typography and font scales.', style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 24),
          Row(children: [
            const Text('Font family', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
            const SizedBox(width: 16),
            SizedBox(
              width: 260,
              child: EditorDropdown<String>(
                value: '${theme['fontFamily'] ?? 'Inter'}',
                items: {..._googleFonts, '${theme['fontFamily'] ?? 'Inter'}'}.toList(),
                label: (f) => f,
                onChanged: (f) {
                  if (f != null) provider.updateThemeProperties({'fontFamily': f});
                },
              ),
            ),
            const SizedBox(width: 12),
            const Flexible(
              child: Text('Loaded with google_fonts in the exported app.', style: TextStyle(color: Colors.white38, fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: EditorColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              children: [
                Row(
                  children: const [
                    Expanded(flex: 3, child: Text('Style Name', style: TextStyle(color: Colors.white54, fontSize: 12))),
                    Expanded(flex: 1, child: Text('Font Size', style: TextStyle(color: Colors.white54, fontSize: 12))),
                    Expanded(flex: 2, child: Text('Weight', style: TextStyle(color: Colors.white54, fontSize: 12))),
                    Expanded(flex: 2, child: Text('Family', style: TextStyle(color: Colors.white54, fontSize: 12))),
                  ],
                ),
                const Divider(color: Colors.white12, height: 24),
                for (var key in textStyleKeys)
                  _buildTypographyRow(key, provider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypographyRow(String key, WidgetTreeProvider provider) {
    final style = provider.themeProperties[key] as Map<String, dynamic>;
    final label = key.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)}').trim();
    final bool isDark = true;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label[0].toUpperCase() + label.substring(1),
              style: TextStyle(
                color: Colors.white,
                fontSize: style['fontSize'] > 24 ? 20 : style['fontSize'],
                fontWeight: style['fontWeight'] == 'Bold' ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text('${style['fontSize'].toInt()}', style: const TextStyle(color: Colors.white70)),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(4)),
              child: Text(style['fontWeight'] ?? 'Normal', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(provider.themeProperties['fontFamily'] ?? 'Default', style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildDesignTokensView() {
    final provider = Provider.of<WidgetTreeProvider>(context);
    const tokens = [
      ('spacingXs', 'Spacing XS', 4, Icons.space_bar),
      ('spacingSm', 'Spacing S', 8, Icons.space_bar),
      ('spacingMd', 'Spacing M', 16, Icons.space_bar),
      ('spacingLg', 'Spacing L', 24, Icons.space_bar),
      ('spacingXl', 'Spacing XL', 32, Icons.space_bar),
      ('radiusSm', 'Radius S', 8, Icons.rounded_corner),
      ('radiusMd', 'Radius M', 12, Icons.rounded_corner),
      ('radiusLg', 'Radius L', 20, Icons.rounded_corner),
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Design System Tokens', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          const Text('Spacing and corner radius tokens, exported as AppTheme.spacingMd, AppTheme.radiusLg, …', style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 32),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              for (final (key, label, fallback, icon) in tokens)
                Container(
                  width: 200,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: EditorColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: EditorColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Icon(icon, color: EditorColors.accent, size: 18),
                        const SizedBox(width: 8),
                        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                      ]),
                      const SizedBox(height: 12),
                      EditorTextInput(
                        value: '${provider.themeProperties[key] ?? fallback}',
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          final n = num.tryParse(v);
                          if (n != null) provider.updateThemeProperties({key: n.toDouble()});
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static const Map<String, String> _darkDefaults = {
    'dark_primaryColor': '0xFF38BDF8',
    'dark_scaffoldBackgroundColor': '0xFF0B1120',
    'dark_backgroundColor': '0xFF111827',
    'dark_primaryText': '0xFFF1F5F9',
    'dark_secondaryText': '0xFF94A3B8',
  };

  static const List<String> _googleFonts = [
    'Inter', 'Outfit', 'Roboto', 'Poppins', 'Montserrat', 'Lato', 'Open Sans', 'Nunito', 'Manrope', 'DM Sans',
    'Plus Jakarta Sans', 'Space Grotesk', 'Figtree', 'Work Sans', 'Rubik', 'Playfair Display', 'Merriweather', 'Lora',
  ];

  /// Builds a full palette (including dark mode) from one brand color.
  Future<void> _generatePalette() async {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    final controller = TextEditingController(text: '${provider.themeProperties['primaryColor'] ?? '0xFF4F46E5'}'.replaceFirst('0xFF', '#'));
    final hex = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Palette from brand color'),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Secondary, tertiary, neutrals and dark-mode colors are derived from it.'),
          const SizedBox(height: 14),
          TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: '#4F46E5')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(c, controller.text.trim()), child: const Text('Generate')),
        ],
      ),
    );
    final cleaned = hex?.replaceAll('#', '').replaceAll('0x', '').replaceAll('0X', '');
    if (cleaned == null || !RegExp(r'^[0-9A-Fa-f]{6}$|^[0-9A-Fa-f]{8}$').hasMatch(cleaned)) return;
    final base = Color(int.parse(cleaned.length == 6 ? 'FF$cleaned' : cleaned, radix: 16));
    final hsl = HSLColor.fromColor(base);
    String c(HSLColor color) => '0x${color.toColor().toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';
    HSLColor shift(double hue, {double? s, double? l}) =>
        hsl.withHue((hsl.hue + hue) % 360).withSaturation((s ?? hsl.saturation).clamp(0.0, 1.0)).withLightness((l ?? hsl.lightness).clamp(0.0, 1.0));
    provider.updateThemeProperties({
      'primaryColor': c(hsl),
      'secondaryColor': c(shift(150, l: 0.45)),
      'tertiaryColor': c(shift(40, s: 0.85, l: 0.55)),
      'alternateColor': c(shift(0, s: 0.15, l: 0.5)),
      'scaffoldBackgroundColor': c(shift(0, s: 0.3, l: 0.98)),
      'backgroundColor': '0xFFFFFFFF',
      'primaryText': c(shift(0, s: 0.4, l: 0.12)),
      'secondaryText': c(shift(0, s: 0.15, l: 0.45)),
      'dark_primaryColor': c(shift(0, l: (hsl.lightness + 0.15).clamp(0.55, 0.75))),
      'dark_scaffoldBackgroundColor': c(shift(0, s: 0.35, l: 0.06)),
      'dark_backgroundColor': c(shift(0, s: 0.3, l: 0.11)),
      'dark_primaryText': c(shift(0, s: 0.2, l: 0.95)),
      'dark_secondaryText': c(shift(0, s: 0.12, l: 0.65)),
    });
  }

  Widget _buildThemeWidgetsView() {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final theme = provider.themeProperties;
    final themedWidgets = provider.themedWidgets;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('Theme Widgets', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  SizedBox(height: 8),
                  Text('See how your theme updates all instances of your widgets.', style: TextStyle(color: Colors.white54)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _showCreateWidgetDialog,
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Create Widget'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigoAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          
          if (themedWidgets.isNotEmpty) ...[
            _buildWidgetCategory('Custom Components', themedWidgets.map((w) {
              return _buildGalleryItem(
                w['name'], 
                _buildThemedWidgetPreview(w),
                isCustom: true,
                onEdit: () => setState(() => _editingWidget = w),
                onDelete: () => provider.removeThemedWidget(w['id']),
              );
            }).toList()),
            const SizedBox(height: 40),
          ],

          _buildWidgetCategory('Base Elements', [
            _buildGalleryItem('Primary Button', ElevatedButton(onPressed: () {}, child: const Text('Button'))),
            _buildGalleryItem('Secondary Button', OutlinedButton(onPressed: () {}, child: const Text('Outline'))),
            _buildGalleryItem('Text Button', TextButton(onPressed: () {}, child: const Text('Text Link'))),
          ]),
          
          const SizedBox(height: 40),
          _buildWidgetCategory('Form Elements', [
            _buildGalleryItem('TextField', const TextField(decoration: InputDecoration(hintText: 'Search...', border: OutlineInputBorder()))),
            _buildGalleryItem('Checkbox', Row(children: [Checkbox(value: true, onChanged: (_){}), const Text('Selected', style: TextStyle(color: Colors.white70))])),
            _buildGalleryItem('Switch', Row(children: [Switch(value: true, onChanged: (_){}), const Text('Active', style: TextStyle(color: Colors.white70))])),
          ]),

          const SizedBox(height: 40),
          _buildWidgetCategory('Layout Elements', [
            _buildGalleryItem('ListTile', const ListTile(leading: Icon(Icons.person, color: Colors.indigoAccent), title: Text('User Profile', style: TextStyle(color: Colors.white)), subtitle: Text('Online', style: TextStyle(color: Colors.white54)))),
            _buildGalleryItem('Card', Card(color: EditorColors.borderStrong, child: const Padding(padding: EdgeInsets.all(16), child: Text('Surface Container', style: TextStyle(color: Colors.white))))),
          ]),
        ],
      ),
    );
  }

  Widget _buildWidgetCategory(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          children: items,
        ),
      ],
    );
  }

  Widget _buildGalleryItem(String label, Widget widget, {bool isCustom = false, VoidCallback? onEdit, VoidCallback? onDelete}) {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    final theme = provider.themeProperties;
    
    return Container(
      width: 320,
      decoration: BoxDecoration(
        color: EditorColors.surfaceRaised,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
              child: Theme(
                data: ThemeData(
                  useMaterial3: true,
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: Color(int.parse(theme['primaryColor'])),
                    primary: Color(int.parse(theme['primaryColor'])),
                    secondary: Color(int.parse(theme['secondaryColor'] ?? theme['primaryColor'])),
                  ),
                ),
                child: widget,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                Row(
                  children: [
                    if (isCustom) ...[
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.white38),
                        onPressed: onEdit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                    ],
                    const Icon(Icons.copy, size: 14, color: Colors.white38),
                    const SizedBox(width: 12),
                    if (isCustom)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 16, color: Colors.white38),
                        onPressed: onDelete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    else
                      const Icon(Icons.delete_outline, size: 14, color: Colors.white38),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateThemeWidgetDialog extends StatefulWidget {
  final Function(String name, String type) onCreated;
  const _CreateThemeWidgetDialog({required this.onCreated});

  @override
  State<_CreateThemeWidgetDialog> createState() => _CreateThemeWidgetDialogState();
}

class _CreateThemeWidgetDialogState extends State<_CreateThemeWidgetDialog> {
  final _nameController = TextEditingController();
  String? _selectedType;

  final Map<String, List<Map<String, dynamic>>> _categories = {
    'Layout Elements': [
      {'type': 'Container', 'icon': Icons.crop_square},
      {'type': 'Card', 'icon': Icons.credit_card},
      {'type': 'Divider', 'icon': Icons.horizontal_rule},
      {'type': 'VerticalDivider', 'icon': Icons.vertical_align_center},
    ],
    'Base Elements': [
      {'type': 'Text', 'icon': Icons.text_fields},
      {'type': 'Icon', 'icon': Icons.insert_emoticon},
      {'type': 'Button', 'icon': Icons.smart_button},
      {'type': 'IconButton', 'icon': Icons.add_circle_outline},
      {'type': 'ListTile', 'icon': Icons.list_alt},
    ],
    'Form Elements': [
      {'type': 'TextField', 'icon': Icons.edit},
      {'type': 'DropDown', 'icon': Icons.arrow_drop_down_circle},
      {'type': 'Checkbox', 'icon': Icons.check_box},
      {'type': 'Switch', 'icon': Icons.toggle_on},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: EditorColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        height: 700,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create Theme Widget', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Select a Widget type below in order to create a new Theme Widget.', style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Theme Widget Name (required)',
                hintStyle: const TextStyle(color: Colors.white24),
                filled: true,
                fillColor: Colors.black26,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: _categories.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(entry.key, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 4,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        children: entry.value.map((item) {
                          final isSelected = _selectedType == item['type'];
                          return InkWell(
                            onTap: () => setState(() => _selectedType = item['type']),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.indigoAccent.withOpacity(0.2) : Colors.black26,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isSelected ? Colors.indigoAccent : Colors.white10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(item['icon'], color: isSelected ? Colors.indigoAccent : Colors.white54, size: 28),
                                  const SizedBox(height: 8),
                                  Text(item['type'], style: TextStyle(color: isSelected ? Colors.white : Colors.white54, fontSize: 10)),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white54))),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty && _selectedType != null) {
                      widget.onCreated(_nameController.text, _selectedType!);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EditorColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Create'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
