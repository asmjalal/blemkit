import 'package:flutter/material.dart';

import '../ui/editor_theme.dart';

/// A quick-start tile on the dashboard (blank app, template, AI).
class DashboardQuickStart extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const DashboardQuickStart({super.key, required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: EditorColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: EditorColors.border)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: EditorColors.textMuted)),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

/// A project in the dashboard grid.
class DashboardProjectCard extends StatefulWidget {
  final Map<String, dynamic> project;
  final VoidCallback onOpen;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final String Function(String) formatTimeAgo;

  const DashboardProjectCard({
    super.key,
    required this.project,
    required this.onOpen,
    required this.onRename,
    required this.onDelete,
    required this.formatTimeAgo,
  });

  @override
  State<DashboardProjectCard> createState() => _DashboardProjectCardState();
}

class _DashboardProjectCardState extends State<DashboardProjectCard> {
  bool _isHovered = false;

  static const _gradients = [
    [Color(0xFF0EA5E9), Color(0xFF6366F1)],
    [Color(0xFF10B981), Color(0xFF0EA5E9)],
    [Color(0xFFF59E0B), Color(0xFFEF4444)],
    [Color(0xFF8B5CF6), Color(0xFFEC4899)],
    [Color(0xFF14B8A6), Color(0xFF22C55E)],
  ];

  @override
  Widget build(BuildContext context) {
    final name = '${widget.project['project_name'] ?? 'Untitled Project'}';
    final colors = _gradients[name.hashCode.abs() % _gradients.length];
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onOpen,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: EditorColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _isHovered ? EditorColors.accent.withValues(alpha: 0.6) : EditorColors.border),
            boxShadow: [if (_isHovered) const BoxShadow(color: Color(0x55000000), blurRadius: 24, offset: Offset(0, 10))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: [colors[0].withValues(alpha: 0.85), colors[1].withValues(alpha: 0.85)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: widget.project['thumbnail'] != null
                      ? ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(widget.project['thumbnail'], fit: BoxFit.cover))
                      : Center(
                          child: Text(
                            name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase(),
                            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 2, 4, 12),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(
                        'Edited ${widget.formatTimeAgo(widget.project['updated_at'] ?? DateTime.now().toIso8601String())}',
                        style: const TextStyle(fontSize: 12, color: EditorColors.textFaint),
                      ),
                    ]),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Project actions',
                    icon: const Icon(Icons.more_horiz_rounded, size: 18, color: EditorColors.textMuted),
                    onSelected: (value) {
                      if (value == 'open') widget.onOpen();
                      if (value == 'rename') widget.onRename();
                      if (value == 'delete') widget.onDelete();
                    },
                    itemBuilder: (BuildContext context) => const [
                      PopupMenuItem<String>(value: 'open', height: 38, child: Text('Open')),
                      PopupMenuItem<String>(value: 'rename', height: 38, child: Text('Rename')),
                      PopupMenuItem<String>(value: 'delete', height: 38, child: Text('Delete', style: TextStyle(color: EditorColors.danger))),
                    ],
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
