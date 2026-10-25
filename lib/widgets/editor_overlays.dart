import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/widget_node.dart';
import '../providers/widget_tree_provider.dart';
import '../ui/editor_theme.dart';
import '../ui/editor_widgets.dart';
import 'canvas_preview/builders/widget_builder_factory.dart';
import 'canvas_preview/canvas_preview_mode.dart';

/// An entry in the command palette.
class EditorCommand {
  final String label;
  final IconData icon;
  final String group;
  final String? shortcut;
  final VoidCallback run;

  const EditorCommand(this.label, this.icon, this.group, this.run, {this.shortcut});
}

/// ⌘K: fuzzy search over editor commands.
Future<void> showCommandPalette(BuildContext context, List<EditorCommand> commands) {
  return showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (context) => _CommandPalette(commands: commands),
  );
}

class _CommandPalette extends StatefulWidget {
  final List<EditorCommand> commands;

  const _CommandPalette({required this.commands});

  @override
  State<_CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<_CommandPalette> {
  String _query = '';
  int _highlight = 0;

  List<EditorCommand> get _matches {
    final q = _query.toLowerCase().trim();
    if (q.isEmpty) return widget.commands.take(40).toList();
    final words = q.split(' ');
    return widget.commands.where((c) {
      final text = '${c.label} ${c.group}'.toLowerCase();
      return words.every(text.contains);
    }).toList();
  }

  void _run(EditorCommand c) {
    Navigator.pop(context);
    c.run();
  }

  @override
  Widget build(BuildContext context) {
    final matches = _matches;
    if (_highlight >= matches.length) _highlight = 0;
    return Align(
      alignment: const Alignment(0, -0.55),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 560,
          constraints: const BoxConstraints(maxHeight: 460),
          decoration: BoxDecoration(
            color: EditorColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: EditorColors.borderStrong),
            boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 40, offset: Offset(0, 16))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  autofocus: true,
                  style: const TextStyle(fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Search commands, pages and widgets…',
                    prefixIcon: Icon(Icons.search_rounded, size: 19),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                  ),
                  onChanged: (v) => setState(() {
                    _query = v;
                    _highlight = 0;
                  }),
                  onSubmitted: (_) {
                    if (matches.isNotEmpty) _run(matches[_highlight]);
                  },
                ),
              ),
              const Divider(),
              Flexible(
                child: matches.isEmpty
                    ? const Padding(padding: EdgeInsets.all(24), child: Text('No matches', style: TextStyle(color: EditorColors.textFaint)))
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(8),
                        itemCount: matches.length,
                        itemBuilder: (context, i) {
                          final c = matches[i];
                          return MouseRegion(
                            onEnter: (_) => setState(() => _highlight = i),
                            child: EditorListTile(
                              icon: c.icon,
                              title: c.label,
                              subtitle: c.group,
                              selected: i == _highlight,
                              onTap: () => _run(c),
                              trailing: c.shortcut == null
                                  ? null
                                  : Text(c.shortcut!, style: const TextStyle(fontSize: 11.5, color: EditorColors.textFaint, fontWeight: FontWeight.w600)),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Keyboard shortcut reference.
Future<void> showShortcutsDialog(BuildContext context) {
  const shortcuts = [
    ('⌘ K', 'Command palette'),
    ('⌘ S', 'Save project'),
    ('⌘ Z / ⌘ ⇧ Z', 'Undo / redo'),
    ('⌘ C / ⌘ V', 'Copy / paste widget'),
    ('⌘ D', 'Duplicate widget'),
    ('Delete', 'Delete selected widget'),
    ('T', 'Toggle Test mode'),
    ('Esc', 'Leave Test mode or deselect'),
    ('?', 'This list'),
  ];
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Keyboard shortcuts'),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (keys, what) in shortcuts)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(children: [
                  Expanded(child: Text(what, style: const TextStyle(color: EditorColors.text))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: EditorColors.background, borderRadius: BorderRadius.circular(6), border: Border.all(color: EditorColors.border)),
                    child: Text(keys, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: EditorColors.textMuted)),
                  ),
                ]),
              ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
    ),
  );
}

/// All pages at a glance with their navigation links.
Future<void> showStoryboard(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const Dialog.fullscreen(backgroundColor: EditorColors.canvas, child: _Storyboard()),
  );
}

class _Storyboard extends StatelessWidget {
  const _Storyboard();

  static Set<String> linksFrom(WidgetNode screen) {
    final targets = <String>{};
    void visitActions(dynamic list) {
      if (list is! List) return;
      for (final a in list.whereType<Map>()) {
        if (a['type'] == 'navigate' && a['targetScreenId'] is String) targets.add(a['targetScreenId'] as String);
        visitActions(a['then']);
        visitActions(a['else']);
      }
    }

    void visit(dynamic v) {
      if (v is WidgetNode) {
        for (final key in const ['actions', 'onLongPress', 'onDoubleTap', 'onChanged', 'onSubmitted', 'onPageLoad']) {
          visitActions(v.properties[key]);
        }
        if (v.properties['navigateTo'] is String) targets.add(v.properties['navigateTo'] as String);
        v.properties.values.forEach(visit);
        v.children.forEach(visit);
      } else if (v is List) {
        v.forEach(visit);
      }
    }

    visit(screen);
    return targets..remove(screen.id);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    String name(String id) => '${provider.screens.where((s) => s.id == id).firstOrNull?.properties['pageName'] ?? 'Page'}';
    return Column(
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: const BoxDecoration(color: EditorColors.surface, border: Border(bottom: BorderSide(color: EditorColors.border))),
          child: Row(children: [
            const Icon(Icons.view_quilt_outlined, color: EditorColors.accent),
            const SizedBox(width: 10),
            const Text('Storyboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(width: 12),
            Text('${provider.screens.length} pages · click a page to edit it', style: const TextStyle(fontSize: 12.5, color: EditorColors.textFaint)),
            const Spacer(),
            EditorIconButton(icon: Icons.close_rounded, tooltip: 'Close', onPressed: () => Navigator.pop(context)),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Wrap(
              spacing: 28,
              runSpacing: 28,
              children: [
                for (final screen in provider.screens)
                  SizedBox(
                    width: 230,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Expanded(child: Text('${screen.properties['pageName'] ?? 'Page'}', overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700))),
                          if (screen.id == provider.logic.homePageId) const Tooltip(message: 'Home page', child: Icon(Icons.home_rounded, size: 15, color: EditorColors.accent)),
                          if (screen.id == provider.logic.loginPageId) const Tooltip(message: 'Sign-in page', child: Icon(Icons.lock_outline_rounded, size: 15, color: EditorColors.warning)),
                        ]),
                        const SizedBox(height: 8),
                        InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            provider.selectScreen(screen);
                            Navigator.pop(context);
                          },
                          child: Container(
                            width: 230,
                            height: 498,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: screen.id == provider.selectedScreen?.id ? EditorColors.accent : EditorColors.borderStrong, width: 2),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: IgnorePointer(
                              child: FittedBox(
                                child: SizedBox(
                                  width: 393,
                                  height: 852,
                                  child: MediaQuery(
                                    data: MediaQuery.of(context).copyWith(size: const Size(393, 852)),
                                    child: Theme(
                                      data: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
                                      child: CanvasPreviewMode(
                                        isLivePreview: true,
                                        child: Material(child: Builder(builder: (c) => WidgetBuilderFactory.buildWidget(c, screen, null))),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(spacing: 6, runSpacing: 6, children: [
                          for (final target in linksFrom(screen))
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: EditorColors.accentSoft, borderRadius: BorderRadius.circular(6)),
                              child: Text('→ ${name(target)}', style: const TextStyle(fontSize: 11.5, color: EditorColors.accent, fontWeight: FontWeight.w600)),
                            ),
                        ]),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Saved versions of the project with restore.
Future<void> showVersionHistory(BuildContext context) {
  return showDialog<void>(context: context, builder: (context) => const _VersionHistoryDialog());
}

class _VersionHistoryDialog extends StatefulWidget {
  const _VersionHistoryDialog();

  @override
  State<_VersionHistoryDialog> createState() => _VersionHistoryDialogState();
}

class _VersionHistoryDialogState extends State<_VersionHistoryDialog> {
  late Future<List<Map<String, dynamic>>> _versions;

  @override
  void initState() {
    super.initState();
    _versions = Provider.of<WidgetTreeProvider>(context, listen: false).listVersions();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    return AlertDialog(
      title: const Text('Version history'),
      content: SizedBox(
        width: 480,
        height: 420,
        child: provider.currentProjectId == null
            ? const EditorEmptyState(icon: Icons.cloud_off_outlined, title: 'Local draft', message: 'Open a cloud project from the dashboard to keep versions.')
            : FutureBuilder<List<Map<String, dynamic>>>(
                future: _versions,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError) {
                    return const EditorEmptyState(
                      icon: Icons.storage_rounded,
                      title: 'Version history is not set up',
                      message: 'Run supabase/migrations/20261025_project_versions_roles_comments.sql in your Supabase SQL editor, then save the project once.',
                    );
                  }
                  final versions = snapshot.data ?? const [];
                  if (versions.isEmpty) {
                    return const EditorEmptyState(icon: Icons.history_rounded, title: 'No versions yet', message: 'Every Save creates a version. You can also save a named version now.');
                  }
                  return ListView(
                    children: [
                      for (final v in versions)
                        EditorListTile(
                          icon: Icons.history_rounded,
                          title: '${v['label'] ?? 'Version'}',
                          subtitle: DateTime.tryParse('${v['created_at']}')?.toLocal().toString().substring(0, 16),
                          trailing: TextButton(
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('Restore this version?'),
                                  content: const Text('The current pages, theme and logic are replaced. Save first if you want to keep them as a version.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
                                    FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Restore')),
                                  ],
                                ),
                              );
                              if (ok != true) return;
                              await provider.restoreVersion('${v['id']}');
                              if (context.mounted) Navigator.pop(context);
                            },
                            child: const Text('Restore'),
                          ),
                        ),
                    ],
                  );
                },
              ),
      ),
      actions: [
        if (provider.currentProjectId != null)
          TextButton.icon(
            icon: const Icon(Icons.bookmark_add_outlined, size: 17),
            label: const Text('Save named version'),
            onPressed: () async {
              final controller = TextEditingController();
              final label = await showDialog<String>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Name this version'),
                  content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'e.g. Before checkout redesign')),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
                    FilledButton(onPressed: () => Navigator.pop(c, controller.text.trim()), child: const Text('Save')),
                  ],
                ),
              );
              if (label == null || label.isEmpty) return;
              await provider.saveVersionSnapshot(label: label);
              setState(() => _versions = provider.listVersions());
            },
          ),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    );
  }
}

/// Right-hand panel with comments on pages and widgets.
class CommentsPanel extends StatefulWidget {
  final VoidCallback onClose;

  const CommentsPanel({super.key, required this.onClose});

  @override
  State<CommentsPanel> createState() => _CommentsPanelState();
}

class _CommentsPanelState extends State<CommentsPanel> {
  final TextEditingController _input = TextEditingController();
  Future<List<Map<String, dynamic>>>? _comments;
  bool _showResolved = false;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() => _comments = Provider.of<WidgetTreeProvider>(context, listen: false).listComments();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final anchor = provider.selectedNode == null || provider.selectedNode?.id == provider.selectedScreen?.id
        ? 'page ${provider.selectedScreen?.properties['pageName'] ?? ''}'
        : provider.selectedNode!.type;
    return Container(
      width: 320,
      decoration: const BoxDecoration(color: EditorColors.surface, border: Border(left: BorderSide(color: EditorColors.border))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 8),
            child: Row(children: [
              const Icon(Icons.mode_comment_outlined, size: 17, color: EditorColors.accent),
              const SizedBox(width: 8),
              const Expanded(child: Text('Comments', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
              EditorPill(label: 'Resolved', selected: _showResolved, onTap: () => setState(() => _showResolved = !_showResolved)),
              EditorIconButton(icon: Icons.close_rounded, tooltip: 'Close', size: 16, onPressed: widget.onClose),
            ]),
          ),
          const Divider(),
          Expanded(
            child: provider.currentProjectId == null
                ? const EditorEmptyState(icon: Icons.cloud_off_outlined, title: 'Local draft', message: 'Comments are stored with cloud projects. Open this project from the dashboard.')
                : FutureBuilder<List<Map<String, dynamic>>>(
                    future: _comments,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
                      if (snapshot.hasError) {
                        return const EditorEmptyState(
                          icon: Icons.storage_rounded,
                          title: 'Comments are not set up',
                          message: 'Run supabase/migrations/20261025_project_versions_roles_comments.sql in the Supabase SQL editor.',
                        );
                      }
                      final comments = (snapshot.data ?? const []).where((c) => _showResolved || c['resolved'] != true).toList();
                      if (comments.isEmpty) {
                        return const EditorEmptyState(icon: Icons.forum_outlined, title: 'No comments', message: 'Select a widget and leave a note for your team.');
                      }
                      return ListView(
                        padding: const EdgeInsets.all(12),
                        children: [
                          for (final c in comments)
                            Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: EditorColors.surfaceRaised,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: EditorColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Expanded(
                                      child: Text('${c['author_name'] ?? c['author_email'] ?? 'Someone'}',
                                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                    ),
                                    EditorIconButton(
                                      icon: c['resolved'] == true ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
                                      tooltip: c['resolved'] == true ? 'Reopen' : 'Resolve',
                                      size: 16,
                                      color: c['resolved'] == true ? EditorColors.success : null,
                                      onPressed: () async {
                                        await provider.setCommentResolved('${c['id']}', c['resolved'] != true);
                                        setState(_reload);
                                      },
                                    ),
                                  ]),
                                  const SizedBox(height: 4),
                                  Text('${c['body']}', style: const TextStyle(fontSize: 13, height: 1.4)),
                                  if (c['widget_id'] != null) ...[
                                    const SizedBox(height: 6),
                                    InkWell(
                                      onTap: () {
                                        final node = provider.findNodeById('${c['widget_id']}');
                                        final screen = provider.screens.where((s) => s.id == c['screen_id']).firstOrNull;
                                        if (screen != null) provider.selectScreen(screen);
                                        if (node != null) provider.selectNode(node);
                                      },
                                      child: const Text('Show widget', style: TextStyle(fontSize: 11.5, color: EditorColors.accent, fontWeight: FontWeight.w600)),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),
          ),
          if (provider.currentProjectId != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(border: Border(top: BorderSide(color: EditorColors.border))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('On $anchor', style: const TextStyle(fontSize: 11.5, color: EditorColors.textFaint)),
                  const SizedBox(height: 6),
                  TextField(controller: _input, minLines: 1, maxLines: 4, decoration: const InputDecoration(hintText: 'Write a comment…')),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: () async {
                      final text = _input.text.trim();
                      if (text.isEmpty) return;
                      final user = _currentUser();
                      try {
                        await provider.addComment(text, authorEmail: user?.email, authorName: user?.displayName);
                        _input.clear();
                        setState(_reload);
                      } catch (e) {
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not post: $e')));
                      }
                    },
                    child: const Text('Comment'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  User? _currentUser() {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }
}
