import 'package:flutter/material.dart';
import '../models/widget_node.dart';
import '../widgets/widget_context_menu/widget_command_manager.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import '../widgets/widget_tree/widget_tree_editor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/supabase_connection_model.dart';
import '../models/backend_query_model.dart';
import '../services/supabase_data_service.dart';

class WidgetTreeProvider extends ChangeNotifier {
  List<WidgetNode> screens = [];
  WidgetNode? selectedScreen;
  WidgetNode? selectedNode;
  WidgetNode? _hoveredNode;
  
  bool hasUnsavedChanges = false;
  String? currentProjectId;

  // Supabase Data Integration State
  SupabaseConnection? activeConnection;
  List<BackendQuery> queries = [];
  final Map<String, List<Map<String, dynamic>>> queryResults = {};
  final Map<String, Stream<List<Map<String, dynamic>>>> activeStreams = {};
  final SupabaseDataService _dataService = SupabaseDataService();
  bool isConnecting = false;
  bool isFetchingSchema = false;

  Map<String, dynamic>? _activeRowData;
  Map<String, dynamic> widgetStates = {};
  Map<String, dynamic>? get activeRowData => _activeRowData;
  set activeRowData(Map<String, dynamic>? val) {
    _activeRowData = val;
    queryResults.clear();
    notifyListeners();
  }

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
    activeConnection = null;
    queries = [];
    queryResults.clear();
    activeStreams.clear();
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

  // Global Project Settings
  Map<String, dynamic> _projectSettings = {
    'projectName': 'Synappkit Project',
    'bundleId': 'com.example.synappkit',
    'version': '1.0.0',
    'buildNumber': '1',
    'platforms': ['android', 'ios', 'web'],
  };

  Map<String, dynamic> get projectSettings => _projectSettings;

  void updateProjectSettings(Map<String, dynamic> newSettings) {
    _projectSettings = {..._projectSettings, ...newSettings};
    hasUnsavedChanges = true;
    _saveToStorage();
    saveProjectSettingsToSupabase();
    notifyListeners();
  }

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
    
    // Check if there's a settings screen
    final settingsIndex = newScreens.indexWhere((s) {
      final pageName = s.properties['pageName'] ?? s.id;
      return pageName == '__settings__';
    });
    
    if (settingsIndex != -1) {
      final settingsNode = newScreens[settingsIndex];
      // Load queries
      if (settingsNode.properties['queries'] != null) {
        try {
          queries = (settingsNode.properties['queries'] as List)
              .map((q) => BackendQuery.fromJson(Map<String, dynamic>.from(q as Map)))
              .toList();
          for (final q in queries) {
            runQuery(q.id);
          }
        } catch (e) {
          debugPrint('Error loading queries from settings: $e');
        }
      }
      
      // Load active connection
      if (settingsNode.properties['activeConnection'] != null) {
        try {
          activeConnection = SupabaseConnection.fromJson(
            Map<String, dynamic>.from(settingsNode.properties['activeConnection'] as Map),
          );
        } catch (e) {
          debugPrint('Error loading activeConnection from settings: $e');
        }
      }
      
      // Remove __settings__ from screens list so it doesn't show in the visual UI
      final list = List<WidgetNode>.from(newScreens);
      list.removeAt(settingsIndex);
      screens = list;
    } else {
      screens = newScreens;
    }

    if (screens.isEmpty) return;
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

  WidgetNode? findNodeById(String id) {
    for (var screen in screens) {
      final found = _findNodeInTree(screen, id);
      if (found != null) return found;
    }
    return null;
  }

  WidgetNode? _findNodeInTree(WidgetNode root, String id) {
    if (root.id == id) return root;
    
    // Check in properties (like title, leading, trailing, etc. which can contain WidgetNodes)
    for (var val in root.properties.values) {
      if (val is WidgetNode) {
        final found = _findNodeInTree(val, id);
        if (found != null) return found;
      } else if (val is List) {
        for (var item in val) {
          if (item is WidgetNode) {
            final found = _findNodeInTree(item, id);
            if (found != null) return found;
          }
        }
      }
    }

    // Check in children
    for (var child in root.children) {
      final found = _findNodeInTree(child, id);
      if (found != null) return found;
    }
    return null;
  }

  void selectNode(WidgetNode? node) {
    if (node == null) {
      selectedNode = null;
    } else {
      selectedNode = findNodeById(node.id) ?? node;
    }
    notifyListeners();
  }

  void addChild(WidgetNode parent, WidgetNode child) {
    if (parent.properties['isSlot'] == true || parent.id.contains('_slot_') || parent.id.contains('_prop_')) {
      final isSlot = parent.properties['isSlot'] == true;
      final slotName = isSlot ? (parent.properties['slotName'] as String) : parent.id.split(parent.id.contains('_slot_') ? '_slot_' : '_prop_')[1];
      final parentId = parent.id.split(parent.id.contains('_slot_') ? '_slot_' : '_prop_')[0];
      final realParent = findNodeById(parentId);
      if (realParent != null) {
        final isList = parent.properties['isList'] == true;
        if (isList) {
          if (realParent.properties[slotName] is List) {
            (realParent.properties[slotName] as List).add(child);
          } else {
            realParent.properties[slotName] = [child];
          }
        } else {
          realParent.properties[slotName] = child;
        }
        hasUnsavedChanges = true;
        notifyListeners();
      }
      return;
    }

    final originalParent = findNodeById(parent.id) ?? parent;
    originalParent.children.add(child);
    hasUnsavedChanges = true;
    notifyListeners();
  }

  void removeNode(WidgetNode node) {
    final originalNode = findNodeById(node.id) ?? node;
    if (originalNode == selectedScreen) {
      selectedScreen = null;
    } else {
      // Find and remove the node from its parent (either in children or in properties)
      bool removeFromParent(WidgetNode parent) {
        // 1. Check children
        final oldLen = parent.children.length;
        parent.children.removeWhere((child) => child.id == originalNode.id);
        if (parent.children.length < oldLen) {
          return true;
        }

        // 2. Check properties
        final keysToUpdate = <String>[];
        parent.properties.forEach((key, value) {
          if (value is WidgetNode && value.id == originalNode.id) {
            keysToUpdate.add(key);
          } else if (value is List) {
            final oldListLen = value.length;
            value.removeWhere((item) => item is WidgetNode && item.id == originalNode.id);
            if (value.length < oldListLen) {
              keysToUpdate.add(key);
            }
          }
        });
        for (var key in keysToUpdate) {
          if (parent.properties[key] is WidgetNode) {
            parent.properties.remove(key);
          }
        }
        if (keysToUpdate.isNotEmpty) return true;

        // 3. Recurse children
        for (var child in parent.children) {
          if (removeFromParent(child)) return true;
        }

        // 4. Recurse properties
        for (var val in parent.properties.values) {
          if (val is WidgetNode) {
            if (removeFromParent(val)) return true;
          } else if (val is List) {
            for (var item in val) {
              if (item is WidgetNode) {
                if (removeFromParent(item)) return true;
              }
            }
          }
        }
        return false;
      }

      if (selectedScreen != null) {
        removeFromParent(selectedScreen!);
      }
    }
    hasUnsavedChanges = true;
    notifyListeners();
  }

  void updateNodeProperties(WidgetNode node, Map<String, dynamic> properties) {
    final originalNode = findNodeById(node.id) ?? node;
    originalNode.properties = properties;
    hasUnsavedChanges = true;
    notifyListeners();
  }

  void moveNode(WidgetNode node, WidgetNode newParent, {int? newIndex}) {
    final originalNode = findNodeById(node.id) ?? node;
    removeNode(originalNode);

    if (newParent.properties['isSlot'] == true || newParent.id.contains('_slot_') || newParent.id.contains('_prop_')) {
      final isSlot = newParent.properties['isSlot'] == true;
      final slotName = isSlot ? (newParent.properties['slotName'] as String) : newParent.id.split(newParent.id.contains('_slot_') ? '_slot_' : '_prop_')[1];
      final parentId = newParent.id.split(newParent.id.contains('_slot_') ? '_slot_' : '_prop_')[0];
      final realParent = findNodeById(parentId);
      if (realParent != null) {
        final isList = newParent.properties['isList'] == true;
        if (isList) {
          if (realParent.properties[slotName] is List) {
            final list = realParent.properties[slotName] as List;
            if (newIndex != null && newIndex <= list.length) {
              list.insert(newIndex, originalNode);
            } else {
              list.add(originalNode);
            }
          } else {
            realParent.properties[slotName] = [originalNode];
          }
        } else {
          realParent.properties[slotName] = originalNode;
        }
      }
    } else {
      final originalParent = findNodeById(newParent.id) ?? newParent;
      if (newIndex != null && newIndex <= originalParent.children.length) {
        originalParent.children.insert(newIndex, originalNode);
      } else {
        originalParent.children.add(originalNode);
      }
    }
    hasUnsavedChanges = true;
    notifyListeners();
  }

  void reorderNode(WidgetNode parent, int oldIndex, int newIndex) {
    final originalParent = findNodeById(parent.id) ?? parent;
    final node = originalParent.children.removeAt(oldIndex);
    originalParent.children.insert(newIndex, node);
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

  void setWidgetState(String widgetId, dynamic value) {
    widgetStates[widgetId] = value;
    // Don't call notifyListeners here as it might trigger rebuild loops for typing.
    // It's just a value store.
  }

  dynamic getWidgetState(String widgetId) {
    return widgetStates[widgetId];
  }

  // void _ensureIdIsUnique(WidgetNode node, Set<String> existingIds) {
  //   node.properties['pageName'] = newName;
  //   hasUnsavedChanges = true;
  //   _saveToStorage();
  //   notifyListeners();
  // }

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
      // Save Project Settings
      html.window.localStorage['${_storageKey}_project_info'] = jsonEncode(_projectSettings);
      // Save Themed Widgets
      html.window.localStorage['${_storageKey}_themed'] = jsonEncode(_themedWidgets);
      
      // Save Supabase Connection
      if (activeConnection != null) {
        html.window.localStorage['${_storageKey}_connection'] = jsonEncode(activeConnection!.toJson());
      } else {
        html.window.localStorage.remove('${_storageKey}_connection');
      }
      // Save Supabase Queries
      html.window.localStorage['${_storageKey}_queries'] = jsonEncode(queries.map((q) => q.toJson()).toList());
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
    // Load Project Settings
    final String? projectStr = html.window.localStorage['${_storageKey}_project_info'];
    if (projectStr != null && projectStr.isNotEmpty) {
      try {
        _projectSettings = jsonDecode(projectStr);
      } catch (e) {
        debugPrint('Error loading project settings from storage: $e');
      }
    }
    // Load Supabase Connection
    final String? connStr = html.window.localStorage['${_storageKey}_connection'];
    if (connStr != null && connStr.isNotEmpty) {
      try {
        activeConnection = SupabaseConnection.fromJson(jsonDecode(connStr));
      } catch (e) {
        debugPrint('Error loading connection from storage: $e');
      }
    }
    // Load Supabase Queries
    final String? queriesStr = html.window.localStorage['${_storageKey}_queries'];
    if (queriesStr != null && queriesStr.isNotEmpty) {
      try {
        queries = (jsonDecode(queriesStr) as List)
            .map((q) => BackendQuery.fromJson(q as Map<String, dynamic>))
            .toList();
        for (final q in queries) {
          runQuery(q.id);
        }
      } catch (e) {
        debugPrint('Error loading queries from storage: $e');
      }
    }
  }

  // --- SUPABASE MVP INTEGRATION ---

  Future<void> saveProjectSettingsToSupabase() async {
    if (currentProjectId == null) return;
    try {
      final supabase = Supabase.instance.client;
      final settingsJson = {
        'activeConnection': activeConnection?.toJson(),
        'queries': queries.map((q) => q.toJson()).toList(),
      };
      
      await supabase.from('screens').upsert({
        'project_id': currentProjectId,
        'screen_name': '__settings__',
        'screen_json': settingsJson,
        'order_index': -1,
      });
    } catch (e) {
      debugPrint('Error saving project settings to Supabase: $e');
    }
  }

  Future<void> loadProjectSettingsFromSupabase(String projectId) async {
    try {
      final supabase = Supabase.instance.client;
      final response = await supabase
          .from('screens')
          .select()
          .eq('project_id', projectId)
          .eq('screen_name', '__settings__')
          .maybeSingle();

      if (response != null && response['screen_json'] != null) {
        final settingsJson = response['screen_json'] as Map<String, dynamic>;
        
        if (settingsJson['activeConnection'] != null) {
          activeConnection = SupabaseConnection.fromJson(settingsJson['activeConnection'] as Map<String, dynamic>);
        } else {
          activeConnection = null;
        }

        if (settingsJson['queries'] != null) {
          queries = (settingsJson['queries'] as List)
              .map((q) => BackendQuery.fromJson(q as Map<String, dynamic>))
              .toList();
        } else {
          queries = [];
        }

        // Run all queries to cache results initially
        for (final q in queries) {
          runQuery(q.id);
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading project settings from Supabase: $e');
    }
  }

  Future<bool> connectDataSource(String name, String url, String anonKey, {String? serviceRoleKey}) async {
    isConnecting = true;
    notifyListeners();
    debugPrint('Attempting to connect Supabase: name=$name, url=$url');
    bool success = false;
    try {
      success = await _dataService.testConnection(url, anonKey);
      debugPrint('Supabase testConnection result: $success');
      if (success) {
        activeConnection = SupabaseConnection(
          id: UniqueKey().toString(),
          projectUrl: url,
          anonKey: anonKey,
          serviceRoleKey: serviceRoleKey,
          name: name,
          createdAt: DateTime.now(),
          isConnected: true,
        );
        debugPrint('Supabase connection established, fetching schema...');
        hasUnsavedChanges = true;
        _saveToStorage();
        await saveProjectSettingsToSupabase();
        await fetchActiveSchema();
        debugPrint('Schema fetched and connection saved.');
      } else {
        debugPrint('Supabase connection failed: testConnection returned false');
      }
    } catch (e) {
      debugPrint('Error during connectDataSource: $e');
      success = false;
    }
    isConnecting = false;
    notifyListeners();
    return success;
  }

  Future<void> fetchActiveSchema() async {
    if (activeConnection == null) return;
    isFetchingSchema = true;
    notifyListeners();
    try {
      final tables = await _dataService.fetchSchema(activeConnection!);
      activeConnection!.tables = tables;
      hasUnsavedChanges = true;
      _saveToStorage();
      await saveProjectSettingsToSupabase();
    } catch (e) {
      debugPrint('Error fetching schema: $e');
    } finally {
      isFetchingSchema = false;
      notifyListeners();
    }
  }

  void disconnectDataSource() {
    activeConnection = null;
    queries = [];
    queryResults.clear();
    activeStreams.clear();
    hasUnsavedChanges = true;
    _saveToStorage();
    saveProjectSettingsToSupabase();
    notifyListeners();
  }

  void addQuery(BackendQuery query) {
    queries.add(query);
    hasUnsavedChanges = true;
    _saveToStorage();
    saveProjectSettingsToSupabase();
    notifyListeners();
    runQuery(query.id);
  }

  void updateQuery(BackendQuery query) {
    final index = queries.indexWhere((q) => q.id == query.id);
    if (index != -1) {
      queries[index] = query;
      hasUnsavedChanges = true;
      _saveToStorage();
      saveProjectSettingsToSupabase();
      notifyListeners();
      runQuery(query.id);
    }
  }

  void removeQuery(String queryId) {
    queries.removeWhere((q) => q.id == queryId);
    queryResults.remove(queryId);
    hasUnsavedChanges = true;
    _saveToStorage();
    saveProjectSettingsToSupabase();
    notifyListeners();
  }

  Future<void> runQuery(String queryId) async {
    final query = queries.where((q) => q.id == queryId).firstOrNull;
    if (query == null || activeConnection == null) return;

    try {
      final results = await _dataService.executeQuery(activeConnection!, query, activeRowData: activeRowData);
      queryResults[queryId] = results;
      notifyListeners();
    } catch (e) {
      debugPrint('Error running query $queryId: $e');
      queryResults[queryId] = []; // Prevent infinite loading loop on query error
      notifyListeners();
    }
  }

  Future<void> saveProjectToSupabase() async {
    if (currentProjectId == null) return;
    
    try {
      final supabase = Supabase.instance.client;
      
      // Update projects updated_at
      await supabase.from('projects').update({
        'updated_at': DateTime.now().toIso8601String()
      }).eq('id', currentProjectId!);

      // Delete existing screens for this project (except __settings__)
      await supabase.from('screens').delete().eq('project_id', currentProjectId!).neq('screen_name', '__settings__');

      // Insert all current screens
      if (screens.isNotEmpty) {
        final screenInserts = screens.asMap().entries.map((entry) {
          final index = entry.key;
          final screen = entry.value;
          return {
            'project_id': currentProjectId,
            'screen_name': screen.properties['pageName'] ?? 'Page ${index + 1}',
            'screen_json': screen.toJson(),
            'order_index': index,
          };
        }).toList();

        await supabase.from('screens').insert(screenInserts);
      }

      await saveProjectSettingsToSupabase();

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
          .neq('screen_name', '__settings__')
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
      
      await loadProjectSettingsFromSupabase(projectId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading project from Supabase: $e');
    }
  }
}