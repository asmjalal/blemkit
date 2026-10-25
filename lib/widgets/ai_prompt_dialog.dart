import 'package:flutter/material.dart';
import '../ui/editor_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/ai_generation_service.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../providers/widget_tree_provider.dart';
import 'ai_generation_status_text.dart';

class AiPromptDialog extends StatefulWidget {
  const AiPromptDialog({super.key});

  @override
  State<AiPromptDialog> createState() => _AiPromptDialogState();
}

class _AiPromptDialogState extends State<AiPromptDialog> {
  final TextEditingController _promptController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final Map<String, String> _apiKeysMap = {};
  
  bool _isLoading = false;
  bool _isFetchingKeys = true;
  AiAgentType _selectedAgent = AiAgentType.deepseek;

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
            String initialAgentStr = data['selectedAi'] ?? 'deepseek';
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
        // Fetch existing apiKeys map to merge
        final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        final docSnap = await docRef.get();
        Map<String, dynamic> existingKeys = {};
        if (docSnap.exists) {
          final data = docSnap.data();
          if (data != null && data['apiKeys'] is Map) {
            existingKeys = Map<String, dynamic>.from(data['apiKeys'] as Map);
          }
        }
        // Update the map with the new key
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

  Future<void> _generate() async {
    if (_promptController.text.trim().isEmpty) return;
    if (_apiKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter an API Key')));
      return;
    }

    setState(() => _isLoading = true);
    await _saveKey();

    try {
      final generatedScreens = await AiGenerationService.generateUi(
        prompt: _promptController.text,
        apiKey: _apiKeyController.text.trim(),
        agentType: _selectedAgent,
      );

      final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
      
      // If generating from scratch, we might replace everything, but for now we just add them
      for (var screen in generatedScreens) {
        provider.addScreen(screen);
      }
      
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI Generation Successful!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: 600,
        decoration: BoxDecoration(
          color: EditorColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: EditorColors.accent.withOpacity(0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: EditorColors.accent.withOpacity(0.2),
              blurRadius: 40,
            )
          ],
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: EditorColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: EditorColors.accent),
                ),
                const SizedBox(width: 16),
                const Text(
                  'SynappKit AI Builder',
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54),
                )
              ],
            ),
            const SizedBox(height: 32),
            if (_isFetchingKeys)
              const Center(child: CircularProgressIndicator(color: EditorColors.accent))
            else ...[
              // AI Selection
              Row(
                children: [
                  const Text('AI Agent:', style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(width: 16),
                  DropdownButton<AiAgentType>(
                    dropdownColor: EditorColors.surfaceRaised,
                    value: _selectedAgent,
                    style: const TextStyle(color: Colors.white),
                    underline: Container(height: 1, color: EditorColors.accent),
                    items: const [
                      DropdownMenuItem(value: AiAgentType.claude, child: Text('Claude Opus 5.5')),
                      DropdownMenuItem(value: AiAgentType.deepseek, child: Text('DeepSeek Chat')),
                      DropdownMenuItem(value: AiAgentType.openai, child: Text('OpenAI GPT-4o')),
                      DropdownMenuItem(value: AiAgentType.kimi, child: Text('Kimi K2')),
                      DropdownMenuItem(value: AiAgentType.gemini, child: Text('Google Gemini')),
                    ],
                    onChanged: (val) async {
                      if (val != null) {
                        // Preserve current key for the previous agent
                        _apiKeysMap[_selectedAgent.nameString] = _apiKeyController.text.trim();
                        setState(() {
                          _selectedAgent = val;
                          _apiKeyController.text = _apiKeysMap[val.nameString] ?? '';
                        });
                        // Save only if the new API key is not empty
                        if (_apiKeyController.text.trim().isNotEmpty) {
                          await _saveKey();
                        }
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // API Key Input
              TextField(
                controller: _apiKeyController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Your API Key (Saved to Firebase)',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: EditorColors.surfaceRaised,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  prefixIcon: const Icon(Icons.vpn_key, color: Colors.white54),
                ),
              ),
              const SizedBox(height: 24),
              // Prompt Input
              TextField(
                controller: _promptController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'E.g., Create a modern fitness dashboard with a pink background, tracking steps and calories.',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: EditorColors.surfaceRaised,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 32),
              // Generate Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _generate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EditorColors.accent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: _isLoading ? 0 : 8,
                    shadowColor: EditorColors.accent.withOpacity(0.5),
                  ),
                  child: _isLoading
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: AiGenerationStatusText(
                            textAlign: TextAlign.center,
                            fontSize: 15,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bolt),
                            SizedBox(width: 8),
                            Text('Generate UI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
