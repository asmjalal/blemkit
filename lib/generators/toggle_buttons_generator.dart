import '../../models/widget_node.dart';
import 'base_widget_generator.dart';

class ToggleButtonsGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = '  ' * indent;
    final childIndent = '  ' * (indent + 1);

    return '${indentStr}ToggleButtons(\n'
           '${childIndent}isSelected: const [true, false, false],\n'
           '${childIndent}onPressed: (int index) {\n'
           '${childIndent}  // Handle toggle logic\n'
           '${childIndent}},\n'
           '${childIndent}children: const [\n'
           '${childIndent}  Icon(Icons.format_bold),\n'
           '${childIndent}  Icon(Icons.format_italic),\n'
           '${childIndent}  Icon(Icons.format_underlined),\n'
           '${childIndent}],\n'
           '$indentStr),\n';
  }
}
