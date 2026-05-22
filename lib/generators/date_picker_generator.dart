import '../../models/widget_node.dart';
import 'base_widget_generator.dart';

class DatePickerGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = '  ' * indent;
    final childIndent = '  ' * (indent + 1);
    final label = node.properties['label']?.toString() ?? 'Select Date';

    return '${indentStr}InkWell(\n'
           '${childIndent}onTap: () async {\n'
           '${childIndent}  await showDatePicker(\n'
           '${childIndent}    context: context,\n'
           '${childIndent}    initialDate: DateTime.now(),\n'
           '${childIndent}    firstDate: DateTime(1900),\n'
           '${childIndent}    lastDate: DateTime(2100),\n'
           '${childIndent}  );\n'
           '${childIndent}},\n'
           '${childIndent}child: InputDecorator(\n'
           '${childIndent}  decoration: const InputDecoration(\n'
           '${childIndent}    labelText: \'$label\',\n'
           '${childIndent}    border: OutlineInputBorder(),\n'
           '${childIndent}    suffixIcon: Icon(Icons.calendar_today),\n'
           '${childIndent}  ),\n'
           '${childIndent}  child: const Text(\'$label\'),\n'
           '${childIndent}),\n'
           '$indentStr),\n';
  }
}
