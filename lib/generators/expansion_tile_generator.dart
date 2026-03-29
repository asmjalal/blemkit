import 'base_widget_generator.dart';
import '../models/widget_node.dart';

class ExpansionTileGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    props.add('title: Text(\'${node.properties['title'] ?? 'Expansion Tile'}\')');
    
    final children = generateChildren(node.children, indent: indent);
    
    return '${indentStr}ExpansionTile(\n$childIndentStr ${props.join(',\n$childIndentStr ')}$children\n$indentStr)';
  }
} 