import 'base_widget_generator.dart';
import '../models/widget_node.dart';
import 'widget_generator_registry.dart';
import 'project_generator.dart';

class ScaffoldGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    // When generating a tab screen, the BottomNavigationBar belongs to
    // the MainNavigationScreen shell — do NOT emit it here.
    final isTabScreen = ProjectGenerator.isGeneratingTabScreen;

    String appBar = '';
    String body = '';
    String fab = '';
    String drawer = '';
    String endDrawer = '';
    String bottomNavBar = '';
    
    // Handle AppBar from properties (primary way)
    if (node.properties['appBar'] != null) {
      final appBarData = node.properties['appBar'];
      WidgetNode? appBarNode;
      if (appBarData is WidgetNode) {
        appBarNode = appBarData;
      } else if (appBarData is Map) {
        appBarNode = WidgetNode.fromJson(Map<String, dynamic>.from(appBarData));
      }
      if (appBarNode != null) {
        appBar = '\n$childIndentStr appBar: ${WidgetGeneratorRegistry.generateCode(appBarNode, indent: indent + 1)},';
      }
    }
    
    // Handle BottomNavigationBar from properties — only for non-tab screens
    if (!isTabScreen && node.properties['bottomNavigationBar'] != null) {
      final bottomNavData = node.properties['bottomNavigationBar'];
      WidgetNode? bottomNavNode;
      if (bottomNavData is WidgetNode) {
        bottomNavNode = bottomNavData;
      } else if (bottomNavData is Map) {
        bottomNavNode = WidgetNode.fromJson(Map<String, dynamic>.from(bottomNavData));
      }
      if (bottomNavNode != null) {
        bottomNavBar = '\n$childIndentStr bottomNavigationBar: ${WidgetGeneratorRegistry.generateCode(bottomNavNode, indent: indent + 1)},';
      }
    }
    
    // Handle FloatingActionButton from properties
    if (node.properties['floatingActionButton'] != null) {
      final fabData = node.properties['floatingActionButton'];
      WidgetNode? fabNode;
      if (fabData is WidgetNode) {
        fabNode = fabData;
      } else if (fabData is Map) {
        fabNode = WidgetNode.fromJson(Map<String, dynamic>.from(fabData));
      }
      if (fabNode != null) {
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
        // For non-tab screens: rescue BNB placed in children
        if (!isTabScreen && bottomNavBar.isEmpty) {
          bottomNavBar = '\n$childIndentStr bottomNavigationBar: ${WidgetGeneratorRegistry.generateCode(child, indent: indent + 1)},';
        }
        // For tab screens: skip entirely — the shell owns the nav bar
      } else {
        body = '\n$childIndentStr body: ${WidgetGeneratorRegistry.generateCode(child, indent: indent + 1)},';
      }
    }
    
    return '${indentStr}Scaffold($backgroundColor$appBar$body$fab$drawer$endDrawer$bottomNavBar\n$indentStr)';
  }
}