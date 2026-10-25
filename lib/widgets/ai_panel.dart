import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/ai_generation_service.dart';
import '../providers/widget_tree_provider.dart';
import 'ai_generation_status_text.dart';
import 'package:file_picker/file_picker.dart';
import '../ui/editor_theme.dart';
import '../ui/editor_widgets.dart';

class AiPanel extends StatefulWidget {
  final VoidCallback onClose;
  
  const AiPanel({super.key, required this.onClose});

  @override
  State<AiPanel> createState() => _AiPanelState();
}

class _AiPanelState extends State<AiPanel> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Map<String, String> _apiKeysMap = {};
  
  bool _isLoading = false;
  bool _isFetchingKeys = true;
  AiAgentType _selectedAgent = AiAgentType.claude;
  
  // Chat History
  final List<Map<String, String>> _messages = [];

  @override
  void initState() {
    super.initState();
    _fetchUserKeys();
  }

  Future<void> _fetchUserKeys() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data();
          if (data != null && data['apiKeys'] != null) {
            final keys = data['apiKeys'];
            if (keys is Map) {
              keys.forEach((key, val) {
                _apiKeysMap[key.toString()] = val.toString();
              });
            }
            String initialAgentStr = data['selectedAi'] ?? 'claude';
            _selectedAgent = AiAgentTypeExtension.fromString(initialAgentStr);
            _apiKeyController.text = _apiKeysMap[_selectedAgent.nameString] ?? '';
          }
        }
      } catch (e) {
        debugPrint('Error fetching keys: $e');
      }
    }
    if (mounted) {
      setState(() => _isFetchingKeys = false);
    }
  }

  Future<void> _saveKey() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final String agentStr = _selectedAgent.nameString;
        final String apiKey = _apiKeyController.text.trim();
        _apiKeysMap[agentStr] = apiKey;
        // Merge with existing keys
        final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnap = await docRef.get();
        Map<String, dynamic> existingKeys = {};
        if (docSnap.exists) {
          final data = docSnap.data();
          if (data != null && data['apiKeys'] is Map) {
            existingKeys = Map<String, dynamic>.from(data['apiKeys'] as Map);
          }
        }
        existingKeys[agentStr] = apiKey;
        await docRef.set({
          'selectedAi': agentStr,
          'apiKeys': existingKeys,
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Error saving key: $e');
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _selectedOnly = false;
  String? _imageBase64;
  String? _imageMediaType;
  String? _imageName;

  static const Map<AiAgentType, String> _agentLabels = {
    AiAgentType.claude: 'Claude Opus 5.5',
    AiAgentType.openai: 'OpenAI GPT-4o',
    AiAgentType.gemini: 'Google Gemini',
    AiAgentType.deepseek: 'DeepSeek',
    AiAgentType.kimi: 'Kimi K2',
  };

  Future<void> _pickScreenshot() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    final file = result?.files.single;
    if (file?.bytes == null) return;
    final ext = (file!.extension ?? 'png').toLowerCase();
    setState(() {
      _imageBase64 = base64Encode(file.bytes!);
      _imageMediaType = ext == 'jpg' || ext == 'jpeg' ? 'image/jpeg' : ext == 'webp' ? 'image/webp' : 'image/png';
      _imageName = file.name;
    });
  }

  Future<void> _generate() async {
    final promptText = _promptController.text.trim();
    if (promptText.isEmpty && _imageBase64 == null) return;
    if (_apiKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add an API key for the selected model first.')));
      return;
    }

    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    final target = provider.selectedNode;
    final editWidget = _selectedOnly && target != null && target.id != provider.selectedScreen?.id;
    final shownPrompt = promptText.isEmpty ? 'Build this screenshot' : promptText;

    setState(() {
      _isLoading = true;
      _messages.add({'role': 'user', 'content': '${editWidget ? '[${target.type}] ' : ''}$shownPrompt${_imageName != null ? '  📎 $_imageName' : ''}'});
    });
    provider.setAiGenerating(true);
    _promptController.clear();
    _scrollToBottom();
    await _saveKey();

    try {
      final currentJson = editWidget
          ? jsonEncode(target.toJson())
          : (provider.rootNode != null && _imageBase64 == null ? jsonEncode(provider.rootNode!.toJson()) : null);

      final generated = await AiGenerationService.generateUi(
        prompt: shownPrompt,
        apiKey: _apiKeyController.text.trim(),
        agentType: _selectedAgent,
        currentJson: currentJson,
        previousMessages: _messages.where((m) => m['role'] != 'user').toList(),
        imageBase64: _imageBase64,
        imageMediaType: _imageMediaType,
        editSelectedWidget: editWidget,
      );

      String summary;
      if (editWidget) {
        provider.replaceNode(target.id, generated.first);
        summary = 'Updated the selected ${target.type}.';
      } else if (generated.length == 1 && provider.selectedScreen != null && _imageBase64 == null) {
        provider.setRootNode(generated.first);
        summary = 'Updated this page.';
      } else {
        for (final screen in generated) {
          provider.addScreen(screen);
        }
        summary = 'Added ${generated.length} page${generated.length == 1 ? '' : 's'}.';
      }
      if (mounted) {
        setState(() {
          _messages.add({'role': 'assistant', 'content': '$summary Ask for more changes. Saved versions are in Version history.'});
          _imageBase64 = null;
          _imageName = null;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _messages.add({'role': 'assistant', 'content': 'Error: ${e.toString().replaceFirst('Exception: ', '')}'}));
        _scrollToBottom();
      }
    } finally {
      provider.setAiGenerating(false);
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final selected = provider.selectedNode;
    final canScope = selected != null && selected.id != provider.selectedScreen?.id;
    return Container(
      width: 360,
      decoration: const BoxDecoration(
        color: EditorColors.surface,
        border: Border(left: BorderSide(color: EditorColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 10, 10),
            child: Row(children: [
              const Icon(Icons.auto_awesome_rounded, color: EditorColors.violet, size: 19),
              const SizedBox(width: 8),
              const Expanded(child: Text('AI Builder', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
              EditorIconButton(icon: Icons.close_rounded, tooltip: 'Close', size: 17, onPressed: widget.onClose),
            ]),
          ),
          if (!_isFetchingKeys)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                EditorDropdown<AiAgentType>(
                  value: _selectedAgent,
                  items: _agentLabels.keys.toList(),
                  label: (a) => _agentLabels[a] ?? a.nameString,
                  onChanged: (val) async {
                    if (val == null) return;
                    setState(() {
                      _apiKeysMap[_selectedAgent.nameString] = _apiKeyController.text.trim();
                      _selectedAgent = val;
                      _apiKeyController.text = _apiKeysMap[val.nameString] ?? '';
                    });
                    await _saveKey();
                  },
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _apiKeyController,
                  obscureText: true,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(hintText: '${_agentLabels[_selectedAgent]} API key', prefixIcon: const Icon(Icons.key_rounded, size: 16)),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  EditorPill(label: 'Whole page', icon: Icons.web_asset_rounded, selected: !_selectedOnly || !canScope, onTap: () => setState(() => _selectedOnly = false)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: EditorPill(
                      label: canScope ? 'Only ${selected.type}' : 'Selected widget',
                      icon: Icons.ads_click_rounded,
                      selected: _selectedOnly && canScope,
                      onTap: canScope ? () => setState(() => _selectedOnly = true) : null,
                    ),
                  ),
                ]),
              ]),
            ),
          const Divider(),
          Expanded(
            child: _messages.isEmpty
                ? const EditorEmptyState(
                    icon: Icons.auto_awesome_rounded,
                    title: 'Describe what to build',
                    message: '“A food delivery home page with categories and restaurant cards”\n“Make this card darker with a rating”\nOr attach a screenshot to recreate it.',
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg['role'] == 'user';
                      final isError = (msg['content'] ?? '').startsWith('Error:');
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: const BoxConstraints(maxWidth: 290),
                          decoration: BoxDecoration(
                            color: isUser ? EditorColors.violet.withValues(alpha: 0.22) : EditorColors.surfaceRaised,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isError ? EditorColors.danger.withValues(alpha: 0.5) : EditorColors.border),
                          ),
                          child: Text(msg['content'] ?? '', style: const TextStyle(fontSize: 13, height: 1.4)),
                        ),
                      );
                    },
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: AiGenerationStatusText(textAlign: TextAlign.start, fontSize: 12),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: EditorColors.border))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              if (_imageName != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(children: [
                    const Icon(Icons.image_outlined, size: 16, color: EditorColors.accent),
                    const SizedBox(width: 6),
                    Expanded(child: Text(_imageName!, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: EditorColors.textMuted))),
                    EditorIconButton(icon: Icons.close_rounded, tooltip: 'Remove', size: 14, onPressed: () => setState(() {
                      _imageBase64 = null;
                      _imageName = null;
                    })),
                  ]),
                ),
              Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                EditorIconButton(icon: Icons.add_photo_alternate_outlined, tooltip: 'Attach a screenshot to recreate', onPressed: _isLoading ? null : _pickScreenshot),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    style: const TextStyle(fontSize: 13.5),
                    maxLines: 4,
                    minLines: 1,
                    onSubmitted: (_) {
                      if (!_isLoading) _generate();
                    },
                    decoration: const InputDecoration(hintText: 'Describe a page or a change…'),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _isLoading ? null : _generate,
                  style: FilledButton.styleFrom(backgroundColor: EditorColors.violet, foregroundColor: Colors.white, padding: const EdgeInsets.all(12), minimumSize: const Size(44, 44)),
                  child: const Icon(Icons.arrow_upward_rounded, size: 18),
                ),
              ]),
            ]),
          ),
        ],
      ),
    );
  }
}
