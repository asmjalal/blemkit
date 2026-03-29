import 'base_widget_generator.dart';
import '../models/widget_node.dart';

class ImageGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    
    final props = <String>[];
    props.add('src: \'${node.properties['src'] ?? ''}\'');
    
    if (node.properties['width'] != null) {
      props.add('width: ${node.properties['width']}');
    }
    if (node.properties['height'] != null) {
      props.add('height: ${node.properties['height']}');
    }
    
    props.add('fit: BoxFit.cover');
    
    return '${indentStr}Image.network(${props.join(', ')})';
  }
} 