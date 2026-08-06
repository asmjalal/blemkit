import '../models/widget_node.dart';
import 'widget_generator_registry.dart';
import 'base_widget_generator.dart';
import 'theme_generator.dart';
import '../models/supabase_connection_model.dart';
import '../models/backend_query_model.dart';

class ProjectGenerator {
  static bool isInsideRepeatedList = false;
  static bool generatingNavigationShell = false;
  static List<BackendQuery> activeQueries = [];

  static List<WidgetNode> getTabScreens(List<WidgetNode> screens) {
    final List<WidgetNode> tabs = [];
    for (var s in screens) {
      if (s.type == 'Scaffold') {
        final hasProp = s.properties['bottomNavigationBar'] != null;
        final hasChild = s.children.any((c) => c.type == 'BottomNavigationBar');
        if (hasProp || hasChild) {
          tabs.add(s);
        }
      }
    }
    return tabs;
  }

  static WidgetNode? getBottomNavBarNode(WidgetNode screen) {
    if (screen.properties['bottomNavigationBar'] != null) {
      final data = screen.properties['bottomNavigationBar'];
      if (data is WidgetNode) return data;
      if (data is Map<String, dynamic>) return WidgetNode.fromJson(data);
    }
    for (var child in screen.children) {
      if (child.type == 'BottomNavigationBar') return child;
    }
    return null;
  }

  static bool usesExternalMainNavigation(List<WidgetNode> screens) {
    return getTabScreens(screens).isNotEmpty;
  }

  /// Tab shell with [BottomNavigationBar]; lives in `lib/main_navigation_screen.dart`.
  static String generateMainNavigationScreenFile(List<WidgetNode> screens) {
    final tabScreens = getTabScreens(screens);
    final screenImports = tabScreens.map((s) {
      final fileName = _toFileName(s.id, s.properties['pageName']);
      return "import '$fileName';";
    }).join('\n');

    final screenClasses = tabScreens.map((s) => _toClassName(s.id, s.properties['pageName'])).toList();
    final screenInstances = screenClasses.map((c) => "const $c()").join(',\n          ');

    WidgetNode? navBarNode;
    for (var s in tabScreens) {
      navBarNode = getBottomNavBarNode(s);
      if (navBarNode != null) break;
    }

    String navBarCode = '';
    if (navBarNode != null) {
      generatingNavigationShell = true;
      navBarCode = WidgetGeneratorRegistry.generateCode(navBarNode, indent: 6).trimLeft();
      generatingNavigationShell = false;
    } else {
      navBarCode = '''BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      )''';
    }

    return '''import 'package:flutter/material.dart';
import 'theme.dart';
import 'dart:ui';
$screenImports

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          $screenInstances
        ],
      ),
      bottomNavigationBar: $navBarCode,
    );
  }
}
''';
  }

  static String generateMain(List<WidgetNode> screens, Map<String, dynamic> theme, {SupabaseConnection? connection}) {
    final firstScreenId = screens.isNotEmpty ? screens.first.id : '';
    final firstScreenClass = _toClassName(firstScreenId, screens.first.properties['pageName']);

    final screenImports = screens.map((s) {
      final fileName = _toFileName(s.id, s.properties['pageName']);
      return "import '$fileName';";
    }).join('\n');

    final supabaseInit = connection != null
        ? "  WidgetsFlutterBinding.ensureInitialized();\n  await SupabaseService.initialize();\n"
        : "";
    final supabaseImport = connection != null ? "import 'supabase_service.dart';\n" : "";

    if (usesExternalMainNavigation(screens)) {
      return '''import 'package:flutter/material.dart';
import 'theme.dart';
import 'dart:ui';
import 'main_navigation_screen.dart';
$supabaseImport
void main() async {
$supabaseInit  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Generated Flutter Project',
      theme: AppTheme.lightTheme,
      home: const MainNavigationScreen(),
    );
  }
}
''';
    }

    return '''import 'package:flutter/material.dart';
import 'theme.dart';
import 'dart:ui';
$screenImports
$supabaseImport
void main() async {
$supabaseInit  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Generated Flutter Project',
      theme: AppTheme.lightTheme,
      home: const $firstScreenClass(),
    );
  }
}
''';
  }

  static String _getIconForScreenName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('home') || lower.contains('dash')) return 'Icons.home';
    if (lower.contains('profile') || lower.contains('user') || lower.contains('account')) return 'Icons.person';
    if (lower.contains('set')) return 'Icons.settings';
    if (lower.contains('search')) return 'Icons.search';
    if (lower.contains('cart')) return 'Icons.shopping_cart';
    if (lower.contains('fav')) return 'Icons.favorite';
    if (lower.contains('work') || lower.contains('fit') || lower.contains('train')) return 'Icons.fitness_center';
    if (lower.contains('activ')) return 'Icons.local_activity';
    if (lower.contains('list')) return 'Icons.list_alt';
    if (lower.contains('med')) return 'Icons.medical_services';
    return 'Icons.dashboard';
  }

  static bool isGeneratingTabScreen = false;

  static String generateScreen(WidgetNode node, {SupabaseConnection? connection, bool isTabScreen = false}) {
    final className = _toClassName(node.id, node.properties['pageName']);
    BaseWidgetGenerator.currentGeneratingScreenClass = className;
    BaseWidgetGenerator.stateVariables.clear();
    BaseWidgetGenerator.disposeVariables.clear();
    BaseWidgetGenerator.screenImports.clear();
    isGeneratingTabScreen = isTabScreen;
    final code = WidgetGeneratorRegistry.generateCode(node, indent: 4);
    isGeneratingTabScreen = false;
    
    final stateVars = BaseWidgetGenerator.stateVariables.map((v) => '  $v').join('\n');
    final disposeBody = BaseWidgetGenerator.disposeVariables.map((v) => '    $v').join('\n');
    
    final navigationImports = BaseWidgetGenerator.screenImports.isNotEmpty 
        ? BaseWidgetGenerator.screenImports.map((f) => "import '$f';").join('\n') + '\n'
        : '';

    final supabaseImport = connection != null ? "import 'supabase_service.dart';\n" : "";

    String disposeMethod = '';
    if (BaseWidgetGenerator.disposeVariables.isNotEmpty) {
      disposeMethod = '''
  @override
  void dispose() {
$disposeBody
    super.dispose();
  }
''';
    }

    return '''import 'package:flutter/material.dart';
import 'theme.dart';
import 'dart:ui';
$navigationImports$supabaseImport
class $className extends StatefulWidget {
  final String? idParam;
  const $className({super.key, this.idParam});

  @override
  State<$className> createState() => _${className}State();
}

class _${className}State extends State<$className> {
$stateVars
 
$disposeMethod
  @override
  Widget build(BuildContext context) {
    return ${code.trimLeft()};
  }
}
''';
  }

  static void prepareMapping(List<WidgetNode> screens) {
    final Map<String, String> nameMapping = {};
    final Map<String, String> fileMapping = {};
    for (var screen in screens) {
      nameMapping[screen.id] = _toClassName(screen.id, screen.properties['pageName']);
      fileMapping[screen.id] = _toFileName(screen.id, screen.properties['pageName']);
    }
    BaseWidgetGenerator.idToClassName = nameMapping;
    BaseWidgetGenerator.idToFileName = fileMapping;
  }

  static String _toClassName(String id, String? pageName) {
    final base = pageName ?? id;
    if (base.isEmpty) return 'GeneratedScreen';
    return base.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ').split(' ').map((s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '').join('') + 'Screen';
  }

  static String _toFileName(String id, String? pageName) {
    final base = (pageName ?? id).toLowerCase();
    if (base.isEmpty) return 'generated_screen.dart';
    return base.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_') + '_screen.dart';
  }

  static String generatePubspec(String projectName, {bool includeSupabase = false}) {
    final supabaseDep = includeSupabase ? '\n  supabase_flutter: ^2.12.4' : '';
    return '''name: ${projectName.toLowerCase().replaceAll(' ', '_')}
description: A new Flutter project generated by SynappKit.
version: 1.0.0+1
environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  google_fonts: ^6.1.0
  provider: ^6.1.1
  archive: ^3.4.10$supabaseDep

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
''';
  }

  static String generateAnalysisOptions() {
    return '''include: package:flutter_lints/flutter.yaml

linter:
  rules:
    use_key_in_widget_constructors: false
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
''';
  }

  static String generateGitignore() {
    return '''# Flutter/Dart
.dart_tool/
.packages
.pub-cache/
.pub/
build/

# Web
build/web/

# IDEs
.idea/
.vscode/
*.iml
''';
  }

  static String generateReadme(String projectName) {
    return '''# $projectName

A new Flutter project generated by **SynappKit**.

## Getting Started

1.  Run `flutter pub get` to install dependencies.
2.  Run `flutter run` to launch the application.

Generated with ❤️ by SynappKit.
''';
  }

  static Map<String, String> generateFullProject(
    List<WidgetNode> screens,
    Map<String, dynamic> theme,
    List<Map<String, dynamic>> themedWidgets, {
    String appName = 'GeneratedProject',
    SupabaseConnection? connection,
    List<BackendQuery> queries = const [],
  }) {
    prepareMapping(screens);
    ProjectGenerator.activeQueries = queries;
    final fullTheme = Map<String, dynamic>.from(theme);
    fullTheme['themedWidgets'] = themedWidgets;
    BaseWidgetGenerator.themeProps = fullTheme;
    final Map<String, String> files = {};

    // 0. Project Metadata
    files['pubspec.yaml'] = generatePubspec(appName, includeSupabase: connection != null);
    files['analysis_options.yaml'] = generateAnalysisOptions();
    files['.gitignore'] = generateGitignore();
    files['README.md'] = generateReadme(appName);

    // 1. Lib Core
    files['lib/theme.dart'] = ThemeGenerator.generateThemeCode(theme);
    
    if (connection != null) {
      files['lib/supabase_service.dart'] = _generateSupabaseService(connection, queries);
    }

    if (usesExternalMainNavigation(screens)) {
      files['lib/main_navigation_screen.dart'] = generateMainNavigationScreenFile(screens);
    }
    files['lib/main.dart'] = generateMain(screens, theme, connection: connection);

    // 2. Screens
    final tabScreenIds = getTabScreens(screens).map((s) => s.id).toSet();
    for (var screen in screens) {
      final fileName = _toFileName(screen.id, screen.properties['pageName']);
      final isTabScreen = tabScreenIds.contains(screen.id);
      files['lib/$fileName'] = generateScreen(screen, connection: connection, isTabScreen: isTabScreen);
    }

    // 3. Themed Widget Components
    for (var tw in themedWidgets) {
      final name = (tw['name'] as String?)?.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_') ?? 'component';
      final className = (tw['name'] as String? ?? 'Component')
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ')
          .split(' ')
          .map((s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '')
          .join('');
      files['lib/components/${name}_component.dart'] = _generateComponentCode(tw, className);
    }

    return files;
  }

  static String _generateSupabaseService(SupabaseConnection connection, List<BackendQuery> queries) {
    final queryMethods = queries.map((q) {
      final rawMethodName = q.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ').split(' ').map((s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '').join('');
      final methodName = rawMethodName.isNotEmpty ? rawMethodName[0].toLowerCase() + rawMethodName.substring(1) : 'fetchData';

      String builder = "client.from('${q.tableName}').select('${q.selectColumns}')";
      
      final methodParams = <String>[];
      for (final f in q.filters) {
        final valStr = f.value?.toString() ?? '';
        final isDynamic = f.value == null || 
                          valStr.isEmpty || 
                          valStr == 'idParam' || 
                          valStr == 'widget.idParam' ||
                          (valStr.startsWith('{{') && valStr.endsWith('}}')) ||
                          f.column == 'id' || 
                          f.column.endsWith('_id');
        if (isDynamic) {
          final paramName = '${f.column}Param';
          methodParams.add('String? $paramName');
          builder += ".${f.operator}('${f.column}', $paramName)";
        } else {
          String formattedVal = (f.value is String) ? "'${valStr.replaceAll("'", "\\'")}'" : valStr.toString();
          builder += ".${f.operator}('${f.column}', $formattedVal)";
        }
      }

      if (q.orderBy != null && q.orderBy!.isNotEmpty) {
        builder += ".order('${q.orderBy}', ascending: ${q.ascending})";
      }

      if (q.limit != null) {
        builder += ".limit(${q.limit})";
      }

      final paramsSignature = methodParams.isNotEmpty ? '{${methodParams.join(', ')}}' : '';

      final futureMethod = '''
  Future<List<Map<String, dynamic>>> $methodName($paramsSignature) async {
    try {
      final response = await $builder;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error in $methodName: \$e');
      return [];
    }
  }''';

      if (q.enableRealtime) {
        final streamBuilder = builder.replaceAll(".select('${q.selectColumns}')", ".stream(primaryKey: ['id'])");
        final streamMethod = '''
  Stream<List<Map<String, dynamic>>> stream$rawMethodName($paramsSignature) {
    try {
      // NOTE: Realtime stream requires the primary key to be properly identified.
      // Defaulting to ['id']. You may need to update this if your PK is different.
      return $streamBuilder.map((event) => List<Map<String, dynamic>>.from(event));
    } catch (e) {
      debugPrint('Error in stream$rawMethodName: \$e');
      return Stream.error(e);
    }
  }''';
        return '$futureMethod\n\n$streamMethod';
      }

      return futureMethod;
    }).join('\n\n');

    final mutationMethods = connection.tables.map((table) {
      final tableName = table.name;
      final capitalized = tableName.isNotEmpty ? tableName[0].toUpperCase() + tableName.substring(1) : '';
      
      return '''
  Future<void> insertInto$capitalized(Map<String, dynamic> data) async {
    try {
      await client.from('$tableName').insert(data);
    } catch (e) {
      debugPrint('Error in insertInto$capitalized: \\\$e');
    }
  }

  Future<void> update$capitalized(String? id, Map<String, dynamic> data) async {
    if (id == null) return;
    try {
      await client.from('$tableName').update(data).eq('id', id);
    } catch (e) {
      debugPrint('Error in update$capitalized: \\\$e');
    }
  }

  Future<void> deleteFrom$capitalized(String? id) async {
    if (id == null) return;
    try {
      await client.from('$tableName').delete().eq('id', id);
    } catch (e) {
      debugPrint('Error in deleteFrom$capitalized: \\\$e');
    }
  }''';
    }).join('\n\n');

    return '''import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

class SupabaseService {
  static final SupabaseService instance = SupabaseService._internal();
  factory SupabaseService() => instance;
  SupabaseService._internal();

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: '${connection.projectUrl}',
      anonKey: '${connection.anonKey}',
    );
  }

  SupabaseClient get client => Supabase.instance.client;

$queryMethods

$mutationMethods
}
''';
  }

  static String _generateComponentCode(Map<String, dynamic> tw, String className) {
    final baseType = tw['type'] ?? 'Container';
    final properties = Map<String, dynamic>.from(tw['properties'] ?? {});
    
    final virtualNode = WidgetNode(
      type: baseType,
      properties: properties,
      children: [],
    );
    
    final code = WidgetGeneratorRegistry.generateCode(virtualNode, indent: 4);
    
    return '''import 'package:flutter/material.dart';
import '../theme.dart';
import 'dart:ui';

class ${className}Component extends StatelessWidget {
  final Widget? child;
  const ${className}Component({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return ${code.trimLeft()};
  }
}
''';
  }
}
