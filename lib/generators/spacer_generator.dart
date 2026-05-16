import 'base_widget_generator.dart';
import '../models/widget_node.dart';

class SpacerGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final flex = node.properties['flex'] ?? 1;
    if (flex == 1) {
      return '${indentStr}Spacer()';
    }
    return '${indentStr}Spacer(flex: $flex)';
  }
}
