import '../base_widget_generator.dart';
import '../../models/widget_node.dart';
import '../widget_generator_registry.dart';

class GridViewGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    // GridView.count is more appropriate for basic grid with crossAxisCount
    if (node.properties['crossAxisCount'] != null) {
      final crossAxisCount = node.properties['crossAxisCount'];
      final additionalProps = <String>[];
      
      if (node.properties['crossAxisSpacing'] != null) {
        additionalProps.add('crossAxisSpacing: ${node.properties['crossAxisSpacing']}');
      }
      
      if (node.properties['mainAxisSpacing'] != null) {
        additionalProps.add('mainAxisSpacing: ${node.properties['mainAxisSpacing']}');
      }
      
      if (node.properties['childAspectRatio'] != null) {
        additionalProps.add('childAspectRatio: ${node.properties['childAspectRatio']}');
      }
      
      if (node.properties['padding'] != null) {
        final padding = node.properties['padding'];
        if (padding is Map) {
          final left = padding['left'] ?? 0;
          final right = padding['right'] ?? 0;
          final top = padding['top'] ?? 0;
          final bottom = padding['bottom'] ?? 0;
          additionalProps.add('padding: EdgeInsets.only(left: $left, top: $top, right: $right, bottom: $bottom)');
        } else {
          additionalProps.add('padding: EdgeInsets.all($padding)');
        }
      }
      
      final children = node.children.isNotEmpty 
          ? '\n$childIndentStr children: [\n${node.children.map((child) => '${getChildIndentStr(indent + 1)}${WidgetGeneratorRegistry.generateCode(child, indent: indent + 2)},').join('\n')}\n$childIndentStr],'
          : '';
      
      final allProps = ['crossAxisCount: $crossAxisCount', ...additionalProps];
      
      return '${indentStr}GridView.count(\n$childIndentStr${allProps.join(',\n$childIndentStr')}${children.isNotEmpty ? ',' : ''}$children\n$indentStr)';
    }
    
    // Fallback to basic GridView
    final children = node.children.isNotEmpty 
        ? '\n$childIndentStr children: [\n${node.children.map((child) => '${getChildIndentStr(indent + 1)}${WidgetGeneratorRegistry.generateCode(child, indent: indent + 2)},').join('\n')}\n$childIndentStr],'
        : '';
    
    return '${indentStr}GridView($children\n$indentStr)';
  }
}

class GridViewBuilderGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    props.add('itemCount: ${node.properties['itemCount'] ?? 10}');
    props.add('itemBuilder: (context, index) => Container()');
    
    if (node.properties['crossAxisCount'] != null) {
      props.add('crossAxisCount: ${node.properties['crossAxisCount']}');
    }
    
    if (node.properties['crossAxisSpacing'] != null) {
      props.add('crossAxisSpacing: ${node.properties['crossAxisSpacing']}');
    }
    
    if (node.properties['mainAxisSpacing'] != null) {
      props.add('mainAxisSpacing: ${node.properties['mainAxisSpacing']}');
    }
    
    if (node.properties['childAspectRatio'] != null) {
      props.add('childAspectRatio: ${node.properties['childAspectRatio']}');
    }
    
    if (node.properties['padding'] != null) {
      props.add('padding: EdgeInsets.all(${node.properties['padding']})');
    }
    
    return '${indentStr}GridView.builder(${props.join(', ')})';
  }
} 