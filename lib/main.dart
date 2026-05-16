import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/builder_screen.dart';
import 'screens/login_screen.dart';
import 'providers/widget_tree_provider.dart';
import 'package:flutter/foundation.dart';
// Add this import for web context menu suppression
import 'dart:html' as html;
import 'widgets/canvas_preview/builders/widget_builder_factory.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Suppress browser context menu on Flutter web
  if (kIsWeb) {
    html.document.onContextMenu.listen((event) => event.preventDefault());
  }
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization warning: $e\nHint: run `flutterfire configure`.');
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
        title: 'Synappkit',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          fontFamily: 'Inter',

        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // Because Firebase init might be caught and skipped due to missing config, 
            // handle error smoothly on non-configured devices.
            try {
               final user = FirebaseAuth.instance.currentUser;
               // Just pinging instance to see if it throws.
            } catch(e) {
               return const BuilderScreen(); // Bypass login if Firebase isn't set up yet
            }
            
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            
            if (snapshot.hasData) {
              return const BuilderScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
