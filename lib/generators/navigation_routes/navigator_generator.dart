import '../base_widget_generator.dart';
import '../../models/widget_node.dart';

class NavigatorGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    if (node.properties['initialRoute'] != null) {
      props.add('initialRoute: \'${node.properties['initialRoute']}\'');
    }
    
    if (node.properties['onGenerateRoute'] != null) {
      props.add('onGenerateRoute: (settings) => MaterialPageRoute(builder: (context) => Container())');
    }
    
    final children = generateChildren(node.children, indent: indent);
    
    return '${indentStr}Navigator(${props.join(', ')}$children\n$indentStr)';
  }
} 