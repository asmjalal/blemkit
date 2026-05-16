import '../models/widget_node.dart';
import 'widget_generator_registry.dart';
import 'base_widget_generator.dart';
import 'theme_generator.dart';

class ProjectGenerator {
  /// Multiple screens without a [BottomNavigationBar] on each [Scaffold] get a
  /// generated shell in [generateMainNavigationScreenFile] — not inlined in main.dart.
  static bool usesExternalMainNavigation(List<WidgetNode> screens) {
    if (screens.length <= 1) return false;
    for (var s in screens) {
      if (s.type == 'Scaffold' && s.properties['bottomNavigationBar'] != null) {
        return false;
      }
    }
    return true;
  }

  /// Tab shell with [BottomNavigationBar]; lives in `lib/main_navigation_screen.dart`.
  static String generateMainNavigationScreenFile(List<WidgetNode> screens) {
    final screenImports = screens.map((s) {
      final fileName = _toFileName(s.id, s.properties['pageName']);
      return "import '$fileName';";
    }).join('\n');

    final screenClasses = screens.map((s) => _toClassName(s.id, s.properties['pageName'])).toList();
    final navItems = screens.map((s) {
      final name = s.properties['pageName'] ?? s.id;
      final icon = _getIconForScreenName(name.toString());
      return "BottomNavigationBarItem(icon: Icon($icon), label: '$name')";
    }).join(',\n          ');

    final screenInstances = screenClasses.map((c) => "const $c()").join(',\n    ');

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

  final List<Widget> _screens = [
    $screenInstances
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          $navItems
        ],
      ),
    );
  }
}
''';
  }

  static String generateMain(List<WidgetNode> screens, Map<String, dynamic> theme) {
    final firstScreenId = screens.isNotEmpty ? screens.first.id : '';
    final firstScreenClass = _toClassName(firstScreenId, screens.first.properties['pageName']);

    final screenImports = screens.map((s) {
      final fileName = _toFileName(s.id, s.properties['pageName']);
      return "import '$fileName';";
    }).join('\n');

    if (usesExternalMainNavigation(screens)) {
      return '''import 'package:flutter/material.dart';
import 'theme.dart';
import 'dart:ui';
import 'main_navigation_screen.dart';

void main() => runApp(const MyApp());

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

void main() => runApp(const MyApp());

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

  static String generateScreen(WidgetNode node) {
    final className = _toClassName(node.id, node.properties['pageName']);
    BaseWidgetGenerator.stateVariables.clear();
    BaseWidgetGenerator.disposeVariables.clear();
    final code = WidgetGeneratorRegistry.generateCode(node, indent: 4);
    
    final stateVars = BaseWidgetGenerator.stateVariables.map((v) => '  $v').join('\n');
    final disposeBody = BaseWidgetGenerator.disposeVariables.map((v) => '    $v').join('\n');
    final isStateful = BaseWidgetGenerator.stateVariables.isNotEmpty || BaseWidgetGenerator.disposeVariables.isNotEmpty;

    if (isStateful) {
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

class $className extends StatefulWidget {
  const $className({super.key});

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

    return '''import 'package:flutter/material.dart';
import 'theme.dart';
import 'dart:ui';

class $className extends StatelessWidget {
  const $className({super.key});

  @override
  Widget build(BuildContext context) {
    return ${code.trimLeft()};
  }
}
''';
  }

  static void prepareMapping(List<WidgetNode> screens) {
    final Map<String, String> mapping = {};
    for (var screen in screens) {
      mapping[screen.id] = _toClassName(screen.id, screen.properties['pageName']);
    }
    BaseWidgetGenerator.idToClassName = mapping;
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

  static String generatePubspec(String projectName) {
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
  archive: ^3.4.10

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

  static Map<String, String> generateFullProject(List<WidgetNode> screens, Map<String, dynamic> theme, List<Map<String, dynamic>> themedWidgets, {String appName = 'GeneratedProject'}) {
    prepareMapping(screens);
    final fullTheme = Map<String, dynamic>.from(theme);
    fullTheme['themedWidgets'] = themedWidgets;
    BaseWidgetGenerator.themeProps = fullTheme;
    final Map<String, String> files = {};

    // 0. Project Metadata
    files['pubspec.yaml'] = generatePubspec(appName);
    files['analysis_options.yaml'] = generateAnalysisOptions();
    files['.gitignore'] = generateGitignore();
    files['README.md'] = generateReadme(appName);

    // 1. Lib Core
    files['lib/theme.dart'] = ThemeGenerator.generateThemeCode(theme);
    if (usesExternalMainNavigation(screens)) {
      files['lib/main_navigation_screen.dart'] = generateMainNavigationScreenFile(screens);
    }
    files['lib/main.dart'] = generateMain(screens, theme);

    // 2. Screens
    for (var screen in screens) {
      final fileName = _toFileName(screen.id, screen.properties['pageName']);
      files['lib/$fileName'] = generateScreen(screen);
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
