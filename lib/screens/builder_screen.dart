import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../generators/widget_generator_registry.dart';
import '../providers/widget_tree_provider.dart';
import '../widgets/canvas_preview_new.dart';
import '../widgets/widget_sidebar/widget_side_bar.dart';
import '../widgets/widget_tree/widget_tree_editor.dart';
import '../widgets/properties_panel.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../models/widget_node.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../platform/web_bridge.dart';
import '../services/github_exporter.dart';
import '../services/export_bundle.dart';
import 'package:archive/archive.dart';
import '../widgets/top_nav_bar.dart';
import '../generators/project_generator.dart';
import 'project_preview_screen.dart';
import '../widgets/template_custom_dialog.dart';
import 'theme_settings_screen.dart';
import 'app_settings_screen.dart';
import '../widgets/ai_panel.dart';
import '../widgets/ai_prompt_dialog.dart';
import '../widgets/widget_context_menu/widget_context_menu_actions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../widgets/submit_marketplace_dialog.dart';
import '../ui/editor_theme.dart';
import '../ui/editor_widgets.dart';
import '../widgets/editor_overlays.dart';
import '../widgets/welcome_tour.dart';
import 'project_logic_screen.dart';
import '../runtime/preview_runtime.dart';
import '../models/project_logic.dart';
import '../widgets/widget_sidebar/widget_side_bar.dart' show WidgetSidebar;

class BuilderScreen extends StatefulWidget {
  const BuilderScreen({super.key});

  @override
  State<BuilderScreen> createState() => _BuilderScreenState();
}

class _ExportChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ExportChip(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: EditorColors.background, borderRadius: BorderRadius.circular(6), border: Border.all(color: EditorColors.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 13, color: EditorColors.accent),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11.5, color: EditorColors.textMuted)),
      ]),
    );
  }
}

class _BuilderScreenState extends State<BuilderScreen> {
  int _selectedSidebarTab = 0; // 0: Widget Palette, 1: Widget Tree
  double _sidebarWidth = 280.0;
  bool _showAiPanel = false;
  bool _showComments = false;

  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _keyboardFocusNode.requestFocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) WelcomeTour.showIfFirstRun(context);
    });
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  bool _isTyping() {
    final focusContext = FocusManager.instance.primaryFocus?.context;
    return focusContext != null && focusContext.findAncestorWidgetOfExactType<EditableText>() != null;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    final isCtrl = HardwareKeyboard.instance.isControlPressed || HardwareKeyboard.instance.isMetaPressed;
    final isShift = HardwareKeyboard.instance.isShiftPressed;
    final key = event.logicalKey;

    if (isCtrl && key == LogicalKeyboardKey.keyK) {
      _openCommandPalette();
      return KeyEventResult.handled;
    }
    if (isCtrl && key == LogicalKeyboardKey.keyS) {
      _handleSave();
      return KeyEventResult.handled;
    }
    if (_isTyping()) return KeyEventResult.ignored;

    final selected = provider.selectedNode;
    final root = provider.rootNode;

    if ((key == LogicalKeyboardKey.delete || key == LogicalKeyboardKey.backspace) && !isCtrl) {
      if (selected != null && root != null && selected.id != root.id) {
        provider.commandManager.executeAction(DeleteWidgetAction(node: selected, provider: provider, root: root));
        return KeyEventResult.handled;
      }
    }
    if (isCtrl && key == LogicalKeyboardKey.keyZ && !isShift) {
      provider.commandManager.undo();
      provider.notify();
      return KeyEventResult.handled;
    }
    if (isCtrl && (key == LogicalKeyboardKey.keyY || (key == LogicalKeyboardKey.keyZ && isShift))) {
      provider.commandManager.redo();
      provider.notify();
      return KeyEventResult.handled;
    }
    if (isCtrl && key == LogicalKeyboardKey.keyC && selected != null && selected.id != root?.id) {
      provider.clipboard = selected.copy();
      Clipboard.setData(ClipboardData(text: jsonEncode({'synappkitWidget': selected.toJson()})));
      _toast('Copied ${selected.type}');
      return KeyEventResult.handled;
    }
    if (isCtrl && key == LogicalKeyboardKey.keyV) {
      _paste();
      return KeyEventResult.handled;
    }
    if (isCtrl && key == LogicalKeyboardKey.keyD && selected != null && root != null && selected.id != root.id) {
      provider.commandManager.executeAction(DuplicateWidgetAction(node: selected, provider: provider, root: root));
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      if (provider.testMode) {
        provider.setTestMode(false);
      } else {
        provider.selectNode(null);
      }
      return KeyEventResult.handled;
    }
    if (!isCtrl && key == LogicalKeyboardKey.keyT) {
      _toggleTestMode();
      return KeyEventResult.handled;
    }
    if (event.character == '?') {
      showShortcutsDialog(context);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }

  /// Pastes a widget copied in this or another project (via the system clipboard).
  Future<void> _paste() async {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    WidgetNode? node = provider.clipboard;
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final decoded = data?.text == null ? null : jsonDecode(data!.text!);
      if (decoded is Map && decoded['synappkitWidget'] is Map) {
        node = WidgetNode.fromJson(Map<String, dynamic>.from(decoded['synappkitWidget'] as Map));
      }
    } catch (_) {}
    if (node == null) return;
    final pasted = provider.pasteNode(node);
    if (pasted != null && mounted) _toast('Pasted ${pasted.type}');
  }

  void _toggleTestMode() {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    provider.setTestMode(!provider.testMode);
    if (provider.testMode && provider.selectedScreen != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) PreviewRuntime.run(context, PageLogic.onPageLoad(provider.selectedScreen!.properties));
      });
    }
  }

  void _openLogic([String section = 'appState']) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ProjectLogicScreen(initialSection: section)));
  }

  void _openCommandPalette() {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    void push(Widget screen) => Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    showCommandPalette(context, [
      EditorCommand('Save project', Icons.cloud_upload_outlined, 'Project', _handleSave, shortcut: '⌘S'),
      EditorCommand('Export Flutter code', Icons.download_rounded, 'Project', _handleExport),
      EditorCommand(provider.testMode ? 'Stop Test mode' : 'Start Test mode', Icons.play_arrow_rounded, 'Canvas', _toggleTestMode, shortcut: 'T'),
      EditorCommand('Toggle dark mode preview', Icons.dark_mode_outlined, 'Canvas', () => provider.setPreviewDarkMode(!provider.previewDarkMode)),
      EditorCommand('Storyboard', Icons.view_quilt_outlined, 'Canvas', () => showStoryboard(context)),
      EditorCommand('Version history', Icons.history_rounded, 'Project', () => showVersionHistory(context)),
      EditorCommand('Comments', Icons.mode_comment_outlined, 'Project', () => setState(() => _showComments = true)),
      EditorCommand('AI builder', Icons.auto_awesome_rounded, 'Build', () => setState(() => _showAiPanel = true)),
      EditorCommand('Theme & dark mode', Icons.palette_outlined, 'Settings', () => push(const ThemeSettingsScreen())),
      EditorCommand('App settings', Icons.settings_outlined, 'Settings', () => push(const AppSettingsScreen())),
      for (final (id, label, icon) in const [
        ('appState', 'App state', Icons.public_rounded),
        ('api', 'API calls', Icons.api_rounded),
        ('dataTypes', 'Data types', Icons.data_object_rounded),
        ('code', 'Custom code', Icons.code_rounded),
        ('auth', 'Authentication', Icons.lock_outline_rounded),
        ('i18n', 'Languages', Icons.translate_rounded),
        ('env', 'Environments', Icons.dns_outlined),
      ])
        EditorCommand(label, icon, 'Logic', () => _openLogic(id)),
      EditorCommand('Keyboard shortcuts', Icons.keyboard_outlined, 'Help', () => showShortcutsDialog(context), shortcut: '?'),
      EditorCommand('Welcome tour', Icons.school_outlined, 'Help', () => WelcomeTour.show(context)),
      for (final screen in provider.screens)
        EditorCommand('Go to ${screen.properties['pageName'] ?? 'page'}', Icons.web_asset_rounded, 'Pages', () => provider.selectScreen(screen)),
      for (final type in WidgetSidebar.paletteTypes)
        EditorCommand('Add $type', Icons.add_box_outlined, 'Widgets', () => _handleAddWidget(context, type)),
    ]);
  }

  Future<void> _handleSave() async {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    if (provider.rootNode == null) return;
    if (provider.currentProjectId == null) {
      _toast('This draft is saved in your browser. Create a project on the dashboard to save it to the cloud.');
      return;
    }

    showDialog(
      context: context, 
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: EditorColors.accent)),
    );
    
    await provider.saveProjectToSupabase();
    
    if (mounted) {
      Navigator.pop(context); // remove loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to the cloud · version created')),
      );
    }
  }

  void _handleSubmitMarketplace() async {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    if (provider.rootNode == null) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const SubmitMarketplaceDialog(),
    );

    if (result != null) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator(color: EditorColors.accent)),
      );

      try {
        final user = FirebaseAuth.instance.currentUser;
        final creatorId = user?.uid;
        
        // Serialize the screens list into JSON
        final screensJson = provider.screens.map((s) => s.toJson()).toList();
        final queriesJson = provider.queries;

        final supabaseClient = supabase.Supabase.instance.client;
        
        // Check if there is an active category in public.categories matching result['category']
        final catResponse = await supabaseClient
            .from('categories')
            .select('id')
            .eq('name', result['category'])
            .maybeSingle();
            
        final categoryId = catResponse != null ? catResponse['id'] : null;

        await supabaseClient.from('templates').insert({
          'name': result['name'],
          'description': result['description'],
          'category': result['category'],
          'category_id': categoryId,
          'screens_json': screensJson,
          'queries_json': queriesJson,
          'creator_id': creatorId,
          'status': 'pending_approval',
          'is_premium': result['is_premium'] ?? false,
          'thumbnail_url': result['thumbnail_url'],
        });

        if (mounted) {
          Navigator.pop(context); // remove loader
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Template submitted successfully! Admins will review it.')),
          );
        }
      } catch (e) {
        debugPrint('Error submitting template: $e');
        if (mounted) {
          Navigator.pop(context); // remove loader
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.redAccent),
          );
        }
      }
    }
  }

  void _handleExport() {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    if (provider.screens.isEmpty) return;

    var appName = '${provider.projectSettings['projectName'] ?? 'My App'}';
    var bundleName = '${provider.projectSettings['bundleId'] ?? 'com.example.myapp'}';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Export Flutter project'),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('You get a complete Flutter project (Android, iOS, web) as a .zip. Settings are pre-filled from App Settings.'),
                const SizedBox(height: 20),
                EditorField(label: 'App name', child: EditorTextInput(value: appName, onChanged: (v) => appName = v)),
                EditorField(label: 'Bundle ID', help: 'Reverse domain, e.g. com.company.app', child: EditorTextInput(value: bundleName, onChanged: (v) => bundleName = v)),
                const SizedBox(height: 4),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  _ExportChip(Icons.web_asset_rounded, '${provider.screens.length} pages'),
                  if (provider.logic.appState.isNotEmpty) _ExportChip(Icons.public_rounded, '${provider.logic.appState.length} app state'),
                  if (provider.logic.apiCalls.isNotEmpty) _ExportChip(Icons.api_rounded, '${provider.logic.apiCalls.length} API calls'),
                  if (provider.activeConnection != null) const _ExportChip(Icons.bolt_rounded, 'Supabase'),
                  if (provider.logic.usesAuth) const _ExportChip(Icons.lock_outline_rounded, 'Auth'),
                  if (provider.logic.customCode.isNotEmpty) _ExportChip(Icons.code_rounded, '${provider.logic.customCode.length} custom code'),
                ]),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton.icon(
              icon: const Icon(Icons.auto_awesome_motion_rounded, size: 17),
              label: const Text('Generate'),
              onPressed: () {
                Navigator.pop(context);
                final projectFiles = ProjectGenerator.generateFullProject(
                  provider.screens,
                  provider.themeProperties,
                  provider.themedWidgets,
                  appName: appName,
                  connection: provider.activeConnection,
                  queries: provider.queries,
                  logic: provider.logic,
                  components: provider.components,
                );
                _showProjectExportDialog(this.context, projectFiles, appName, bundleName);
              },
            ),
          ],
        );
      },
    );
  }

  void _showProjectExportDialog(BuildContext context, Map<String, String> files, String appName, String bundleName) {
    String selectedFile = files.keys.first;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: EditorColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 1000,
            height: 750,
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
                        Text(
                          'Export Full Project',
                          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Review generated code and download the complete app source.',
                          style: TextStyle(color: Colors.white54, fontSize: 14),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // File List
                      Container(
                        width: 240,
                        decoration: BoxDecoration(
                          color: EditorColors.surfaceRaised,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          itemCount: files.length,
                          itemBuilder: (context, index) {
                            final fileName = files.keys.elementAt(index);
                            final isSelected = fileName == selectedFile;
                            return ListTile(
                              dense: true,
                              title: Text(
                                fileName,
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFF3B82F6) : Colors.white70,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              onTap: () => setState(() => selectedFile = fileName),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Code Viewer
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: EditorColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(selectedFile, style: const TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.copy, size: 18, color: Colors.white70),
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: files[selectedFile]!));
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
                                    },
                                  ),
                                ],
                              ),
                              const Divider(color: Colors.white12),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: SelectableText(
                                    files[selectedFile]!,
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      color: Color(0xFFE2E8F0),
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close', style: TextStyle(color: Colors.white70)),
                    ),
                    if (kIsWeb) ...[
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () => _downloadFile(selectedFile, files[selectedFile]!),
                        icon: const Icon(Icons.download, size: 18),
                        label: const Text('Download Selected'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF3B82F6)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: () => _pushToGitHub(files, appName, bundleName),
                      icon: const Icon(Icons.commit_rounded, size: 18),
                      label: const Text('Push to GitHub'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: () => _downloadProjectAsZip(files, appName, bundleName),
                      icon: const Icon(Icons.folder_zip, size: 18),
                      label: const Text('Source Code (Complete Project)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Commits the full export to a GitHub branch with a personal access token.
  Future<void> _pushToGitHub(Map<String, String> files, String appName, String bundleName) async {
    final saved = WebBridge.read('synappkit_github') ?? '';
    final parts = saved.split('|');
    var repoText = parts.isNotEmpty && parts.first.isNotEmpty ? parts.first : 'owner/repository';
    var branch = parts.length > 1 ? parts[1] : 'synappkit';
    var token = '';
    var remember = parts.length > 2 && parts[2] == '1';
    if (remember) token = WebBridge.read('synappkit_github_token') ?? '';

    final go = await showDialog<bool>(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (c, setLocal) => AlertDialog(
          title: const Text('Push to GitHub'),
          content: SizedBox(
            width: 440,
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const Text('Commits the complete Flutter project to a branch. Use a fine-grained token with “Contents: Read and write” on that repository.'),
              const SizedBox(height: 16),
              EditorField(label: 'Repository (owner/name)', child: EditorTextInput(value: repoText, onChanged: (v) => repoText = v.trim())),
              EditorField(label: 'Branch', help: 'Created from the default branch if it does not exist.', child: EditorTextInput(value: branch, onChanged: (v) => branch = v.trim())),
              EditorField(label: 'Personal access token', child: EditorTextInput(value: token, obscure: true, onChanged: (v) => token = v.trim())),
              Row(children: [
                Checkbox(value: remember, onChanged: (v) => setLocal(() => remember = v ?? false)),
                const Expanded(child: Text('Remember the token in this browser', style: TextStyle(fontSize: 12.5))),
              ]),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
            FilledButton.icon(onPressed: () => Navigator.pop(c, true), icon: const Icon(Icons.commit_rounded, size: 17), label: const Text('Push')),
          ],
        ),
      ),
    );
    if (go != true || !mounted) return;
    final ownerRepo = repoText.split('/');
    if (ownerRepo.length != 2 || token.isEmpty || branch.isEmpty) {
      _toast('Enter owner/name, a branch and a token.');
      return;
    }
    WebBridge.write('synappkit_github', '$repoText|$branch|${remember ? 1 : 0}');
    remember ? WebBridge.write('synappkit_github_token', token) : WebBridge.remove('synappkit_github_token');

    final status = ValueNotifier<String>('Preparing files…');
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        content: Row(children: [
          const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5)),
          const SizedBox(width: 16),
          Expanded(child: ValueListenableBuilder<String>(valueListenable: status, builder: (_, v, __) => Text(v))),
        ]),
      ),
    );
    try {
      final bundle = await ExportBundle.build(files, appName, bundleName);
      final url = await GitHubExporter(token: token, owner: ownerRepo[0], repo: ownerRepo[1]).push(
        bundle,
        branch: branch,
        message: 'Update from SynappKit (${DateTime.now().toLocal().toString().substring(0, 16)})',
        onProgress: (m) => status.value = m,
      );
      if (mounted) Navigator.pop(context);
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('Pushed to GitHub'),
            content: SelectableText(url),
            actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Done'))],
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) _toast('$e');
    }
  }

  Future<void> _downloadProjectAsZip(Map<String, String> files, String appName, String bundleName) async {
    try {
      final zipData = ExportBundle.zip(await ExportBundle.build(files, appName, bundleName));

      if (zipData != null) {
        if (kIsWeb) {
          WebBridge.downloadBytes(zipData, 'flutter_project.zip');
        } else {
          String? outputFile = await FilePicker.platform.saveFile(
            dialogTitle: 'Save Project Zip',
            fileName: 'flutter_project.zip',
            type: FileType.custom,
            allowedExtensions: ['zip'],
          );
          if (outputFile != null) {
            final file = File(outputFile);
            await file.writeAsBytes(zipData);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Project exported successfully!')));
            }
          }
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export error: \$e')));
      }
    }
  }

  void _downloadFile(String fileName, String content) {
    if (kIsWeb) {
      final bytes = utf8.encode(content);
      WebBridge.downloadBytes(bytes, fileName);
    }
  }

  Future<void> _handleLoad() async {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result != null) {
      if (kIsWeb) {
        final jsonStr = utf8.decode(result.files.single.bytes!);
        final node = WidgetNode.fromJson(jsonDecode(jsonStr));
        provider.setRootNode(node);
      } else {
        final file = File(result.files.single.path!);
        final jsonStr = await file.readAsString();
        final node = WidgetNode.fromJson(jsonDecode(jsonStr));
        provider.setRootNode(node);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
        if (!provider.hasUnsavedChanges) return true;

        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Unsaved Changes', style: TextStyle(color: Colors.white)),
            backgroundColor: EditorColors.surfaceHover,
            content: const Text(
              'You have unsaved changes. Do you want to save before leaving?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false), // Cancel
                child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true), // Leave without saving
                child: const Text('Leave Without Saving', style: TextStyle(color: Colors.redAccent)),
              ),
              ElevatedButton(
                onPressed: () async {
                  await provider.saveProjectToSupabase();
                  if (context.mounted) {
                    Navigator.pop(context, true); // Save & Exit
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: EditorColors.accent,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Save & Exit'),
              ),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Focus(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKeyEvent: _handleKeyEvent,
        child: Scaffold(
        backgroundColor: EditorColors.background,
        appBar: TopNavBar(
          onSave: _handleSave,
          onExport: _handleExport,
          onSubmitMarketplace: _handleSubmitMarketplace,
          aiActive: _showAiPanel,
          commentsActive: _showComments,
          onAiBuilder: () {
            final willShow = !_showAiPanel;
            setState(() => _showAiPanel = willShow);
            if (willShow) Provider.of<WidgetTreeProvider>(context, listen: false).selectNode(null);
          },
          onPreview: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProjectPreviewScreen())),
          onNew: () => _showNewDesignDialog(context),
          onLoad: _handleLoad,
          onUndo: () {
            final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
            provider.commandManager.undo();
            provider.notify();
          },
          onRedo: () {
            final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
            provider.commandManager.redo();
            provider.notify();
          },
          onTemplate: () => _showTemplateSelector(context),
          onTheme: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ThemeSettingsScreen())),
          onSettings: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AppSettingsScreen())),
          onLogic: () => _openLogic(),
          onCommandPalette: _openCommandPalette,
          onVersionHistory: () => showVersionHistory(context),
          onComments: () => setState(() => _showComments = !_showComments),
          onStoryboard: () => showStoryboard(context),
          onShortcuts: () => showShortcutsDialog(context),
        ),
        body: Row(
          children: [
            SizedBox(
              width: _sidebarWidth,
              child: WidgetSidebar(
                selectedTab: _selectedSidebarTab,
                onTabSelected: (index) => setState(() => _selectedSidebarTab = index),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onHorizontalDragUpdate: (details) {
                setState(() => _sidebarWidth = (_sidebarWidth + details.delta.dx).clamp(240.0, 480.0));
              },
              child: const MouseRegion(
                cursor: SystemMouseCursors.resizeLeftRight,
                child: SizedBox(width: 5, child: Center(child: VerticalDivider(width: 1))),
              ),
            ),
            Expanded(
              child: Consumer<WidgetTreeProvider>(
                builder: (context, provider, child) {
                  if (provider.rootNode == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      provider.setRootNode(
                        WidgetNode(
                          type: 'Scaffold',
                          properties: {
                            'pageName': 'Home',
                            'appBar': WidgetNode(type: 'AppBar', properties: {
                              'title': WidgetNode(type: 'Text', properties: {'text': 'Home'}),
                            }),
                          },
                          children: [
                            WidgetNode(type: 'SingleChildScrollView', children: [
                              WidgetNode(type: 'Column', children: [
                                WidgetNode(type: 'Text', properties: {'text': 'Hello, World!'}),
                              ]),
                            ]),
                          ],
                        ),
                      );
                    });
                    return const SizedBox.shrink();
                  }
                  return Stack(
                    children: [
                      const CanvasPreview(),
                      if (provider.isAiGenerating)
                        Positioned.fill(
                          child: Container(
                            color: EditorColors.background.withValues(alpha: 0.82),
                            child: const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(width: 44, height: 44, child: CircularProgressIndicator(color: EditorColors.violet, strokeWidth: 3)),
                                  SizedBox(height: 24),
                                  Text('AI is building your UI…', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                                  SizedBox(height: 6),
                                  Text('This usually takes 10–30 seconds.', style: TextStyle(fontSize: 13, color: EditorColors.textMuted)),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            Consumer<WidgetTreeProvider>(
              builder: (context, provider, child) {
                if (provider.selectedNode == null || provider.testMode) return const SizedBox.shrink();
                return Container(
                  width: 330,
                  decoration: const BoxDecoration(
                    color: EditorColors.surface,
                    border: Border(left: BorderSide(color: EditorColors.border)),
                  ),
                  child: PropertiesPanel(),
                );
              },
            ),
            if (_showComments) CommentsPanel(onClose: () => setState(() => _showComments = false)),
            if (_showAiPanel)
              AiPanel(
                onClose: () => setState(() => _showAiPanel = false),
              ),
          ],
        ),
      ),
      ));
  }


  void _handleAddWidget(BuildContext context, String type) {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    final newNode = WidgetTreeEditor.createFromPaletteType(type);

    if (provider.selectedNode != null) {
      provider.addChild(provider.selectedNode!, newNode);
    } else if (provider.rootNode == null) {
      provider.setRootNode(newNode);
    } else {
      provider.addChild(provider.rootNode!, newNode);
    }
  }

  String _generateDartCode(WidgetNode node, {int indent = 0}) {
    return WidgetGeneratorRegistry.generateCode(node, indent: indent);
  }

  String _generateFullDartCode(WidgetNode node) {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    final theme = provider.themeProperties;
    
    return '''import 'package:flutter/material.dart';
import 'dart:ui';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Generated Flutter App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(${theme['primaryColor']}),
          primary: const Color(${theme['primaryColor']}),
          secondary: const Color(${theme['accentColor']}),
          surface: const Color(${theme['backgroundColor']}),
        ),
        scaffoldBackgroundColor: const Color(${theme['scaffoldBackgroundColor'] ?? '0xFFFFFFFF'}),
        fontFamily: '${theme['fontFamily']}',
        useMaterial3: ${theme['useMaterial3'] ?? true},
      ),
      home: const MyGeneratedWidget(),
    );
  }
}

class MyGeneratedWidget extends StatelessWidget {
  const MyGeneratedWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ${_generateDartCode(node, indent: 4)};
  }
}
''';
  }

  Widget _buildActionButton({required IconData icon, required String tooltip, required VoidCallback onPressed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: IconButton(
        icon: Icon(icon, size: 22),
        tooltip: tooltip,
        onPressed: onPressed,
        splashRadius: 24,
        color: Colors.black,
        hoverColor: Colors.white12,
      ),
    );
  }

  void _showCodeDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generated Dart Code'),
        content: SizedBox(
          width: 800,
          height: 600,
          child: Column(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: EditorColors.surfaceRaised, // Slate 800
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      code,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Color(0xFFE2E8F0), // Slate 200
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            icon: const Icon(Icons.copy, size: 18),
            label: const Text('Copy to Clipboard'),
          ),
          if (kIsWeb)
            TextButton.icon(
              onPressed: () {
                final bytes = utf8.encode(code);
                WebBridge.downloadBytes(bytes, 'main.dart');
              },
              icon: const Icon(Icons.download, size: 18),
              label: const Text('Download .dart'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTemplateSelector(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return const TemplateCustomDialog();
      },
    );
  }

  void _showNewDesignDialog(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: 700,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: EditorColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: EditorColors.surfaceRaised, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create New Design',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'How would you like to start your next masterpiece?',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: _buildDesignOptionCard(
                        dialogContext,
                        icon: Icons.create_outlined,
                        title: 'Blank Canvas',
                        description: 'Start from scratch with an empty screen.',
                        color: Colors.blue,
                        onTap: () {
                          Provider.of<WidgetTreeProvider>(dialogContext, listen: false)
                              .setRootNode(WidgetNode(type: 'Scaffold', properties: {}, children: []));
                          Navigator.of(dialogContext).pop();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDesignOptionCard(
                        dialogContext,
                        icon: Icons.view_module_outlined,
                        title: 'Templates',
                        description: 'Choose from a gallery of pre-made layouts.',
                        color: Colors.purple,
                        onTap: () {
                          Navigator.of(dialogContext).pop();
                          _showTemplateSelector(parentContext);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDesignOptionCard(
                        dialogContext,
                        icon: Icons.auto_awesome,
                        title: 'Generate with AI',
                        description: 'Describe what you want and let AI build it.',
                        color: Colors.amber,
                        onTap: () {
                          final provider =
                              Provider.of<WidgetTreeProvider>(parentContext, listen: false);
                          Navigator.of(dialogContext).pop();
                          provider.selectNode(null);
                          showDialog(
                            context: parentContext,
                            builder: (ctx) => const AiPromptDialog(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesignOptionCard(BuildContext context, {required IconData icon, required String title, required String description, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: EditorColors.surfaceRaised,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 