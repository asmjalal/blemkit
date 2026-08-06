// Template metadata - now loads from JSON files

// Template loader service
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/widget_node.dart';

class TemplateService {
  static Future<dynamic> loadTemplate(String templatePath) async {
    try {
      print('TemplateService: Attempting to load template from: $templatePath');
      final String jsonString = await rootBundle.loadString(templatePath);
      print('TemplateService: Successfully loaded JSON string, length: ${jsonString.length}');
      
      final dynamic jsonData = json.decode(jsonString);
      
      if (jsonData is List) {
        print('TemplateService: Loading multi-screen project');
        return jsonData.map((s) => WidgetNode.fromJson(s as Map<String, dynamic>)).toList();
      } else {
        print('TemplateService: Successfully parsed JSON data, root type: ${jsonData['type']}');
        final widgetNode = WidgetNode.fromJson(jsonData);
        print('TemplateService: Successfully created WidgetNode: ${widgetNode.type}');
        return widgetNode;
      }
    } catch (e, stackTrace) {
      print('Error loading template from $templatePath: $e');
      print('Stack trace: $stackTrace');
      
      // Return a fallback template
      return WidgetNode(
        type: 'Scaffold',
        properties: {},
        children: [
          WidgetNode(
            type: 'Center',
            properties: {},
            children: [
              WidgetNode(
                type: 'Text',
                properties: {'text': 'Template Load Error: $e'},
                children: [],
              ),
            ],
          ),
        ],
      );
    }
  }
}

// Template categories matching only our three premium templates
enum TemplateCategory {
  ecommerce,
  productivity,
  finance,
}

class TemplateMetadata {
  final String name;
  final String description;
  final IconData icon;
  final String jsonPath;
  final TemplateCategory category;
  final List<String> screenNames;
  final String? imageUrl;
  
  const TemplateMetadata({
    required this.name,
    required this.description,
    required this.icon,
    required this.jsonPath,
    required this.category,
    this.screenNames = const [],
    this.imageUrl,
  });
}

// List of available templates grouped by category
final List<TemplateMetadata> templates = [
  // E-commerce
  TemplateMetadata(
    name: 'E-Commerce Supabase Store',
    description: 'Full-stack retail store template integrated with Supabase products catalog, cart insertions, and orders.',
    icon: Icons.cloud_done_outlined,
    jsonPath: 'lib/templates/ecommerce_supabase.json',
    screenNames: [
      'Storefront',
      'Product Details',
      'Shopping Cart',
      'Order Success'
    ],
    category: TemplateCategory.ecommerce,
  ),
  TemplateMetadata(
    name: 'E-Commerce Store',
    description: 'Sophisticated light-themed retail product shopping, item detail, and shopping cart checkout flows.',
    icon: Icons.shopping_cart,
    jsonPath: 'lib/templates/ecommerce_home.json',
    screenNames: [
      'Login',
      'Storefront',
      'Product Details',
      'Shopping Cart',
      'Favorites',
      'Checkout',
      'Order Success',
      'Order History',
      'Order Details'
    ],
    category: TemplateCategory.ecommerce,
  ),
  // Notes App
  TemplateMetadata(
    name: 'Notes App',
    description: 'Clean minimalist personal notes keeper with custom tag cards, notes grid, and editor screens.',
    icon: Icons.note_alt_outlined,
    jsonPath: 'lib/templates/notes_app.json',
    category: TemplateCategory.productivity,
    screenNames: ['My Notes', 'Note Editor'],
  ),
  // Expense Tracker
  TemplateMetadata(
    name: 'Expense Tracker',
    description: 'Luxury personal wallet analytics dashboard, spending category metrics, and quick payment details.',
    icon: Icons.account_balance_wallet_outlined,
    jsonPath: 'lib/templates/expense_tracker.json',
    category: TemplateCategory.finance,
    screenNames: ['Wallet Dashboard', 'Analytics', 'Add Expense'],
  ),
];

// Legacy support - loads the first template for backward compatibility
Future<dynamic> get ecommerceHomeTemplate async {
  return await TemplateService.loadTemplate('lib/templates/ecommerce_home.json');
}
