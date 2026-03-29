import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/builder_screen.dart';
import 'providers/widget_tree_provider.dart';
import 'package:flutter/foundation.dart';
// Add this import for web context menu suppression
import 'dart:html' as html;
import 'widgets/canvas_preview/builders/widget_builder_factory.dart';

void main() {
  // Suppress browser context menu on Flutter web
  if (kIsWeb) {
    html.document.onContextMenu.listen((event) => event.preventDefault());
  }
  WidgetBuilderFactory.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WidgetTreeProvider()..loadFromStorage(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Visual Flutter App Builder',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const BuilderScreen(),
      ),
    );
  }
}
