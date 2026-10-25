// Dev-only entrypoint that opens app screens without signing in, for UI
// review and screenshots:
//
//   flutter run -d chrome -t tool/ui_preview/main.dart
//
// Pick the screen with the URL fragment: #login, #dashboard, #templates,
// #theme, #settings, or #builder=<template> (a file name from lib/templates).
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

import 'package:designflutterkit/app_config.dart';
import 'package:designflutterkit/ui/editor_theme.dart';
import 'package:designflutterkit/screens/project_logic_screen.dart';
import 'package:designflutterkit/firebase_options.dart';
import 'package:designflutterkit/providers/widget_tree_provider.dart';
import 'package:designflutterkit/screens/app_settings_screen.dart';
import 'package:designflutterkit/screens/builder_screen.dart';
import 'package:designflutterkit/screens/dashboard_screen.dart';
import 'package:designflutterkit/screens/login_screen.dart';
import 'package:designflutterkit/screens/templates_screen.dart';
import 'package:designflutterkit/screens/theme_settings_screen.dart';
import 'package:designflutterkit/templates/templates.dart';
import 'package:designflutterkit/models/widget_node.dart';
import 'package:designflutterkit/widgets/canvas_preview/builders/widget_builder_factory.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}
  try {
    await supabase.Supabase.initialize(url: AppConfig.supabaseUrl, anonKey: AppConfig.supabaseAnonKey);
  } catch (_) {}
  WidgetBuilderFactory.initialize();

  final fragment = Uri.base.fragment;
  final provider = WidgetTreeProvider();
  if (fragment.startsWith('builder') || fragment.startsWith('logic')) {
    final template = fragment.startsWith('builder') && fragment.contains('=') ? fragment.split('=').last : 'food_delivery';
    final loaded = await TemplateService.loadTemplate('lib/templates/$template.json');
    provider.setProject(loaded is List<WidgetNode> ? loaded : [loaded as WidgetNode]);
  }

  runApp(ChangeNotifierProvider.value(
    value: provider,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: EditorTheme.dark(),
      home: switch (fragment.split('=').first) {
        'login' => const LoginScreen(),
        'dashboard' => DashboardScreen(previewProjects: [
            for (final (name, days) in const [('Food Delivery', 0), ('Banking Dashboard', 1), ('Fitness Tracker', 3), ('Notes', 9), ('Shop', 30)])
              {'id': name, 'project_name': name, 'updated_at': DateTime.now().subtract(Duration(days: days, hours: 2)).toIso8601String()},
          ]),
        'templates' => const TemplatesScreen(),
        'theme' => const ThemeSettingsScreen(),
        'settings' => const AppSettingsScreen(),
        'logic' => ProjectLogicScreen(initialSection: fragment.contains('=') ? fragment.split('=').last : 'appState'),
        _ => const BuilderScreen(),
      },
    ),
  ));
  SystemChrome.setApplicationSwitcherDescription(const ApplicationSwitcherDescription(label: 'SynappKit UI preview'));
}
