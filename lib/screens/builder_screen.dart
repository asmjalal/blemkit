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
import 'dart:html' as html;
import 'package:archive/archive.dart';
import '../widgets/top_nav_bar.dart';
import '../generators/project_generator.dart';
import 'project_preview_screen.dart';
import '../widgets/template_custom_dialog.dart';
import 'theme_settings_screen.dart';
import '../widgets/ai_panel.dart';
import '../widgets/ai_prompt_dialog.dart';
import '../widgets/widget_context_menu/widget_context_menu_actions.dart';

class BuilderScreen extends StatefulWidget {
  const BuilderScreen({super.key});

  @override
  State<BuilderScreen> createState() => _BuilderScreenState();
}

class _BuilderScreenState extends State<BuilderScreen> {
  int _selectedSidebarTab = 0; // 0: Widget Palette, 1: Widget Tree
  double _sidebarWidth = 280.0;
  bool _showAiPanel = false;

  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _keyboardFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    final isCtrl = HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;

    // Delete / Backspace → delete selected node
    if ((event.logicalKey == LogicalKeyboardKey.delete ||
            event.logicalKey == LogicalKeyboardKey.backspace) &&
        !isCtrl) {
      final selected = provider.selectedNode;
      final root = provider.rootNode;
      if (selected != null && root != null && selected.id != root.id) {
        provider.commandManager.executeAction(
          DeleteWidgetAction(node: selected, provider: provider, root: root),
        );
        return KeyEventResult.handled;
      }
    }

    // Ctrl+Z → undo
    if (isCtrl && event.logicalKey == LogicalKeyboardKey.keyZ &&
        !HardwareKeyboard.instance.isShiftPressed) {
      provider.commandManager.undo();
      return KeyEventResult.handled;
    }

    // Ctrl+Y or Ctrl+Shift+Z → redo
    if (isCtrl &&
        (event.logicalKey == LogicalKeyboardKey.keyY ||
            (event.logicalKey == LogicalKeyboardKey.keyZ &&
                HardwareKeyboard.instance.isShiftPressed))) {
      provider.commandManager.redo();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  Future<void> _handleSave() async {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    if (provider.rootNode == null) return;
    final jsonStr = jsonEncode(provider.rootNode!.toJson());
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save your design as JSON',
      fileName: 'design.json',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (outputFile != null) {
      final file = File(outputFile);
      await file.writeAsString(jsonStr);
    }
  }

  void _handleExport() {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    if (provider.screens.isEmpty) return;
    
    String appName = 'My App';
    String bundleName = 'com.example.myapp';
    
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Export Project Settings',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Configure the native application settings before downloading.',
                  style: TextStyle(color: Colors.white54, fontSize: 14),
                ),
                const SizedBox(height: 32),
                Theme(
                  data: ThemeData.dark().copyWith(
                    textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Inter'),
                    inputDecorationTheme: InputDecorationTheme(
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF3B82F6))),
                    ),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(labelText: 'App Name', labelStyle: TextStyle(color: Colors.white54)),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (val) => appName = val,
                        controller: TextEditingController(text: appName),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: const InputDecoration(labelText: 'Bundle ID (e.g. com.example.app)', labelStyle: TextStyle(color: Colors.white54)),
                        style: const TextStyle(color: Colors.white),
                        onChanged: (val) => bundleName = val,
                        controller: TextEditingController(text: bundleName),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        final projectFiles = ProjectGenerator.generateFullProject(
                          provider.screens, 
                          provider.themeProperties, 
                          provider.themedWidgets,
                          appName: appName,
                        );
                        _showProjectExportDialog(context, projectFiles, appName, bundleName);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Generate Export'),
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

  void _showProjectExportDialog(BuildContext context, Map<String, String> files, String appName, String bundleName) {
    String selectedFile = files.keys.first;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: const Color(0xFF0F172A),
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
                          color: const Color(0xFF1E293B),
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
                            color: const Color(0xFF1E293B),
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

  Future<void> _downloadProjectAsZip(Map<String, String> files, String appName, String bundleName) async {
    try {
      final baseBytes = await rootBundle.load('assets/base_template.zip');
      final baseArchive = ZipDecoder().decodeBytes(baseBytes.buffer.asUint8List());

      final archive = Archive();
      final safeAppName = appName.toLowerCase().replaceAll(' ', '_');

      // Copy all base template files, EXCEPT strictly generated paths
      for (final file in baseArchive) {
        if (file.isFile) {
          if (!file.name.startsWith('lib/') && 
              file.name != 'pubspec.yaml' && 
              !file.name.startsWith('test/') && 
              file.name != 'README.md' &&
              file.name != 'analysis_options.yaml' &&
              file.name != '.gitignore') {
            
            String contentPath = file.name
                .replaceAll('com/example/base_template', bundleName.replaceAll('.', '/'))
                .replaceAll('base_template', safeAppName);
            
            final ext = file.name.split('.').last;
            final isText = ['xml', 'kt', 'java', 'gradle', 'kts', 'swift', 'pbxproj', 'plist', 'h', 'm', 'sh', 'xcconfig', 'json', 'md', 'yaml'].contains(ext);
            
            List<int> outBytes = file.content as List<int>;
            if (isText) {
                try {
                    String contentStr = utf8.decode(outBytes);
                    contentStr = contentStr.replaceAll('com.example.base_template', bundleName);
                    contentStr = contentStr.replaceAll('base_template', safeAppName);
                    // User-facing name fixes:
                    contentStr = contentStr.replaceAll('android:label="\$safeAppName"', 'android:label="\$appName"');
                    contentStr = contentStr.replaceAll('<string>\$safeAppName</string>', '<string>\$appName</string>');
                    
                    outBytes = utf8.encode(contentStr);
                } catch(e) {
                   // Ignore non-utf8 un-decodable files
                }
            }
            
            archive.addFile(ArchiveFile(contentPath, outBytes.length, outBytes));
          }
        }
      }

      // Add our dynamically generated flutter project code
      files.forEach((filePath, content) {
        final bytes = utf8.encode(content);
        archive.addFile(ArchiveFile(filePath, bytes.length, bytes));
      });

      final encoder = ZipEncoder();
      final zipData = encoder.encode(archive);

      if (zipData != null) {
        if (kIsWeb) {
          final blob = html.Blob([zipData]);
          final url = html.Url.createObjectUrlFromBlob(blob);
          final anchor = html.AnchorElement(href: url)
            ..setAttribute('download', 'flutter_project.zip')
            ..click();
          html.Url.revokeObjectUrl(url);
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
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
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
    return Focus(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: TopNavBar(
        onSave: _handleSave,
        onExport: _handleExport,
        onAiBuilder: () {
          final willShow = !_showAiPanel;
          setState(() {
            _showAiPanel = willShow;
          });
          if (willShow) {
            Provider.of<WidgetTreeProvider>(context, listen: false).selectNode(null);
          }
        },
        onPreview: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProjectPreviewScreen()),
          );
        },
        onNew: () => _showNewDesignDialog(context),
        onLoad: _handleLoad,
        onUndo: () => Provider.of<WidgetTreeProvider>(context, listen: false).commandManager.undo(),
        onRedo: () => Provider.of<WidgetTreeProvider>(context, listen: false).commandManager.redo(),
        onTemplate: () => _showTemplateSelector(context),
        onTheme: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ThemeSettingsScreen()),
          );
        },
      ),
      body: Row(
        children: [
          // Sidebar
          Theme(
            data: ThemeData.dark().copyWith(
              canvasColor: const Color(0xFF0F172A),
              cardColor: const Color(0xFF1E293B),
            ),
            child: SizedBox(
              width: _sidebarWidth,
              child: WidgetSidebar(
                selectedTab: _selectedSidebarTab,
                onTabSelected: (index) {
                  setState(() {
                    _selectedSidebarTab = index;
                  });
                },
              ),
            ),
          ),
          // Resize Divider
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragUpdate: (details) {
              setState(() {
                _sidebarWidth += details.delta.dx;
                if (_sidebarWidth < 200) _sidebarWidth = 200;
                if (_sidebarWidth > 500) _sidebarWidth = 500;
              });
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.resizeLeftRight,
              child: Container(
                width: 4,
                color: Colors.transparent,
                child: Center(
                  child: Container(
                    width: 1,
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),
          ),
          // Canvas Preview (Center)
          Expanded(
            child: Consumer<WidgetTreeProvider>(
              builder: (context, provider, child) {
                if (provider.rootNode == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    provider.setRootNode(
                      WidgetNode(
                        type: 'Scaffold',
                        properties: {
                          'appBar': WidgetNode(
                            type: 'AppBar',
                            properties: {
                              'title': WidgetNode(
                                type: 'Text',
                                properties: {'text': 'App Bar'},
                              ),
                              'backgroundColor': Colors.blue.value.toString(),
                            },
                          ),
                          'backgroundColor': Colors.white.value.toString(),
                        },
                        children: [
                          WidgetNode(
                            type: 'SingleChildScrollView',
                            children: [
                              WidgetNode(
                                type: 'Column',
                                children: [
                                  WidgetNode(type: 'Text', properties: {'text': 'Hello, World!'}),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  });
                  return const SizedBox.shrink();
                }
                return const CanvasPreview();
              },
            ),
          ),
          // Properties Panel (Right Panel) - Only show when a widget is selected
          Consumer<WidgetTreeProvider>(
            builder: (context, provider, child) {
              if (provider.selectedNode == null) {
                return const SizedBox.shrink();
              }
              return Theme(
                data: ThemeData.dark().copyWith(
                  textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Inter'),
                  canvasColor: const Color(0xFF0F172A),
                  cardColor: const Color(0xFF1E293B),
                ),
                child: Container(
                  width: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A), // Match sidebar
                    border: Border(left: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                  ),
                  child: PropertiesPanel(),
                ),
              );
            },
          ),
          // AI Panel (Far Right)
          if (_showAiPanel)
            AiPanel(
              onClose: () {
                setState(() {
                  _showAiPanel = false;
                });
              },
            ),
        ],
      ),
    ),  // closes Scaffold
    );  // closes Focus
  }


  void _handleAddWidget(BuildContext context, String type) {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    
    WidgetNode newNode;
    if (type.startsWith('ThemedWidget:')) {
      final themedId = type.substring('ThemedWidget:'.length);
      newNode = WidgetNode(
        type: 'ThemedWidget',
        properties: {'themedWidgetId': themedId},
      );
    } else {
      newNode = WidgetTreeEditor.createWidgetNodeWithDefaults(type);
    }
    
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
                    color: const Color(0xFF1E293B), // Slate 800
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
                final blob = html.Blob([bytes]);
                final url = html.Url.createObjectUrlFromBlob(blob);
                final anchor = html.AnchorElement(href: url)
                  ..setAttribute('download', 'main.dart')
                  ..click();
                html.Url.revokeObjectUrl(url);
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
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF1E293B), width: 2),
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
          color: const Color(0xFF1E293B),
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