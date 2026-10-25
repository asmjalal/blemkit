import '../../models/widget_node.dart';
import 'base_widget_generator.dart';

class AutoCompleteGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = '  ' * indent;
    final childIndent = '  ' * (indent + 1);
    final hintText = node.properties['hintText']?.toString() ?? 'Type to search...';

    return '${indentStr}Autocomplete<String>(\n'
           '${childIndent}optionsBuilder: (TextEditingValue textEditingValue) {\n'
           '${childIndent}  if (textEditingValue.text == \'\') {\n'
           '${childIndent}    return const Iterable<String>.empty();\n'
           '${childIndent}  }\n'
           '${childIndent}  return [\'Option 1\', \'Option 2\', \'Option 3\'].where((String option) {\n'
           '${childIndent}    return option.toLowerCase().contains(textEditingValue.text.toLowerCase());\n'
           '${childIndent}  });\n'
           '${childIndent}},\n'
           '${childIndent}onSelected: (String selection) {\n'
           '${childIndent}  debugPrint(\'You just selected \$selection\');\n'
           '${childIndent}},\n'
           '${childIndent}fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {\n'
           '${childIndent}  return TextField(\n'
           '${childIndent}    controller: controller,\n'
           '${childIndent}    focusNode: focusNode,\n'
           '${childIndent}    decoration: InputDecoration(\n'
           '${childIndent}      hintText: ${dartString(hintText)},\n'
           '${childIndent}      suffixIcon: const Icon(Icons.arrow_drop_down),\n'
           '${childIndent}      border: const OutlineInputBorder(),\n'
           '${childIndent}    ),\n'
           '${childIndent}  );\n'
           '${childIndent}},\n'
           '$indentStr),\n';
  }
}
