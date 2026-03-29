import '../base_widget_generator.dart';
import '../../models/widget_node.dart';

class CustomScrollViewGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final props = <String>[];
    
    if (node.properties['scrollDirection'] != null) {
      props.add('scrollDirection: Axis.${node.properties['scrollDirection']}');
    }
    
    if (node.properties['physics'] != null) {
      props.add('physics: ${node.properties['physics']}');
    }
    
    final slivers = node.children.map((child) {
      String sliverCode;
      switch (child.type) {
        case 'SliverAppBar':
          sliverCode = 'SliverAppBar(title: Text(\'${child.properties['title'] ?? 'App Bar'}\'))';
          break;
        case 'SliverList':
          sliverCode = 'SliverList(delegate: SliverChildListDelegate([Container()]))';
          break;
        case 'SliverGrid':
          sliverCode = 'SliverGrid(delegate: SliverChildListDelegate([Container()]), gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2))';
          break;
        default:
          sliverCode = 'SliverToBoxAdapter(child: ${generateCode(child, indent: indent + 1)})';
      }
      return sliverCode;
    }).join(',\n$childIndentStr');
    
    props.add('slivers: [\n$childIndentStr $slivers\n$indentStr]');
    
    return '${indentStr}CustomScrollView(${props.join(',\n$childIndentStr ')}\n$indentStr)';
  }
} 