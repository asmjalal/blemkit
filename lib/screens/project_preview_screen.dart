import 'package:flutter/material.dart';
import '../ui/editor_theme.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/widget_tree_provider.dart';
import '../generators/project_generator.dart';
import '../widgets/canvas_preview_new.dart';

class ProjectPreviewScreen extends StatefulWidget {
  const ProjectPreviewScreen({super.key});

  @override
  State<ProjectPreviewScreen> createState() => _ProjectPreviewScreenState();
}

class _ProjectPreviewScreenState extends State<ProjectPreviewScreen> {
  String? _selectedFile;
  Map<String, String> _projectFiles = {};
  String? _lastSelectedScreenId;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);

    if (provider.screens.isNotEmpty) {
      _projectFiles = ProjectGenerator.generateFullProject(
        provider.screens,
        provider.themeProperties,
        provider.themedWidgets,
        appName: '${provider.projectSettings['projectName'] ?? 'GeneratedProject'}',
        connection: provider.activeConnection,
        queries: provider.queries,
        logic: provider.logic,
        components: provider.components,
      );

      // Auto-initialize selected file if null
      if (_selectedFile == null && _projectFiles.isNotEmpty) {
        _selectedFile = _projectFiles.keys.first;
      }

      // Sync selection with active screen if it changed in provider
      final activeScreen = provider.selectedScreen;
      if (activeScreen != null && activeScreen.id != _lastSelectedScreenId) {
        _lastSelectedScreenId = activeScreen.id;
        final expectedFileName = ProjectGenerator.screenFilePath(provider.screens, activeScreen);
        if (_projectFiles.containsKey(expectedFileName)) {
          _selectedFile = expectedFileName;
        }
      }
    }

    return Scaffold(
      backgroundColor: EditorColors.surface,
      appBar: AppBar(
        backgroundColor: EditorColors.surface,
        title: const Text('Project Preview & Code', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            tooltip: 'Regenerate Code',
            onPressed: () => setState(() {}),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Left Sidebar: Screen/File List
          _buildFileList(),
          
          // 2. Center: Code Viewer
          Expanded(
            flex: 4,
            child: _buildCodeViewer(),
          ),
          
          // 3. Right: Live Canvas Preview
          Expanded(
            flex: 3,
            child: _buildLivePreview(),
          ),
        ],
      ),
    );
  }

  Widget _buildFileList() {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: EditorColors.surface,
        border: Border(right: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('PROJECT FILES', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _projectFiles.length,
              itemBuilder: (context, index) {
                final fileName = _projectFiles.keys.elementAt(index);
                final isSelected = fileName == _selectedFile;
                final isMain = fileName == 'main.dart';

                return ListTile(
                  dense: true,
                  horizontalTitleGap: 0,
                  leading: Icon(
                    isMain ? Icons.settings : Icons.description_outlined,
                    size: 18,
                    color: isSelected ? Colors.blue : Colors.white38,
                  ),
                  title: Text(
                    fileName,
                    style: TextStyle(
                      color: isSelected ? Colors.blue : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedFile = fileName;
                      
                      // Also update the active screen in the provider if it's a screen file
                      if (!isMain) {
                        final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
                        final screenName = fileName.replaceAll('_screen.dart', '').replaceAll('_', ' ');
                        try {
                          final screen = provider.screens.firstWhere(
                            (s) => (s.properties['pageName'] ?? s.id).toString().toLowerCase() == screenName.toLowerCase()
                          );
                          provider.selectScreen(screen);
                        } catch (_) {}
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeViewer() {
    if (_selectedFile == null) return const Center(child: Text('Select a file to view code', style: TextStyle(color: Colors.white30)));
    
    return Container(
      color: EditorColors.surfaceRaised,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: EditorColors.surfaceRaised,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_selectedFile!, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600, fontSize: 13)),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16, color: Colors.white38),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _projectFiles[_selectedFile!]!));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)));
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white10),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                _projectFiles[_selectedFile!]!,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  color: Color(0xFFE2E8F0),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLivePreview() {
    return Container(
      decoration: const BoxDecoration(
        color: EditorColors.surface,
        border: Border(left: BorderSide(color: Colors.white12)),
      ),
      child: Column(
        children: [
           const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text('LIVE PREVIEW', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          ),
          Expanded(
            child: Transform.scale(
              scale: 0.85,
              child: const CanvasPreview(isLivePreview: true),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
