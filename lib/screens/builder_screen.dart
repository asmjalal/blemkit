import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../generators/widget_generator_registry.dart';
import '../providers/widget_tree_provider.dart';
import '../widgets/canvas_preview_new.dart';
import '../widgets/widget_sidebar/widget_side_bar.dart';
import '../widgets/widget_tree/widget_tree_editor.dart';
import '../widgets/properties_panel.dart';
import '../widgets/widget_palette.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import '../models/widget_node.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import '../templates/templates.dart';
import '../widgets/top_nav_bar.dart';

class BuilderScreen extends StatefulWidget {
  const BuilderScreen({super.key});

  @override
  State<BuilderScreen> createState() => _BuilderScreenState();
}

class _BuilderScreenState extends State<BuilderScreen> {
  int _selectedSidebarTab = 0; // 0: Widget Palette, 1: Widget Tree
  double _sidebarWidth = 280.0;

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
    if (provider.rootNode == null) return;
    final code = _generateFullDartCode(provider.rootNode!);
    _showCodeDialog(context, code);
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
    return Scaffold(
      appBar: TopNavBar(
        onSave: _handleSave,
        onExport: _handleExport,
        onNew: () => _showNewDesignDialog(context),
        onLoad: _handleLoad,
        onTemplate: () => _showTemplateSelector(context),
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
                              ).toJson(),
                              'backgroundColor': Colors.blue.value.toString(),
                            },
                          ).toJson(),
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
        ],
      ),
    );
  }

  void _handleAddWidget(BuildContext context, String type) {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    final WidgetNode newNode = WidgetTreeEditor.createWidgetNodeWithDefaults(type);
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
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose a Template'),
          content: SizedBox(
            width: 400,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                return ListTile(
                  leading: Icon(template.icon),
                  title: Text(template.name),
                  onTap: () async {
                    try {
                      // Load template from JSON file
                      final templateNode = await TemplateService.loadTemplate(template.jsonPath);
                      Provider.of<WidgetTreeProvider>(context, listen: false)
                          .setRootNode(templateNode.copy());
                      Navigator.of(context).pop();
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error loading template: $e')),
                        );
                      }
                    }
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showNewDesignDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Start New Design'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.create),
                title: const Text('Start from scratch'),
                onTap: () {
                  Provider.of<WidgetTreeProvider>(context, listen: false)
                      .setRootNode(WidgetNode(type: 'Scaffold', properties: {}, children: []));
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.view_module),
                title: const Text('Choose a template'),
                onTap: () {
                  Navigator.of(context).pop();
                  _showTemplateSelector(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
} 