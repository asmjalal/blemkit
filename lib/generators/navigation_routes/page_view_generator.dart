import '../base_widget_generator.dart';
import '../../models/widget_node.dart';

class PageViewGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    if (node.properties['scrollDirection'] != null) {
      props.add('scrollDirection: ${axisExpression(node.properties['scrollDirection'])}');
    }
    
    if (node.properties['controller'] != null) {
      props.add('controller: PageController()');
    }
    
    if (node.properties['onPageChanged'] != null) {
      props.add('onPageChanged: (index) {}');
    }
    
    final children = generateChildren(node.children, indent: indent);
    
    return '${indentStr}PageView(${props.join(', ')}$children\n$indentStr)';
  }
} 