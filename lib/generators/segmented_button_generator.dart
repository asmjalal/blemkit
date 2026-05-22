import '../../models/widget_node.dart';
import 'base_widget_generator.dart';

class SegmentedButtonGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = '  ' * indent;
    final childIndent = '  ' * (indent + 1);

    return '${indentStr}SegmentedButton<int>(\n'
           '${childIndent}segments: const [\n'
           '${childIndent}  ButtonSegment<int>(value: 0, label: Text(\'Day\'), icon: Icon(Icons.calendar_view_day)),\n'
           '${childIndent}  ButtonSegment<int>(value: 1, label: Text(\'Week\'), icon: Icon(Icons.calendar_view_week)),\n'
           '${childIndent}  ButtonSegment<int>(value: 2, label: Text(\'Month\'), icon: Icon(Icons.calendar_view_month)),\n'
           '${childIndent}],\n'
           '${childIndent}selected: const {0},\n'
           '${childIndent}onSelectionChanged: (Set<int> newSelection) {\n'
           '${childIndent}  // Handle selection\n'
           '${childIndent}},\n'
           '$indentStr),\n';
  }
}
