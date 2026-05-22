import 'base_widget_generator.dart';
import 'widget_generator_registry.dart';
import '../models/widget_node.dart';

class PopupMenuButtonGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    props.add('itemBuilder: (context) => [\n$childIndentStr PopupMenuItem(value: 1, child: Text(\'Option 1\')),\n$childIndentStr PopupMenuItem(value: 2, child: Text(\'Option 2\')),\n$indentStr]');
    props.add('onSelected: (value) {}');
    
    String child = '';
    if (node.children.isNotEmpty) {
      child = '\n$childIndentStr child: ${WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1)},';
    } else if (node.properties['icon'] != null) {
      child = '\n$childIndentStr child: Icon(Icons.${node.properties['icon']}),';
    }
    
    return '${indentStr}PopupMenuButton(${props.join(',\n$childIndentStr ')}$child\n$indentStr)';
  }
} 