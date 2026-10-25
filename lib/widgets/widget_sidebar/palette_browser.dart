import 'package:flutter/material.dart';

import '../../ui/editor_theme.dart';

/// The Widgets tab: search, category filter and a grid of draggable widget
/// tiles. Tapping a tile adds it to the selected widget; dragging drops it
/// onto the canvas.
class PaletteBrowser extends StatefulWidget {
  final List<Map<String, dynamic>> categories;
  final List<String> recent;
  final ValueChanged<String> onAdd;

  const PaletteBrowser({super.key, required this.categories, required this.recent, required this.onAdd});

  @override
  State<PaletteBrowser> createState() => _PaletteBrowserState();
}

class _PaletteBrowserState extends State<PaletteBrowser> {
  String _query = '';
  String? _category;

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final iconsByType = <String, IconData>{
      for (final c in widget.categories)
        for (final w in c['widgets'] as List) w['type'] as String: w['icon'] as IconData,
    };
    final labelsByType = <String, String>{
      for (final c in widget.categories)
        for (final w in c['widgets'] as List) w['type'] as String: (w['label'] ?? w['type']) as String,
    };

    final sections = <MapEntry<String, List<Map>>>[];
    for (final c in widget.categories) {
      if (_category != null && c['name'] != _category) continue;
      final items = (c['widgets'] as List)
          .cast<Map>()
          .where((w) => q.isEmpty || '${w['label'] ?? w['type']}'.toLowerCase().contains(q) || '${w['type']}'.toLowerCase().contains(q))
          .toList();
      if (items.isNotEmpty) sections.add(MapEntry(c['name'] as String, items));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: 'Search widgets',
            prefixIcon: const Icon(Icons.search_rounded, size: 18),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(icon: const Icon(Icons.close_rounded, size: 16), onPressed: () => setState(() => _query = '')),
          ),
          controller: TextEditingController(text: _query)..selection = TextSelection.collapsed(offset: _query.length),
          onChanged: (v) => setState(() => _query = v),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 30,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _chip('All', _category == null, () => setState(() => _category = null)),
              for (final c in widget.categories) _chip(_shortName(c['name'] as String), _category == c['name'], () => setState(() => _category = c['name'] as String)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              if (q.isEmpty && _category == null && widget.recent.isNotEmpty) ...[
                _sectionTitle('Recently used'),
                _grid([for (final t in widget.recent) if (iconsByType.containsKey(t)) {'type': t, 'icon': iconsByType[t], 'label': labelsByType[t]}]),
              ],
              for (final section in sections) ...[
                _sectionTitle(section.key),
                _grid(section.value),
              ],
              if (sections.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No widgets match.', textAlign: TextAlign.center, style: TextStyle(color: EditorColors.textFaint)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _shortName(String name) => name.replaceAll(' Elements', '').replaceAll(' & State', '');

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: selected ? EditorColors.accentSoft : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(7),
          side: BorderSide(color: selected ? EditorColors.accent : EditorColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Center(
              child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? EditorColors.text : EditorColors.textMuted)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(2, 10, 0, 8),
        child: Text(text.toUpperCase(), style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, letterSpacing: 1.1, color: EditorColors.textFaint)),
      );

  Widget _grid(List<Map> items) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      childAspectRatio: 1.05,
      children: [
        for (final w in items)
          _PaletteTile(
            type: w['type'] as String,
            label: (w['label'] ?? w['type']) as String,
            icon: w['icon'] as IconData,
            onTap: () => widget.onAdd(w['type'] as String),
          ),
      ],
    );
  }
}

class _PaletteTile extends StatefulWidget {
  final String type;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PaletteTile({required this.type, required this.label, required this.icon, required this.onTap});

  @override
  State<_PaletteTile> createState() => _PaletteTileState();
}

class _PaletteTileState extends State<_PaletteTile> {
  bool _hover = false;

  /// "VerticalDivider" → "Vertical Divider" so long names wrap at word breaks.
  String get _label => widget.label.replaceAllMapped(RegExp(r'(?<=[a-z])(?=[A-Z])'), (_) => ' ');

  Widget _tile({bool dragging = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: BoxDecoration(
        color: _hover || dragging ? EditorColors.surfaceHover : EditorColors.surfaceRaised,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: _hover || dragging ? EditorColors.borderStrong : Colors.transparent),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(widget.icon, size: 19, color: _hover ? EditorColors.accent : EditorColors.textMuted),
          const SizedBox(height: 6),
          Text(
            _label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10.5, height: 1.2, color: _hover ? EditorColors.text : EditorColors.textMuted, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Click to add · drag onto the canvas',
      waitDuration: const Duration(milliseconds: 900),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Draggable<String>(
          data: widget.type,
          feedback: Material(color: Colors.transparent, child: SizedBox(width: 84, height: 78, child: Opacity(opacity: 0.85, child: _tile(dragging: true)))),
          childWhenDragging: Opacity(opacity: 0.35, child: _tile()),
          child: GestureDetector(onTap: widget.onTap, child: _tile()),
        ),
      ),
    );
  }
}
