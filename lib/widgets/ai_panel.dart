import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../services/ai_generation_service.dart';
import '../models/widget_node.dart';
import '../providers/widget_tree_provider.dart';
import 'ai_generation_status_text.dart';

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
  AiAgentType _selectedAgent = AiAgentType.deepseek;
  
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

  Future<void> _generate() async {
    final promptText = _promptController.text.trim();
    if (promptText.isEmpty) return;
    if (_apiKeyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter an API Key')));
      return;
    }

    setState(() {
      _isLoading = true;
      _messages.add({'role': 'user', 'content': promptText});
    });
    
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    provider.setAiGenerating(true);
    
    _promptController.clear();
    _scrollToBottom();
    await _saveKey();

    try {
      String? currentJsonStr;
      
      // If we have an existing root node, pass it as context so the AI can modify it instead of starting from scratch
      if (provider.rootNode != null) {
        currentJsonStr = jsonEncode(provider.rootNode!.toJson());
      }

      final generatedScreens = await AiGenerationService.generateUi(
        prompt: promptText,
        apiKey: _apiKeyController.text.trim(),
        agentType: _selectedAgent,
        currentJson: currentJsonStr,
        previousMessages: _messages.where((m) => m['role'] != 'user').toList(), // Pass previous assistant responses as context
      );

      if (generatedScreens.length == 1 && provider.selectedScreen != null) {
        // If AI returned a single screen and we have one selected, assume it's a modification of the current one
        provider.setRootNode(generatedScreens.first);
      } else {
        // Otherwise, add them as new screens
        for (var screen in generatedScreens) {
          provider.addScreen(screen);
        }
      }
      
      if (mounted) {
        setState(() {
          _messages.add({'role': 'assistant', 'content': 'UI successfully updated! \\n\\n*You can ask me to change colors, add text, or modify the layout.*'});
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add({'role': 'assistant', 'content': 'Error: ${e.toString()}'});
        });
        _scrollToBottom();
      }
    } finally {
      provider.setAiGenerating(false);
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: Border(left: BorderSide(color: Colors.white.withOpacity(0.1))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(-5, 0),
          )
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFF0fadd5), size: 20),
                const SizedBox(width: 8),
                const Text(
                  'AI Builder',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                  onPressed: widget.onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                )
              ],
            ),
          ),
          
          // Settings (Agent & Key)
          if (!_isFetchingKeys)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Text('Model:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<AiAgentType>(
                            dropdownColor: const Color(0xFF1E293B),
                            value: _selectedAgent,
                            isExpanded: true,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                            items: const [
                              DropdownMenuItem(value: AiAgentType.deepseek, child: Text('DeepSeek Chat')),
                              DropdownMenuItem(value: AiAgentType.openai, child: Text('OpenAI GPT-4o')),
                              DropdownMenuItem(value: AiAgentType.kimi, child: Text('Kimi K2')),
                              DropdownMenuItem(value: AiAgentType.gemini, child: Text('Google Gemini')),
                            ],
                            onChanged: (val) async {
                              if (val != null) {
                                setState(() {
                                  _apiKeysMap[_selectedAgent.nameString] = _apiKeyController.text.trim();
                                  _selectedAgent = val;
                                  _apiKeyController.text = _apiKeysMap[val.nameString] ?? '';
                                });
                                await _saveKey();
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: TextField(
                      controller: _apiKeyController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'API Key',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF1E293B),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
          const Divider(height: 1, color: Colors.white12),

          // Chat Area
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    constraints: const BoxConstraints(maxWidth: 280),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF0fadd5) : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                        bottomLeft: !isUser ? const Radius.circular(4) : const Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      msg['content'] ?? '',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                );
              },
            ),
          ),
          
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: const AiGenerationStatusText(
                    textAlign: TextAlign.end,
                    fontSize: 12,
                  ),
                ),
              ),
            ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 3,
                    minLines: 1,
                    onSubmitted: (_) { if(!_isLoading) _generate(); },
                    decoration: InputDecoration(
                      hintText: 'e.g. "Make the button red"',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: const Color(0xFF1E293B),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF0fadd5),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _isLoading ? null : _generate,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
