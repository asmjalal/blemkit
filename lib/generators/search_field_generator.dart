import '../../models/widget_node.dart';
import 'base_widget_generator.dart';

class SearchFieldGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = '  ' * indent;
    final childIndent = '  ' * (indent + 1);
    final hintText = node.properties['hintText']?.toString() ?? 'Search...';

    return '${indentStr}TextField(\n'
           '${childIndent}decoration: InputDecoration(\n'
           '${childIndent}  hintText: ${dartString(hintText)},\n'
           '${childIndent}  prefixIcon: const Icon(Icons.search),\n'
           '${childIndent}  suffixIcon: const Icon(Icons.mic),\n'
           '${childIndent}  border: OutlineInputBorder(\n'
           '${childIndent}    borderRadius: BorderRadius.circular(30.0),\n'
           '${childIndent}  ),\n'
           '${childIndent}  filled: true,\n'
           '${childIndent}  fillColor: Colors.grey.withOpacity(0.1),\n'
           '${childIndent}),\n'
           '$indentStr),\n';
  }
}
