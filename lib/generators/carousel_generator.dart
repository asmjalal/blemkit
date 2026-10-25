import 'base_widget_generator.dart';
import 'logic_codegen.dart';
import '../models/widget_node.dart';
import 'widget_generator_registry.dart';

class CarouselGenerator extends BaseWidgetGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    LogicCodegen.imports.add('package:carousel_slider/carousel_slider.dart');
    LogicCodegen.packages.add('carousel_slider');
    final indentStr = getIndentString(indent);
    final childIndentStr = getChildIndentStr(indent);
    final itemIndentStr = getChildIndentStr(indent + 1);
    
    final height = node.properties['height']?.toString() ?? '200.0';
    final autoPlay = node.properties['autoPlay']?.toString() ?? 'false';
    final viewportFraction = node.properties['viewportFraction']?.toString() ?? '0.8';

    final childrenCode = node.children.isEmpty
        ? '[]'
        : '[\n${node.children.map((c) => '$itemIndentStr${WidgetGeneratorRegistry.generateCode(c, indent: indent + 2)},').join('\n')}\n$childIndentStr]';

    return '''${indentStr}CarouselSlider(
${childIndentStr}options: CarouselOptions(
${itemIndentStr}height: $height,
${itemIndentStr}autoPlay: $autoPlay,
${itemIndentStr}viewportFraction: $viewportFraction,
${childIndentStr}),
${childIndentStr}items: $childrenCode,
$indentStr)''';
  }
}
