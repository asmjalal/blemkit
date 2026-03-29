import '../base_widget_generator.dart';
import '../../models/widget_node.dart';

class ReorderableListViewGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    if (node.properties['scrollDirection'] != null) {
      props.add('scrollDirection: Axis.${node.properties['scrollDirection']}');
    }
    
    if (node.properties['padding'] != null) {
      props.add('padding: EdgeInsets.all(${node.properties['padding']})');
    }
    
    props.add('onReorder: (oldIndex, newIndex) {}');
    
    final children = node.children.map((child) {
      return '${generateCode(child, indent: indent + 1)},';
    }).join('\n$childIndentStr');
    
    props.add('children: [\n$childIndentStr $children\n$indentStr]');
    
    return '${indentStr}ReorderableListView(${props.join(',\n$childIndentStr ')}\n$indentStr)';
  }
} 