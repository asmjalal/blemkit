import '../base_widget_generator.dart';
import '../../models/widget_node.dart';

class MaterialPageRouteGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    props.add('builder: (context) => ${node.properties['builder'] ?? 'Container()'}');
    
    if (node.properties['settings'] != null) {
      props.add('settings: RouteSettings(name: ${dartString(node.properties['settings'])})');
    }
    
    if (node.properties['fullscreenDialog'] != null) {
      props.add('fullscreenDialog: ${node.properties['fullscreenDialog']}');
    }
    
    if (node.properties['maintainState'] != null) {
      props.add('maintainState: ${node.properties['maintainState']}');
    }
    
    return '${indentStr}MaterialPageRoute(${props.join(', ')})';
  }
} 