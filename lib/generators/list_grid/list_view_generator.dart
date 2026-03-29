import '../base_widget_generator.dart';
import '../../models/widget_node.dart';
import '../widget_generator_registry.dart';

class ListViewGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    if (node.properties['scrollDirection'] != null) {
      props.add('scrollDirection: Axis.${node.properties['scrollDirection']}');
    }
    
    if (node.properties['padding'] != null) {
      final padding = node.properties['padding'];
      if (padding is Map) {
        final left = padding['left'] ?? 0;
        final right = padding['right'] ?? 0;
        final top = padding['top'] ?? 0;
        final bottom = padding['bottom'] ?? 0;
        props.add('padding: EdgeInsets.only(left: $left, top: $top, right: $right, bottom: $bottom)');
      } else {
        props.add('padding: EdgeInsets.all($padding)');
      }
    }
    
    if (node.properties['shrinkWrap'] != null) {
      props.add('shrinkWrap: ${node.properties['shrinkWrap']}');
    }
    
    final children = node.children.isNotEmpty 
        ? '\n$childIndentStr children: [\n${node.children.map((child) => '${getChildIndentStr(indent + 1)}${WidgetGeneratorRegistry.generateCode(child, indent: indent + 2)},').join('\n')}\n$childIndentStr],'
        : '';
    
    return '${indentStr}ListView(${props.isNotEmpty ? '\n$childIndentStr${props.join(',\n$childIndentStr')}${children.isNotEmpty ? ',' : ''}' : ''}$children\n$indentStr)';
  }
}

class ListViewBuilderGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    props.add('itemCount: ${node.properties['itemCount'] ?? 10}');
    props.add('itemBuilder: (context, index) => Container()');
    
    if (node.properties['scrollDirection'] != null) {
      props.add('scrollDirection: Axis.${node.properties['scrollDirection']}');
    }
    
    if (node.properties['padding'] != null) {
      final padding = node.properties['padding'];
      if (padding is Map) {
        final left = padding['left'] ?? 0;
        final right = padding['right'] ?? 0;
        final top = padding['top'] ?? 0;
        final bottom = padding['bottom'] ?? 0;
        props.add('padding: EdgeInsets.only(left: $left, top: $top, right: $right, bottom: $bottom)');
      } else {
        props.add('padding: EdgeInsets.all($padding)');
      }
    }
    
    if (node.properties['shrinkWrap'] != null) {
      props.add('shrinkWrap: ${node.properties['shrinkWrap']}');
    }
    
    return '${indentStr}ListView.builder(${props.join(', ')})';
  }
} 