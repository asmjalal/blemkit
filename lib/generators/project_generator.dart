import '../models/widget_node.dart';
import 'widget_generator_registry.dart';
import 'base_widget_generator.dart';
import 'theme_generator.dart';
import '../models/supabase_connection_model.dart';
import '../models/backend_query_model.dart';
import '../models/project_logic.dart';
import 'logic_codegen.dart';
import 'runtime_sources.g.dart';

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
    final logic = LogicCodegen.logic;
    final firstScreen = _initialScreen(screens);
    final firstScreenClass = _toClassName(firstScreen.id, firstScreen.properties['pageName']);
    final useShell = usesExternalMainNavigation(screens);
    final useAuthGate = connection != null && logic.usesAuth && logic.loginPageId != null && _screenById(screens, logic.loginPageId) != null;

    final imports = <String>{
      "import 'package:flutter/material.dart';",
      "import 'theme.dart';",
      "import 'app_state.dart';",
      if (connection != null) "import 'supabase_service.dart';",
      if (useAuthGate) "import 'auth_gate.dart';" else if (useShell) "import 'main_navigation_screen.dart';" else "import '${_toFileName(firstScreen.id, firstScreen.properties['pageName'])}';",
    };
    final home = useAuthGate ? 'const AuthGate()' : useShell ? 'const MainNavigationScreen()' : 'const $firstScreenClass()';
    final rtlBuilder = logic.rtl
        ? "\n          builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),"
        : '';
    final appName = (_projectName.isEmpty ? 'Generated Flutter Project' : _projectName).replaceAll("'", r"\'");

    return '''${imports.join('\n')}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
${connection != null ? '  await SupabaseService.initialize();\n' : ''}  await AppState.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppState.instance,
      builder: (context, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '$appName',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: AppState.instance.themeMode,$rtlBuilder
          home: $home,
        ),
    );
  }
}
''';
  }

  static WidgetNode? _screenById(List<WidgetNode> screens, String? id) => screens.where((s) => s.id == id).firstOrNull;

  /// The page the app opens on: the configured home page, else the first page.
  static WidgetNode _initialScreen(List<WidgetNode> screens) =>
      _screenById(screens, LogicCodegen.logic.homePageId) ?? screens.first;

  static String _projectName = '';

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

  /// Generates a reusable component as `lib/components/<name>_component.dart`.
  static String generateComponent(WidgetNode node, {SupabaseConnection? connection}) {
    final code = generateScreen(node, connection: connection, className: componentClassName(node));
    // Component files live one folder down; make relative imports point up.
    return code.replaceAllMapped(RegExp(r"import '(?!package:|dart:)([^']+)';"), (m) => "import '../${m[1]}';");
  }

  static String componentClassName(WidgetNode node) =>
      '${LogicCodegen.typeName(PageLogic.componentName(node.properties) ?? 'Component')}Component';

  static String componentFileName(WidgetNode node) =>
      '${LogicCodegen.typeName(PageLogic.componentName(node.properties) ?? 'Component').replaceAllMapped(RegExp(r'(?<=[a-z0-9])([A-Z])'), (m) => '_${m[1]}').toLowerCase()}_component.dart';

  /// Components by id for `ComponentInstance` generation.
  static Map<String, WidgetNode> componentsById = {};

  static String generateScreen(WidgetNode node, {SupabaseConnection? connection, bool isTabScreen = false, String? className}) {
    className ??= _toClassName(node.id, node.properties['pageName']);
    BaseWidgetGenerator.currentGeneratingScreenClass = className;
    BaseWidgetGenerator.stateVariables.clear();
    BaseWidgetGenerator.disposeVariables.clear();
    BaseWidgetGenerator.screenImports.clear();
    LogicCodegen.beginScreen(node.properties);
    currentScreenRootId = node.id;
    isGeneratingTabScreen = isTabScreen;
    final code = WidgetGeneratorRegistry.generateCode(node, indent: 6);
    final onLoad = PageLogic.onPageLoad(node.properties);
    final onLoadCode = LogicCodegen.hasActions(onLoad) ? LogicCodegen.statements(onLoad, indent: '      ') : '';
    isGeneratingTabScreen = false;

    final pageParams = LogicCodegen.pageParams;
    final pageState = LogicCodegen.pageState;

    final declared = BaseWidgetGenerator.stateVariables.join('\n');
    final extraWidgetVars = LogicCodegen.widgetStateVars.entries
        .where((e) => !declared.contains(' ${e.key} ') && !declared.contains(' ${e.key};'))
        .map((e) => e.value);
    final stateVars = [
      'final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();',
      ...pageState.map((f) => '${LogicCodegen.fieldType(f)} _${LogicCodegen.ident(f.name)} = ${LogicCodegen.literal(f.defaultValue, f.type, isList: f.isList)};'),
      ...BaseWidgetGenerator.stateVariables,
      ...extraWidgetVars,
    ].map((v) => '  $v').join('\n');
    final disposeBody = BaseWidgetGenerator.disposeVariables.map((v) => '    $v').join('\n');

    final paramFields = pageParams
        .map((p) => '  final ${LogicCodegen.fieldType(p)}${p.required ? '' : '?'} ${LogicCodegen.ident(p.name)};')
        .join('\n');
    final ctorParams = [
      'super.key',
      'this.idParam',
      ...pageParams.map((p) => p.required ? 'required this.${LogicCodegen.ident(p.name)}' : 'this.${LogicCodegen.ident(p.name)}'),
    ].join(', ');

    final imports = <String>{
      "import 'package:flutter/material.dart';",
      "import 'theme.dart';",
      "import 'synapp/synapp_widgets.dart';",
      if (connection != null) "import 'supabase_service.dart';",
      ...BaseWidgetGenerator.screenImports.map((f) => "import '$f';"),
      ...LogicCodegen.imports.map((f) => "import '$f';"),
    }.toList()
      ..sort((a, b) => a.compareTo(b));

    final initState = onLoadCode.trim().isEmpty
        ? ''
        : '''
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _onPageLoad());
  }

  Future<void> _onPageLoad() async {
    if (!mounted) return;
$onLoadCode
  }
''';

    final disposeMethod = BaseWidgetGenerator.disposeVariables.isEmpty
        ? ''
        : '''
  @override
  void dispose() {
$disposeBody
    super.dispose();
  }
''';

    final usesAppState = LogicCodegen.imports.contains('app_state.dart') || code.contains('AppState.instance');
    final body = usesAppState
        ? 'return ListenableBuilder(\n      listenable: AppState.instance,\n      builder: (context, _) => ${code.trimLeft()},\n    );'
        : 'return ${code.trimLeft()};';
    if (usesAppState && !imports.contains("import 'app_state.dart';")) imports.add("import 'app_state.dart';");

    return '''// ignore_for_file: unused_field, unused_element, unused_import
${imports.join('\n')}

class $className extends StatefulWidget {
  final String? idParam;
$paramFields
  const $className({$ctorParams});

  @override
  State<$className> createState() => _${className}State();
}

class _${className}State extends State<$className> {
$stateVars
$initState$disposeMethod
  @override
  Widget build(BuildContext context) {
    $body
  }
}
''';
  }

  /// Id of the screen being generated; its root Scaffold gets `_scaffoldKey`.
  static String? currentScreenRootId;

  /// Nesting depth of generated query builders (`data` is in scope when > 0).
  static int queryBuilderDepth = 0;

  static Map<String, List<FieldDef>> _pageParamsById = {};

  static List<FieldDef> pageParamsFor(String screenId) => _pageParamsById[screenId] ?? const [];

  static void prepareMapping(List<WidgetNode> screens) {
    _orderedScreens = List.of(screens);
    final Map<String, String> nameMapping = {};
    final Map<String, String> fileMapping = {};
    for (var screen in screens) {
      nameMapping[screen.id] = _toClassName(screen.id, screen.properties['pageName']);
      fileMapping[screen.id] = _toFileName(screen.id, screen.properties['pageName']);
    }
    BaseWidgetGenerator.idToClassName = nameMapping;
    BaseWidgetGenerator.idToFileName = fileMapping;
  }

  /// Screens without a usable name fall back to `Page<n>` based on their position.
  static List<WidgetNode> _orderedScreens = [];

  static String _baseName(String id, String? pageName) {
    final cleaned = (pageName ?? '').replaceAll(RegExp(r'[^a-zA-Z0-9]+'), ' ').trim();
    if (cleaned.isNotEmpty && RegExp(r'^[a-zA-Z]').hasMatch(cleaned)) return cleaned;
    final index = _orderedScreens.indexWhere((s) => s.id == id);
    final fallback = 'Page ${index == -1 ? 1 : index + 1}';
    return cleaned.isEmpty ? fallback : '$fallback $cleaned';
  }

  /// Path of the generated file for [screen] inside an export, e.g. `lib/home_screen.dart`.
  static String screenFilePath(List<WidgetNode> screens, WidgetNode screen) {
    _orderedScreens = List.of(screens);
    return 'lib/${_toFileName(screen.id, screen.properties['pageName'])}';
  }

  static String _toClassName(String id, String? pageName) {
    return _baseName(id, pageName).split(' ').map((s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '').join('') + 'Screen';
  }

  static String _toFileName(String id, String? pageName) {
    return _baseName(id, pageName).toLowerCase().replaceAll(' ', '_') + '_screen.dart';
  }

  static String generatePubspec(String projectName, {bool includeSupabase = false}) {
    final logic = LogicCodegen.logic;
    final deps = <String, String>{
      'google_fonts': '^6.1.0',
      'shared_preferences': '^2.2.0',
      if (logic.apiCalls.isNotEmpty) 'http': '^1.2.0',
      if (includeSupabase) 'supabase_flutter': '^2.12.4',
      if (LogicCodegen.packages.contains('url_launcher')) 'url_launcher': '^6.2.0',
      if (LogicCodegen.packages.contains('share_plus')) 'share_plus': '^10.1.0',
      if (LogicCodegen.packages.contains('file_picker')) 'file_picker': '^6.1.1',
      if (LogicCodegen.packages.contains('carousel_slider')) 'carousel_slider': '^5.1.2',
      if (LogicCodegen.packages.contains('expandable')) 'expandable': '^5.0.1',
      if (LogicCodegen.packages.contains('flutter_svg')) 'flutter_svg': '^2.2.3',
    };
    for (final dep in logic.dependencies) {
      if (dep.name.trim().isNotEmpty) deps[dep.name.trim()] = dep.version.trim().isEmpty ? 'any' : dep.version.trim();
    }
    final hasIcon = logic.appIconUrl != null && logic.appIconUrl!.isNotEmpty;
    final iconConfig = hasIcon
        ? '''

flutter_launcher_icons:
  android: true
  ios: true
  web:
    generate: true
  image_path: "assets/app_icon.png"

flutter_native_splash:
  color: "${(logic.splashColor ?? '#FFFFFF')}"
  image: "assets/app_icon.png"
'''
        : '';
    return '''name: ${_packageName(projectName)}
description: A new Flutter project generated by SynappKit.
publish_to: 'none'
version: 1.0.0+1
environment:
  sdk: '>=3.4.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
${deps.entries.map((e) => '  ${e.key}: ${e.value}').join('\n')}

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0${hasIcon ? '\n  flutter_launcher_icons: ^0.14.1\n  flutter_native_splash: ^2.4.1' : ''}

flutter:
  uses-material-design: true${hasIcon ? '\n  assets:\n    - assets/' : ''}$iconConfig''';
  }

  static String _packageName(String projectName) {
    var name = projectName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9_]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
    if (name.isEmpty || RegExp(r'^[0-9]').hasMatch(name)) name = 'app_$name';
    return name;
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
    final logic = LogicCodegen.logic;
    final hasIcon = logic.appIconUrl != null && logic.appIconUrl!.isNotEmpty;
    return '''# $projectName

A Flutter project generated by **SynappKit**.

## Getting started

1. `flutter pub get`
2. `flutter run`
${logic.envValues.isNotEmpty ? '\nChoose an environment with `--dart-define=APP_ENV=${logic.environments.join('|')}` (default: `${logic.activeEnvironment}`).\n' : ''}${hasIcon ? '''
## App icon and splash screen

Save your icon as `assets/app_icon.png` (1024×1024; it was configured from ${logic.appIconUrl}), then run:

```
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```
''' : ''}
## Project layout

- `lib/main.dart` – app entry, theme and initial page
- `lib/*_screen.dart` – one file per page
- `lib/app_state.dart` – app-wide state (persisted values use shared_preferences)
- `lib/theme.dart` – colors, typography, spacing and dark mode
- `lib/synapp/` – SynappKit runtime widgets and helpers
${logic.apiCalls.isNotEmpty ? '- `lib/backend/api_calls.dart` – REST API calls\n' : ''}${logic.dataTypes.isNotEmpty || logic.enums.isNotEmpty ? '- `lib/backend/schema/data_types.dart` – custom data types and enums\n' : ''}${logic.customCode.isNotEmpty ? '- `lib/custom_code/` – your custom functions, actions and widgets\n' : ''}''';
  }

  static Map<String, String> generateFullProject(
    List<WidgetNode> screens,
    Map<String, dynamic> theme,
    List<Map<String, dynamic>> themedWidgets, {
    String appName = 'GeneratedProject',
    SupabaseConnection? connection,
    List<BackendQuery> queries = const [],
    ProjectLogic? logic,
    List<WidgetNode> components = const [],
  }) {
    final projectLogic = logic ?? ProjectLogic();
    componentsById = {for (final c in components) c.id: c};
    LogicCodegen.begin(projectLogic, supabase: connection != null);
    _projectName = appName;
    prepareMapping(screens);
    _pageParamsById = {for (final s in screens) s.id: PageLogic.pageParams(s.properties)};
    ProjectGenerator.activeQueries = queries;
    queryBuilderDepth = 0;
    isInsideRepeatedList = false;
    final fullTheme = Map<String, dynamic>.from(theme);
    fullTheme['themedWidgets'] = themedWidgets;
    BaseWidgetGenerator.themeProps = fullTheme;
    final Map<String, String> files = {};

    // 1. Shared runtime, theme and app state
    files['lib/theme.dart'] = ThemeGenerator.generateThemeCode(theme);
    kRuntimeSources.forEach((name, source) => files['lib/synapp/$name'] = source);
    files['lib/app_state.dart'] = LogicCodegen.appStateFile();
    files['lib/l10n/translations.dart'] = LogicCodegen.translationsFile();
    if (projectLogic.dataTypes.isNotEmpty || projectLogic.enums.isNotEmpty) {
      files['lib/backend/schema/data_types.dart'] = LogicCodegen.dataTypesFile();
    }
    if (projectLogic.apiCalls.isNotEmpty) files['lib/backend/api_calls.dart'] = LogicCodegen.apiCallsFile();
    if (projectLogic.envValues.isNotEmpty) files['lib/env.dart'] = LogicCodegen.envFile();
    if (projectLogic.customCode.any((c) => c.kind == 'function')) {
      files['lib/custom_code/custom_functions.dart'] = LogicCodegen.customFunctionsFile();
    }
    if (projectLogic.customCode.any((c) => c.kind == 'action')) {
      files['lib/custom_code/custom_actions.dart'] = LogicCodegen.customActionsFile();
    }
    for (final w in projectLogic.customCode.where((c) => c.kind == 'widget')) {
      files['lib/custom_code/widgets/${customWidgetFileName(w.name)}'] = LogicCodegen.customWidgetFile(w);
    }

    if (connection != null) {
      files['lib/supabase_service.dart'] = _generateSupabaseService(connection, queries);
    }

    for (final component in components) {
      files['lib/components/${componentFileName(component)}'] = generateComponent(component, connection: connection);
    }

    // 2. Screens (generated before main/pubspec so used packages are known)
    final tabScreenIds = getTabScreens(screens).map((s) => s.id).toSet();
    for (var screen in screens) {
      final fileName = _toFileName(screen.id, screen.properties['pageName']);
      final isTabScreen = tabScreenIds.contains(screen.id);
      files['lib/$fileName'] = generateScreen(screen, connection: connection, isTabScreen: isTabScreen);
    }

    if (usesExternalMainNavigation(screens)) {
      files['lib/main_navigation_screen.dart'] = generateMainNavigationScreenFile(screens);
    }
    final login = _screenById(screens, projectLogic.loginPageId);
    if (connection != null && projectLogic.usesAuth && login != null) {
      final home = usesExternalMainNavigation(screens) ? null : _initialScreen(screens);
      files['lib/auth_gate.dart'] = LogicCodegen.authGateFile(
        _toClassName(login.id, login.properties['pageName']),
        _toFileName(login.id, login.properties['pageName']),
        home == null ? 'MainNavigationScreen' : _toClassName(home.id, home.properties['pageName']),
        home == null ? 'main_navigation_screen.dart' : _toFileName(home.id, home.properties['pageName']),
      );
    }
    files['lib/main.dart'] = generateMain(screens, theme, connection: connection);

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

    // 4. Project metadata
    files['pubspec.yaml'] = generatePubspec(appName, includeSupabase: connection != null);
    files['analysis_options.yaml'] = generateAnalysisOptions();
    files['.gitignore'] = generateGitignore();
    files['README.md'] = generateReadme(appName);

    return files;
  }

  static String customWidgetFileName(String name) =>
      '${LogicCodegen.typeName(name).replaceAllMapped(RegExp(r'(?<=[a-z0-9])([A-Z])'), (m) => '_${m[1]}').toLowerCase()}.dart';

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
      debugPrint('Error in insertInto$capitalized: \$e');
    }
  }

  Future<void> update$capitalized(String? id, Map<String, dynamic> data) async {
    if (id == null) return;
    try {
      await client.from('$tableName').update(data).eq('id', id);
    } catch (e) {
      debugPrint('Error in update$capitalized: \$e');
    }
  }

  Future<void> deleteFrom$capitalized(String? id) async {
    if (id == null) return;
    try {
      await client.from('$tableName').delete().eq('id', id);
    } catch (e) {
      debugPrint('Error in deleteFrom$capitalized: \$e');
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
