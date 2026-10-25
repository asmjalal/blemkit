import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/widget_tree_provider.dart';
import '../ui/editor_theme.dart';
import '../ui/editor_widgets.dart';

/// The editor's top bar: project and page context on the left, tools and
/// the primary Save/Export actions on the right.
class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSave;
  final VoidCallback onExport;
  final VoidCallback onNew;
  final VoidCallback onLoad;
  final VoidCallback onTemplate;
  final VoidCallback onPreview;
  final VoidCallback onTheme;
  final VoidCallback onAiBuilder;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onSettings;
  final VoidCallback? onSubmitMarketplace;
  final VoidCallback? onLogic;
  final VoidCallback? onCommandPalette;
  final VoidCallback? onVersionHistory;
  final VoidCallback? onComments;
  final VoidCallback? onStoryboard;
  final VoidCallback? onShortcuts;
  final VoidCallback? onBack;
  final bool aiActive;
  final bool commentsActive;

  const TopNavBar({
    super.key,
    required this.onSave,
    required this.onExport,
    required this.onPreview,
    required this.onNew,
    required this.onLoad,
    required this.onTemplate,
    required this.onTheme,
    required this.onAiBuilder,
    this.onUndo,
    this.onRedo,
    this.onSettings,
    this.onSubmitMarketplace,
    this.onLogic,
    this.onCommandPalette,
    this.onVersionHistory,
    this.onComments,
    this.onStoryboard,
    this.onShortcuts,
    this.onBack,
    this.aiActive = false,
    this.commentsActive = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final projectName = '${provider.projectSettings['projectName'] ?? 'Untitled project'}';

    Widget divider() => Container(width: 1, height: 24, margin: const EdgeInsets.symmetric(horizontal: 8), color: EditorColors.border);

    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: EditorColors.surface,
        border: Border(bottom: BorderSide(color: EditorColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Tooltip(
            message: 'Back to projects',
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onBack ?? () => Navigator.maybePop(context),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset('assets/images/logo_mark.png', width: 30, height: 30, errorBuilder: (_, __, ___) => const Icon(Icons.widgets_rounded, color: EditorColors.accent)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Flexible(
                    child: Text(projectName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: EditorColors.text)),
                  ),
                  if (provider.hasUnsavedChanges)
                    const Tooltip(
                      message: 'Unsaved changes',
                      child: Padding(
                        padding: EdgeInsets.only(left: 6),
                        child: CircleAvatar(radius: 3.5, backgroundColor: EditorColors.warning),
                      ),
                    ),
                ]),
                Text(provider.currentProjectId == null ? 'Local draft' : 'Saved to cloud', style: const TextStyle(fontSize: 11, color: EditorColors.textFaint)),
              ],
            ),
          ),
          divider(),
          const _PageSwitcher(),
          const Spacer(),
          EditorIconButton(icon: Icons.undo_rounded, tooltip: 'Undo (⌘Z)', onPressed: onUndo),
          EditorIconButton(icon: Icons.redo_rounded, tooltip: 'Redo (⌘⇧Z)', onPressed: onRedo),
          divider(),
          _LabeledTool(icon: Icons.auto_awesome_rounded, label: 'AI', tooltip: 'AI builder', onTap: onAiBuilder, active: aiActive, color: EditorColors.violet),
          _LabeledTool(icon: Icons.account_tree_outlined, label: 'Logic', tooltip: 'App state, API calls, custom code, auth…', onTap: onLogic),
          _LabeledTool(icon: Icons.palette_outlined, label: 'Theme', tooltip: 'Colors, typography, dark mode', onTap: onTheme),
          _LabeledTool(icon: Icons.settings_outlined, label: 'Settings', tooltip: 'App settings & integrations', onTap: onSettings),
          divider(),
          EditorIconButton(icon: Icons.view_quilt_outlined, tooltip: 'Storyboard: all pages', onPressed: onStoryboard),
          EditorIconButton(icon: Icons.history_rounded, tooltip: 'Version history', onPressed: onVersionHistory),
          EditorIconButton(icon: Icons.mode_comment_outlined, tooltip: 'Comments', onPressed: onComments, active: commentsActive),
          _CommandButton(onTap: onCommandPalette),
          PopupMenuButton<String>(
            tooltip: 'More',
            icon: const Icon(Icons.more_horiz_rounded, size: 20, color: EditorColors.textMuted),
            onSelected: (v) {
              switch (v) {
                case 'new':
                  onNew();
                  break;
                case 'template':
                  onTemplate();
                  break;
                case 'load':
                  onLoad();
                  break;
                case 'preview':
                  onPreview();
                  break;
                case 'marketplace':
                  onSubmitMarketplace?.call();
                  break;
                case 'shortcuts':
                  onShortcuts?.call();
                  break;
              }
            },
            itemBuilder: (context) => [
              _menuItem('new', Icons.add_box_outlined, 'New design'),
              _menuItem('template', Icons.dashboard_customize_outlined, 'Insert template'),
              _menuItem('load', Icons.file_open_outlined, 'Import JSON'),
              _menuItem('preview', Icons.code_rounded, 'Code & live preview'),
              if (onSubmitMarketplace != null) _menuItem('marketplace', Icons.storefront_outlined, 'Submit to marketplace'),
              _menuItem('shortcuts', Icons.keyboard_outlined, 'Keyboard shortcuts'),
            ],
          ),
          const SizedBox(width: 6),
          OutlinedButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.cloud_upload_outlined, size: 17),
            label: const Text('Save'),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: onExport,
            icon: const Icon(Icons.download_rounded, size: 17),
            label: const Text('Export'),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label) => PopupMenuItem(
        value: value,
        height: 40,
        child: Row(children: [Icon(icon, size: 17, color: EditorColors.textMuted), const SizedBox(width: 10), Text(label)]),
      );
}

class _LabeledTool extends StatelessWidget {
  final IconData icon;
  final String label;
  final String tooltip;
  final VoidCallback? onTap;
  final bool active;
  final Color? color;

  const _LabeledTool({required this.icon, required this.label, required this.tooltip, this.onTap, this.active = false, this.color});

  @override
  Widget build(BuildContext context) {
    final tint = color ?? EditorColors.accent;
    return Tooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Material(
          color: active ? tint.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
              child: Row(children: [
                Icon(icon, size: 16, color: active || color != null ? tint : EditorColors.textMuted),
                const SizedBox(width: 6),
                Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: active ? EditorColors.text : EditorColors.textMuted)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class _CommandButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _CommandButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Material(
        color: EditorColors.background,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: EditorColors.border)),
            child: const Row(children: [
              Icon(Icons.search_rounded, size: 15, color: EditorColors.textFaint),
              SizedBox(width: 6),
              Text('Search', style: TextStyle(fontSize: 12.5, color: EditorColors.textFaint)),
              SizedBox(width: 14),
              Text('⌘K', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: EditorColors.textFaint)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _PageSwitcher extends StatelessWidget {
  const _PageSwitcher();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final current = provider.selectedScreen;
    return PopupMenuButton<String>(
      tooltip: 'Switch page',
      offset: const Offset(0, 44),
      onSelected: (id) {
        final screen = provider.screens.where((s) => s.id == id).firstOrNull;
        if (screen != null) provider.selectScreen(screen);
      },
      itemBuilder: (context) => [
        for (final s in provider.screens)
          PopupMenuItem(
            value: s.id,
            height: 38,
            child: Row(children: [
              Icon(Icons.web_asset_rounded, size: 16, color: s.id == current?.id ? EditorColors.accent : EditorColors.textMuted),
              const SizedBox(width: 10),
              Text('${s.properties['pageName'] ?? 'Page'}'),
            ]),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(color: EditorColors.background, borderRadius: BorderRadius.circular(8), border: Border.all(color: EditorColors.border)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.web_asset_rounded, size: 15, color: EditorColors.accent),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 160),
            child: Text('${current?.properties['pageName'] ?? 'No page'}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 6),
          Text('${provider.screens.length}', style: const TextStyle(fontSize: 11, color: EditorColors.textFaint)),
          const Icon(Icons.expand_more_rounded, size: 16, color: EditorColors.textFaint),
        ]),
      ),
    );
  }
}
