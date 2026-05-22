import '../../models/widget_node.dart';
import 'base_widget_generator.dart';

class NavigationRailGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = '  ' * indent;
    final childIndent = '  ' * (indent + 1);

    return '${indentStr}NavigationRail(\n'
           '${childIndent}selectedIndex: 0,\n'
           '${childIndent}onDestinationSelected: (int index) {\n'
           '${childIndent}  // Handle navigation\n'
           '${childIndent}},\n'
           '${childIndent}labelType: NavigationRailLabelType.selected,\n'
           '${childIndent}destinations: const [\n'
           '${childIndent}  NavigationRailDestination(\n'
           '${childIndent}    icon: Icon(Icons.favorite_border),\n'
           '${childIndent}    selectedIcon: Icon(Icons.favorite),\n'
           '${childIndent}    label: Text(\'First\'),\n'
           '${childIndent}  ),\n'
           '${childIndent}  NavigationRailDestination(\n'
           '${childIndent}    icon: Icon(Icons.bookmark_border),\n'
           '${childIndent}    selectedIcon: Icon(Icons.book),\n'
           '${childIndent}    label: Text(\'Second\'),\n'
           '${childIndent}  ),\n'
           '${childIndent}  NavigationRailDestination(\n'
           '${childIndent}    icon: Icon(Icons.star_border),\n'
           '${childIndent}    selectedIcon: Icon(Icons.star),\n'
           '${childIndent}    label: Text(\'Third\'),\n'
           '${childIndent}  ),\n'
           '${childIndent}],\n'
           '$indentStr),\n';
  }
}
