import '../../models/widget_node.dart';
import 'base_widget_generator.dart';

class TimePickerGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = '  ' * indent;
    final childIndent = '  ' * (indent + 1);
    final label = node.properties['label']?.toString() ?? 'Select Time';

    return '${indentStr}InkWell(\n'
           '${childIndent}onTap: () async {\n'
           '${childIndent}  await showTimePicker(\n'
           '${childIndent}    context: context,\n'
           '${childIndent}    initialTime: TimeOfDay.now(),\n'
           '${childIndent}  );\n'
           '${childIndent}},\n'
           '${childIndent}child: InputDecorator(\n'
           '${childIndent}  decoration: const InputDecoration(\n'
           '${childIndent}    labelText: ${dartString(label)},\n'
           '${childIndent}    border: OutlineInputBorder(),\n'
           '${childIndent}    suffixIcon: Icon(Icons.access_time),\n'
           '${childIndent}  ),\n'
           '${childIndent}  child: const Text(${dartString(label)}),\n'
           '${childIndent}),\n'
           '$indentStr),\n';
  }
}
