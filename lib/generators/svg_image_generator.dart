import 'base_widget_generator.dart';
import 'logic_codegen.dart';
import '../models/widget_node.dart';

class SvgImageGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    LogicCodegen.imports.add('package:flutter_svg/flutter_svg.dart');
    LogicCodegen.packages.add('flutter_svg');
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    
    final src = node.properties['src']?.toString() ?? 'assets/icons/placeholder.svg';
    final width = node.properties['width']?.toString();
    final height = node.properties['height']?.toString();
    
    final isNetwork = src.startsWith('http');
    final constructor = isNetwork ? 'SvgPicture.network' : 'SvgPicture.asset';
    
    final props = <String>[];
    if (width != null) props.add('width: $width');
    if (height != null) props.add('height: $height');
    if (node.properties['color'] != null) {
      props.add('colorFilter: ColorFilter.mode(${formatColor(node.properties['color'])}, BlendMode.srcIn)');
    }
    
    final propsString = props.isNotEmpty ? ',\n$childIndentStr${props.join(',\n$childIndentStr')},' : '';

    return '''$indentStr$constructor(
$childIndentStr${dartString(src)}$propsString
$indentStr)''';
  }
}
