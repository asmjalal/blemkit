import 'package:flutter/material.dart';
import '../models/widget_node.dart';
import '../widgets/widget_context_menu/widget_command_manager.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import '../widgets/widget_tree/widget_tree_editor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WidgetTreeProvider extends ChangeNotifier {
  List<WidgetNode> screens = [];
  WidgetNode? selectedScreen;
  WidgetNode? selectedNode;
  WidgetNode? _hoveredNode;
  
  bool hasUnsavedChanges = false;
  String? currentProjectId;

  WidgetNode? get rootNode => selectedScreen;
  WidgetNode? get hoveredNode => _hoveredNode;

  bool _isAiGenerating = false;
  bool get isAiGenerating => _isAiGenerating;

  void setAiGenerating(bool value) {
    _isAiGenerating = value;
    notifyListeners();
  }

  /// Public wrapper for notifyListeners to allow external actions to trigger rebuilds
  void notify() {
    hasUnsavedChanges = true;
    notifyListeners();
  }

  void clearState() {
    screens = [];
    selectedScreen = null;
    selectedNode = null;
    hasUnsavedChanges = false;
    currentProjectId = null;
    notifyListeners();
  }

  final WidgetCommandManager commandManager = WidgetCommandManager();

  // Global Theme properties
  Map<String, dynamic> _themeProperties = {
    // Brand Colors
    'primaryColor': '0xFF0fadd5',    // Indigo 500
    'secondaryColor': '0xFF10B981',  // Emerald 500
    'tertiaryColor': '0xFFF59E0B',   // Amber 500
    'alternateColor': '0xFF64748B',  // Slate 500
    
    // Utility Colors
    'backgroundColor': '0xFFFFFFFF',
    'scaffoldBackgroundColor': '0xFFF8FAFC',
    'primaryText': '0xFF0F172A',
    'secondaryText': '0xFF64748B',
    
    // Semantic Colors
    'successColor': '0xFF22C55E',
    'errorColor': '0xFFEF4444',
    'warningColor': '0xFFF59E0B',
    'infoColor': '0xFF3B82F6',

    // Typography
    'fontFamily': 'Outfit',
    'secondaryFontFamily': 'Figtree',
    'useMaterial3': true,
    
    // Text Styles (Simplified for now)
    'displayLarge': {'fontSize': 57.0, 'fontWeight': 'Normal', 'letterSpacing': -0.25},
    'displayMedium': {'fontSize': 45.0, 'fontWeight': 'Normal', 'letterSpacing': 0.0},
    'displaySmall': {'fontSize': 36.0, 'fontWeight': 'Normal', 'letterSpacing': 0.0},
    'headlineLarge': {'fontSize': 32.0, 'fontWeight': 'Normal', 'letterSpacing': 0.0},
    'headlineMedium': {'fontSize': 28.0, 'fontWeight': 'Normal', 'letterSpacing': 0.0},
    'headlineSmall': {'fontSize': 24.0, 'fontWeight': 'Normal', 'letterSpacing': 0.0},
    'titleLarge': {'fontSize': 22.0, 'fontWeight': 'Normal', 'letterSpacing': 0.0},
    'titleMedium': {'fontSize': 16.0, 'fontWeight': 'Medium', 'letterSpacing': 0.15},
    'titleSmall': {'fontSize': 14.0, 'fontWeight': 'Medium', 'letterSpacing': 0.1},
    'labelLarge': {'fontSize': 14.0, 'fontWeight': 'Medium', 'letterSpacing': 0.1},
    'bodyLarge': {'fontSize': 16.0, 'fontWeight': 'Normal', 'letterSpacing': 0.5},
    'bodyMedium': {'fontSize': 14.0, 'fontWeight': 'Normal', 'letterSpacing': 0.25},
    'bodySmall': {'fontSize': 12.0, 'fontWeight': 'Normal', 'letterSpacing': 0.4},
  };

  Map<String, dynamic> get themeProperties => _themeProperties;

  // Global API settings
  Map<String, dynamic> _apiSettings = {
    'url': '',
    'apiKey': '',
    'method': 'GET',
    'headers': {},
  };

  Map<String, dynamic> get apiSettings => _apiSettings;

  // Custom Themed Widgets (Components)
  List<Map<String, dynamic>> _themedWidgets = [];
  List<Map<String, dynamic>> get themedWidgets => _themedWidgets;

  void addThemedWidget(Map<String, dynamic> widget) {
    _themedWidgets.add(widget);
    _saveToStorage();
    notifyListeners();
  }

  void updateThemedWidget(String id, Map<String, dynamic> properties) {
    final idx = _themedWidgets.indexWhere((w) => w['id'] == id);
    if (idx != -1) {
      _themedWidgets[idx]['properties'] = properties;
      _saveToStorage();
      notifyListeners();
    }
  }

  void removeThemedWidget(String id) {
    _themedWidgets.removeWhere((w) => w['id'] == id);
    _saveToStorage();
    notifyListeners();
  }

  void setRootNode(WidgetNode? node) {
    if (selectedScreen == null && node != null) {
      screens.add(node);
      selectedScreen = node;
    } else if (selectedScreen != null && node != null) {
      final idx = screens.indexOf(selectedScreen!);
      if (idx != -1) screens[idx] = node;
      selectedScreen = node;
    } else if (node == null && selectedScreen != null) {
      screens.remove(selectedScreen);
      selectedScreen = screens.isNotEmpty ? screens.first : null;
    }
    hasUnsavedChanges = true;
    _saveToStorage();
    notifyListeners();
  }

  void setProject(List<WidgetNode> newScreens) {
    if (newScreens.isEmpty) return;
    screens = newScreens;
    selectedScreen = screens.first;
    selectedNode = selectedScreen;
    hasUnsavedChanges = true;
    _saveToStorage();
    notifyListeners();
  }

  void addScreen(WidgetNode node) {
    screens.add(node);
    selectedScreen = node;
    selectedNode = node;
    hasUnsavedChanges = true;
    notifyListeners();
  }

  void addNode(String type, {WidgetNode? parent}) {
    final newNode = WidgetTreeEditor.createWidgetNodeWithDefaults(type);
    if (parent != null) {
      addChild(parent, newNode);
    } else if (rootNode == null) {
      setRootNode(newNode);
    } else {
      addChild(rootNode!, newNode);
    }
    hasUnsavedChanges = true;
  }

  void selectScreen(WidgetNode node) {
    selectedScreen = node;
    selectedNode = node;
    notifyListeners();
  }

  void removeScreen(WidgetNode node) {
    screens.removeWhere((s) => s.id == node.id);
    if (selectedScreen?.id == node.id) {
      selectedScreen = screens.isNotEmpty ? screens.first : null;
      selectedNode = selectedScreen;
    }
    hasUnsavedChanges = true;
    notifyListeners();
  }

  void selectNode(WidgetNode? node) {
    selectedNode = node;
    notifyListeners();
  }

  void addChild(WidgetNode parent, WidgetNode child) {
    parent.children.add(child);
    hasUnsavedChanges = true;
    notifyListeners();
  }

  void removeNode(WidgetNode node) {
    if (node == selectedScreen) {
      selectedScreen = null;
    } else {
      // Find and remove the node from its parent
      void removeFromParent(WidgetNode parent) {
        parent.children.removeWhere((child) {
          if (child == node) {
            return true;
          }
          removeFromParent(child);
          return false;
        });
      }
      if (selectedScreen != null) {
        removeFromParent(selectedScreen!);
      }
    }
    hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateNodeProperties(WidgetNode node, Map<String, dynamic> properties) {
    node.properties = properties;
    hasUnsavedChanges = true;
    notifyListeners();
  }

  void moveNode(WidgetNode node, WidgetNode newParent, {int? newIndex}) {
    removeNode(node);
    if (newIndex != null) {
      newParent.children.insert(newIndex, node);
    } else {
      newParent.children.add(node);
    }
    hasUnsavedChanges = true;
    notifyListeners();
  }

  void reorderNode(WidgetNode parent, int oldIndex, int newIndex) {
    final node = parent.children.removeAt(oldIndex);
    parent.children.insert(newIndex, node);
    hasUnsavedChanges = true;
    notifyListeners();
  }

  void setHoveredNode(WidgetNode? node) {
    _hoveredNode = node;
    notifyListeners();
  }

  void updateThemeProperties(Map<String, dynamic> newProperties) {
    _themeProperties = {..._themeProperties, ...newProperties};
    hasUnsavedChanges = true;
    _saveToStorage();
    notifyListeners();
  }

  void updateApiSettings(Map<String, dynamic> newSettings) {
    _apiSettings = {..._apiSettings, ...newSettings};
    _saveToStorage();
    notifyListeners();
  }

  void duplicateScreen(WidgetNode node) {
    final newNode = node.copy();
    newNode.properties['pageName'] = '${node.properties['pageName'] ?? 'Page'} (Copy)';
    screens.add(newNode);
    selectedScreen = newNode;
    selectedNode = newNode;
    hasUnsavedChanges = true;
    _saveToStorage();
    notifyListeners();
  }

  void renameScreen(WidgetNode node, String newName) {
    node.properties['pageName'] = newName;
    hasUnsavedChanges = true;
    _saveToStorage();
    notifyListeners();
  }

  static const String _storageKey = 'design_flutter_kit_root';

  void _saveToStorage() {
    if (!kIsWeb) return;
    try {
      if (screens.isNotEmpty) {
        final List<Map<String, dynamic>> screensJson = screens.map((s) => s.toJson()).toList();
        html.window.localStorage[_storageKey] = jsonEncode(screensJson);
        
        if (selectedScreen != null) {
          html.window.localStorage['${_storageKey}_active'] = selectedScreen!.id;
        }
      }
      // Save theme
      html.window.localStorage['${_storageKey}_theme'] = jsonEncode(_themeProperties);
      // Save API
      html.window.localStorage['${_storageKey}_api'] = jsonEncode(_apiSettings);
      // Save Themed Widgets
      html.window.localStorage['${_storageKey}_themed'] = jsonEncode(_themedWidgets);
    } catch (e) {
      debugPrint('Error saving to storage: $e');
    }
  }

  void loadFromStorage() {
    if (!kIsWeb) return;
    final String? jsonStr = html.window.localStorage[_storageKey];
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(jsonStr);
        if (decoded is List) {
          screens = decoded.map((s) => WidgetNode.fromJson(s as Map<String, dynamic>)).toList();
          
          final String? activeId = html.window.localStorage['${_storageKey}_active'];
          if (activeId != null) {
            selectedScreen = screens.firstWhere((s) => s.id == activeId, orElse: () => screens.first);
          } else if (screens.isNotEmpty) {
            selectedScreen = screens.first;
          }
          selectedNode = selectedScreen;
        } else if (decoded is Map<String, dynamic>) {
          // Backward compatibility for single screen
          final node = WidgetNode.fromJson(decoded);
          screens = [node];
          selectedScreen = node;
          selectedNode = node;
        }
      } catch (e) {
        debugPrint('Error loading from storage: $e');
      }
    }
    // Load theme
    final String? themeStr = html.window.localStorage['${_storageKey}_theme'];
    if (themeStr != null && themeStr.isNotEmpty) {
      try {
        _themeProperties = jsonDecode(themeStr);
      } catch (e) {
        debugPrint('Error loading theme from storage: $e');
      }
    }
    // Load Themed Widgets
    final String? themedStr = html.window.localStorage['${_storageKey}_themed'];
    if (themedStr != null && themedStr.isNotEmpty) {
      try {
        _themedWidgets = List<Map<String, dynamic>>.from(jsonDecode(themedStr));
      } catch (e) {
        debugPrint('Error loading themed widgets: $e');
      }
    }
  }

  // --- SUPABASE MVP INTEGRATION ---

  Future<void> saveProjectToSupabase() async {
    if (currentProjectId == null) return;
    
    try {
      final supabase = Supabase.instance.client;
      
      // Update projects updated_at
      await supabase.from('projects').update({
        'updated_at': DateTime.now().toIso8601String()
      }).eq('id', currentProjectId!);

      // Delete existing screens for this project
      await supabase.from('screens').delete().eq('project_id', currentProjectId!);

      // Insert all current screens
      if (screens.isNotEmpty) {
        final screenInserts = screens.asMap().entries.map((entry) {
          final index = entry.key;
          final screen = entry.value;
          return {
            'project_id': currentProjectId,
            'screen_name': screen.properties['pageName'] ?? 'Page \${index + 1}',
            'screen_json': screen.toJson(),
            'order_index': index,
          };
        }).toList();

        await supabase.from('screens').insert(screenInserts);
      }

      hasUnsavedChanges = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving project to Supabase: $e');
    }
  }

  Future<void> loadProjectFromSupabase(String projectId) async {
    try {
      final supabase = Supabase.instance.client;
      
      currentProjectId = projectId;
      hasUnsavedChanges = false;

      final response = await supabase
          .from('screens')
          .select()
          .eq('project_id', projectId)
          .order('order_index', ascending: true);

      final screenRecords = List<Map<String, dynamic>>.from(response);

      if (screenRecords.isNotEmpty) {
        screens = screenRecords.map((record) {
          final json = record['screen_json'] as Map<String, dynamic>;
          return WidgetNode.fromJson(json);
        }).toList();
        
        selectedScreen = screens.first;
        selectedNode = selectedScreen;
      } else {
        screens = [];
        selectedScreen = null;
        selectedNode = null;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading project from Supabase: $e');
    }
  }
}