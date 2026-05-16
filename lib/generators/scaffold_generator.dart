import 'base_widget_generator.dart';
import '../models/widget_node.dart';
import 'widget_generator_registry.dart';

class ScaffoldGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    String appBar = '';
    String body = '';
    String fab = '';
    String drawer = '';
    String endDrawer = '';
    String bottomNavBar = '';
    
    // Handle AppBar from properties (primary way)
    if (node.properties['appBar'] != null) {
      final appBarData = node.properties['appBar'];
      if (appBarData is Map<String, dynamic>) {
        final appBarNode = WidgetNode.fromJson(appBarData);
        appBar = '\n$childIndentStr appBar: ${WidgetGeneratorRegistry.generateCode(appBarNode, indent: indent + 1)},';
      }
    }
    
    // Handle BottomNavigationBar from properties
    if (node.properties['bottomNavigationBar'] != null) {
      final bottomNavData = node.properties['bottomNavigationBar'];
      if (bottomNavData is Map<String, dynamic>) {
        final bottomNavNode = WidgetNode.fromJson(bottomNavData);
        bottomNavBar = '\n$childIndentStr bottomNavigationBar: ${WidgetGeneratorRegistry.generateCode(bottomNavNode, indent: indent + 1)},';
      }
    }
    
    // Handle FloatingActionButton from properties
    if (node.properties['floatingActionButton'] != null) {
      final fabData = node.properties['floatingActionButton'];
      if (fabData is Map<String, dynamic>) {
        final fabNode = WidgetNode.fromJson(fabData);
        fab = '\n$childIndentStr floatingActionButton: ${WidgetGeneratorRegistry.generateCode(fabNode, indent: indent + 1)},';
      }
    }
    
    // Handle backgroundColor
    String backgroundColor = '';
    if (node.properties['backgroundColor'] != null) {
      backgroundColor = '\n$childIndentStr backgroundColor: ${formatColor(node.properties['backgroundColor'])},';
    }
    
    // Handle children (for body and other components)
    for (final child in node.children) {
      if (child.type == 'AppBar') {
        // Fallback: Handle AppBar from children (secondary way)
        appBar = '\n$childIndentStr appBar: ${WidgetGeneratorRegistry.generateCode(child, indent: indent + 1)},';
      } else if (child.type == 'FAB' || child.type == 'FloatingActionButton') {
        fab = '\n$childIndentStr floatingActionButton: ${WidgetGeneratorRegistry.generateCode(child, indent: indent + 1)},';
      } else if (child.type == 'Drawer') {
        drawer = '\n$childIndentStr drawer: ${WidgetGeneratorRegistry.generateCode(child, indent: indent + 1)},';
      } else if (child.type == 'EndDrawer') {
        endDrawer = '\n$childIndentStr endDrawer: ${WidgetGeneratorRegistry.generateCode(child, indent: indent + 1)},';
      } else if (child.type == 'BottomNavigationBar') {
        // Fallback: AI sometimes places BottomNavigationBar in children — rescue it
        if (bottomNavBar.isEmpty) {
          bottomNavBar = '\n$childIndentStr bottomNavigationBar: ${WidgetGeneratorRegistry.generateCode(child, indent: indent + 1)},';
        }
      } else {
        body = '\n$childIndentStr body: ${WidgetGeneratorRegistry.generateCode(child, indent: indent + 1)},';
      }
    }
    
    return '${indentStr}Scaffold($backgroundColor$appBar$body$fab$drawer$endDrawer$bottomNavBar\n$indentStr)';
  }
}
 