import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/widget_node.dart';
import '../../providers/widget_tree_provider.dart';

class TestingService {
  static Future<void> loadTestDesign(WidgetTreeProvider provider) async {
    try {
      // Load the JSON file
      final String jsonString = await rootBundle.loadString('lib/services/testing/testing_design.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // Convert JSON to WidgetNode
      final WidgetNode rootNode = WidgetNode.fromJson(jsonData);
      
      // Set the root node in the provider
      provider.setRootNode(rootNode);
    } catch (e) {
      print('Error loading test design: $e');
    }
  }
} 