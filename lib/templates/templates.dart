// Template metadata - now loads from JSON files

// Template loader service
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/widget_node.dart';

class TemplateService {
  static Future<WidgetNode> loadTemplate(String templatePath) async {
    try {
      print('TemplateService: Attempting to load template from: $templatePath');
      final String jsonString = await rootBundle.loadString(templatePath);
      print('TemplateService: Successfully loaded JSON string, length: ${jsonString.length}');
      
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      print('TemplateService: Successfully parsed JSON data, root type: ${jsonData['type']}');
      
      final widgetNode = WidgetNode.fromJson(jsonData);
      print('TemplateService: Successfully created WidgetNode: ${widgetNode.type}');
      
      return widgetNode;
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

// Template metadata - now loads from JSON files
class TemplateMetadata {
  final String name;
  final IconData icon;
  final String jsonPath;
  
  const TemplateMetadata({
    required this.name,
    required this.icon,
    required this.jsonPath,
  });
}

// List of available templates
final List<TemplateMetadata> templates = [
  TemplateMetadata(
    name: 'Ecommerce Home',
    icon: Icons.shopping_cart,
    jsonPath: 'lib/templates/ecommerce_home.json',
  ),
  TemplateMetadata(
    name: 'Login Screen',
    icon: Icons.lock_outline,
    jsonPath: 'lib/templates/login_screen.json',
  ),
  TemplateMetadata(
    name: 'Settings',
    icon: Icons.settings_outlined,
    jsonPath: 'lib/templates/settings_screen.json',
  ),
  TemplateMetadata(
    name: 'Food Delivery',
    icon: Icons.delivery_dining,
    jsonPath: 'lib/templates/food_delivery.json',
  ),
  TemplateMetadata(
    name: 'Chat Screen',
    icon: Icons.chat_bubble_outline,
    jsonPath: 'lib/templates/chat_screen.json',
  ),
  TemplateMetadata(
    name: 'Modern Dashboard',
    icon: Icons.dashboard_customize,
    jsonPath: 'lib/templates/modern_dashboard.json',
  ),
  TemplateMetadata(
    name: 'Social Profile',
    icon: Icons.person_add_alt_1,
    jsonPath: 'lib/templates/social_profile.json',
  ),
];

// Legacy support - loads the first template for backward compatibility
Future<WidgetNode> get ecommerceHomeTemplate async {
  return await TemplateService.loadTemplate('lib/templates/ecommerce_home.json');
}
