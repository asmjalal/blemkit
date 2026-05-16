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

// Template metadata - now with categories and descriptions
enum TemplateCategory {
  ecommerce,
  delivery,
  food,
  pharmacy,
  todo,
  fitness,
  scratch,
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
    name: 'E-commerce Store',
    description: 'Sophisticated retail solutions with integrated inventory and checkout flows.',
    icon: Icons.shopping_cart,
    jsonPath: 'lib/templates/ecommerce_home.json',
    category: TemplateCategory.ecommerce,
    screenNames: ['Storefront', 'Product Details', 'Shopping Cart', 'Checkout'],
  ),
  // Delivery
  TemplateMetadata(
    name: 'Delivery',
    description: 'Real-time tracking and logistics management for fast-paced fulfillment.',
    icon: Icons.local_shipping,
    jsonPath: 'lib/templates/food_delivery.json',
    category: TemplateCategory.delivery,
    screenNames: ['Active Orders', 'Map View', 'Order History', 'Courier Chat'],
  ),
  // Food
  TemplateMetadata(
    name: 'Food',
    description: 'Interactive menus and seamless ordering systems for modern dining experiences.',
    icon: Icons.restaurant,
    jsonPath: 'lib/templates/food_delivery.json', // Shared for now
    category: TemplateCategory.food,
    screenNames: ['Restaurant Menu', 'Dish Details', 'Order Tracker', 'Reviews'],
  ),
  // Pharmacy
  TemplateMetadata(
    name: 'Pharmacy',
    description: 'Compliant and secure medication management with prescription fulfillment.',
    icon: Icons.local_pharmacy,
    jsonPath: 'lib/templates/pharmacy_screen.json',
    category: TemplateCategory.pharmacy,
    screenNames: ['Medication List', 'Prescription Upload', 'Pharmacy Map', 'Profile'],
  ),
  // Todo
  TemplateMetadata(
    name: 'Todo',
    description: 'Advanced productivity tools with task prioritization and team collaboration.',
    icon: Icons.checklist_rtl,
    jsonPath: 'lib/templates/high_fidelity_todo.json',
    category: TemplateCategory.todo,
    screenNames: ['Dashboard', 'Calendar View', 'New Task', 'Achievements'],
  ),
  // Fitness
  TemplateMetadata(
    name: 'FitLife Tracker',
    description: 'Beautiful fitness dashboard with workout tracking, activity feed, and profile management.',
    icon: Icons.fitness_center,
    jsonPath: 'lib/templates/fitlife_tracker.json',
    category: TemplateCategory.fitness,
    screenNames: ['Dashboard', 'Workouts', 'Activity', 'Profile'],
  ),
];

// Legacy support - loads the first template for backward compatibility
Future<WidgetNode> get ecommerceHomeTemplate async {
  return await TemplateService.loadTemplate('lib/templates/ecommerce_home.json');
}
