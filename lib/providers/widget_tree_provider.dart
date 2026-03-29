import 'package:flutter/material.dart';
import '../models/widget_node.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import '../widgets/widget_tree/widget_tree_editor.dart';

class WidgetTreeProvider extends ChangeNotifier {
  List<WidgetNode> screens = [];
  WidgetNode? selectedScreen;
  WidgetNode? selectedNode;
  WidgetNode? _hoveredNode;

  WidgetNode? get rootNode => selectedScreen;
  WidgetNode? get hoveredNode => _hoveredNode;

  // Global Theme properties
  Map<String, dynamic> _themeProperties = {
    'primaryColor': '0xFF6366F1',    // Indigo 500
    'accentColor': '0xFF818CF8',     // Indigo 400
    'backgroundColor': '0xFFFFFFFF',
    'scaffoldBackgroundColor': '0xFFF8FAFC', // Slate 50
    'fontFamily': null,
    'useMaterial3': true,
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
    _saveToStorage();
    notifyListeners();
  }

  void addScreen(WidgetNode node) {
    screens.add(node);
    selectedScreen = node;
    selectedNode = node;
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
    notifyListeners();
  }

  void selectNode(WidgetNode? node) {
    selectedNode = node;
    notifyListeners();
  }

  void addChild(WidgetNode parent, WidgetNode child) {
    parent.children.add(child);
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
    notifyListeners();
  }

  void updateNodeProperties(WidgetNode node, Map<String, dynamic> properties) {
    node.properties = properties;
    notifyListeners();
  }

  void moveNode(WidgetNode node, WidgetNode newParent, {int? newIndex}) {
    removeNode(node);
    if (newIndex != null) {
      newParent.children.insert(newIndex, node);
    } else {
      newParent.children.add(node);
    }
    notifyListeners();
  }

  void reorderNode(WidgetNode parent, int oldIndex, int newIndex) {
    final node = parent.children.removeAt(oldIndex);
    parent.children.insert(newIndex, node);
    notifyListeners();
  }

  void setHoveredNode(WidgetNode? node) {
    _hoveredNode = node;
    notifyListeners();
  }

  void updateThemeProperties(Map<String, dynamic> newProperties) {
    _themeProperties = {..._themeProperties, ...newProperties};
    _saveToStorage();
    notifyListeners();
  }

  void updateApiSettings(Map<String, dynamic> newSettings) {
    _apiSettings = {..._apiSettings, ...newSettings};
    _saveToStorage();
    notifyListeners();
  }

  // Persistence logic
  static const String _storageKey = 'design_flutter_kit_root';

  void _saveToStorage() {
    if (!kIsWeb) return;
    try {
      if (selectedScreen != null) {
        final String jsonStr = jsonEncode(selectedScreen!.toJson());
        html.window.localStorage[_storageKey] = jsonStr;
      }
      // Save theme
      html.window.localStorage['${_storageKey}_theme'] = jsonEncode(_themeProperties);
      // Save API
      html.window.localStorage['${_storageKey}_api'] = jsonEncode(_apiSettings);
    } catch (e) {
      debugPrint('Error saving to storage: $e');
    }
  }

  void loadFromStorage() {
    if (!kIsWeb) return;
    final String? jsonStr = html.window.localStorage[_storageKey];
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final Map<String, dynamic> jsonData = jsonDecode(jsonStr);
        final node = WidgetNode.fromJson(jsonData);
        setRootNode(node);
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
  }
}