import '../models/project_logic.dart';
import '../models/widget_node.dart';
import 'base_widget_generator.dart';
import 'logic_codegen.dart';
import 'project_generator.dart';
import 'widget_generator_registry.dart';

/// Generators for widgets backed by the SynappKit runtime library
/// (`lib/runtime/exported/synapp_widgets.dart`, exported as
/// `lib/synapp/synapp_widgets.dart`) plus a few small Flutter wrappers.
/// Input widgets keep their value in a state field so "Widget state" values
/// and `onChanged` actions can read it.
abstract class _SynappGenerator extends BaseWidgetGenerator {
  String safeId(WidgetNode node) => node.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');

  List<String> options(dynamic raw, List<String> fallback) {
    if (raw is List) return raw.map((e) => e is Map ? '${e['value'] ?? e['label'] ?? ''}' : e.toString()).toList();
    if (raw is String && raw.trim().isNotEmpty) return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return fallback;
  }

  String stringList(List<String> items) => '[${items.map(dartString).join(', ')}]';

  double number(dynamic raw, double fallback) => raw is num ? raw.toDouble() : double.tryParse('${raw ?? ''}') ?? fallback;

  String? color(WidgetNode node, String key) => node.properties[key] == null ? null : formatColor(node.properties[key]);

  /// `onChanged` closure that stores the new value in [varName] and runs the
  /// node's `onChanged` actions.
  String onChanged(WidgetNode node, String varName, String param) {
    final actions = node.properties['onChanged'];
    final runActions = LogicCodegen.hasActions(actions) ? '\n        ${LogicCodegen.statements(actions as List, indent: '        ').trim()}' : '';
    final isAsync = runActions.contains('await ');
    return '($param) ${isAsync ? 'async ' : ''}{\n        setState(() => $varName = $param);$runActions\n      }';
  }

  String call(String name, List<String?> args, String indentStr) =>
      '$indentStr$name(${args.whereType<String>().join(', ')})';

  String childOf(WidgetNode node, int indent) => node.children.isEmpty
      ? 'const SizedBox.shrink()'
      : WidgetGeneratorRegistry.generateCode(node.children.first, indent: indent + 1).trimLeft();
}

class RatingBarGenerator extends _SynappGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final v = '_rating_${safeId(node)}';
    BaseWidgetGenerator.stateVariables.add('double $v = ${number(node.properties['rating'], 3)};');
    return call('SynappRatingBar', [
      'rating: $v',
      'itemCount: ${number(node.properties['itemCount'], 5).toInt()}',
      'itemSize: ${node.properties['itemSize'] ?? 28.0}',
      if (color(node, 'color') != null) 'color: ${color(node, 'color')}',
      if (node.properties['allowHalf'] == true) 'allowHalf: true',
      'onChanged: ${onChanged(node, v, 'value')}',
    ], getIndentString(indent));
  }
}

class PinCodeGenerator extends _SynappGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final v = '_pin_${safeId(node)}';
    BaseWidgetGenerator.stateVariables.add("String $v = '';");
    return call('SynappPinCode', [
      'length: ${number(node.properties['length'], 4).toInt()}',
      'obscureText: ${node.properties['obscureText'] == true}',
      if (node.properties['boxSize'] != null) 'boxSize: ${node.properties['boxSize']}',
      if (color(node, 'activeColor') != null) 'activeColor: ${color(node, 'activeColor')}',
      'onChanged: ${onChanged(node, v, 'value')}',
    ], getIndentString(indent));
  }
}

class CounterButtonGenerator extends _SynappGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final v = '_counter_${safeId(node)}';
    BaseWidgetGenerator.stateVariables.add('int $v = ${number(node.properties['value'], 1).toInt()};');
    return call('SynappCounter', [
      'value: $v',
      'min: ${number(node.properties['min'], 0).toInt()}',
      'max: ${number(node.properties['max'], 99).toInt()}',
      if (color(node, 'color') != null) 'color: ${color(node, 'color')}',
      'onChanged: ${onChanged(node, v, 'value')}',
    ], getIndentString(indent));
  }
}

class ChoiceChipsGenerator extends _SynappGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final v = '_choices_${safeId(node)}';
    final selected = options(node.properties['selected'], const []);
    BaseWidgetGenerator.stateVariables.add('List<String> $v = ${stringList(selected)};');
    return call('SynappChoiceChips', [
      'options: const ${stringList(options(node.properties['options'], const ['Option A', 'Option B', 'Option C']))}',
      'initiallySelected: $v',
      'multiSelect: ${node.properties['multiSelect'] == true}',
      if (color(node, 'selectedColor') != null) 'selectedColor: ${color(node, 'selectedColor')}',
      'onChanged: ${onChanged(node, v, 'value')}',
    ], getIndentString(indent));
  }
}

class CheckboxGroupGenerator extends _SynappGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final v = '_choices_${safeId(node)}';
    BaseWidgetGenerator.stateVariables.add('List<String> $v = ${stringList(options(node.properties['selected'], const []))};');
    return call('SynappCheckboxGroup', [
      'options: const ${stringList(options(node.properties['options'], const ['Option A', 'Option B', 'Option C']))}',
      'initiallySelected: $v',
      if (color(node, 'activeColor') != null) 'activeColor: ${color(node, 'activeColor')}',
      'onChanged: ${onChanged(node, v, 'value')}',
    ], getIndentString(indent));
  }
}

class RadioGroupGenerator extends _SynappGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final v = '_radio_${safeId(node)}';
    final initial = node.properties['value'];
    BaseWidgetGenerator.stateVariables.add('String? $v = ${initial == null || '$initial'.isEmpty ? 'null' : dartString(initial)};');
    return call('SynappRadioGroup', [
      'options: const ${stringList(options(node.properties['options'], const ['Option A', 'Option B']))}',
      'initialValue: $v',
      'horizontal: ${node.properties['horizontal'] == true}',
      if (color(node, 'activeColor') != null) 'activeColor: ${color(node, 'activeColor')}',
      'onChanged: ${onChanged(node, v, 'value')}',
    ], getIndentString(indent));
  }
}

class SignatureGenerator extends _SynappGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) => call('SynappSignature', [
        'height: ${node.properties['height'] ?? 160.0}',
        if (color(node, 'penColor') != null) 'penColor: ${color(node, 'penColor')}',
        if (color(node, 'backgroundColor') != null) 'backgroundColor: ${color(node, 'backgroundColor')}',
      ], getIndentString(indent));
}

class DataTableGenerator extends _SynappGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final columns = options(node.properties['columns'], const ['Name', 'Status']);
    final rawRows = node.properties['rows'];
    final rows = <List<String>>[
      if (rawRows is List)
        for (final r in rawRows) r is List ? r.map((e) => '$e').toList() : '$r'.split(',').map((e) => e.trim()).toList()
      else if (rawRows is String)
        for (final line in rawRows.split('\n').where((l) => l.trim().isNotEmpty)) line.split(',').map((e) => e.trim()).toList()
    ];
    return call('SynappDataTable', [
      'columns: const ${stringList(columns)}',
      'rows: const [${rows.map(stringList).join(', ')}]',
      if (color(node, 'headerColor') != null) 'headerColor: ${color(node, 'headerColor')}',
    ], getIndentString(indent));
  }
}

class CreditCardFormGenerator extends _SynappGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) => call('SynappCreditCardForm', [
        if (color(node, 'cardColor') != null) 'cardColor: ${color(node, 'cardColor')}',
      ], getIndentString(indent));
}

class SlidableListTileGenerator extends _SynappGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final actions = node.properties['actions'];
    return call('SynappSlidableTile', [
      'title: ${dartString(node.properties['title'] ?? 'Slidable List Tile')}',
      if ('${node.properties['subtitle'] ?? ''}'.isNotEmpty) 'subtitle: ${dartString(node.properties['subtitle'])}',
      'actionLabel: ${dartString(node.properties['actionLabel'] ?? 'Delete')}',
      if (color(node, 'actionColor') != null) 'actionColor: ${color(node, 'actionColor')}',
      if (LogicCodegen.hasActions(actions)) 'onAction: ${LogicCodegen.closure(actions as List)}',
    ], getIndentString(indent));
  }
}

class LoadingOverlayGenerator extends _SynappGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) => call('SynappLoadingOverlay', [
        'isLoading: ${node.properties['isLoading'] != false}',
        'child: ${childOf(node, indent)}',
      ], getIndentString(indent));
}

class PlacePickerGenerator extends _SynappGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final v = '_place_${safeId(node)}';
    BaseWidgetGenerator.stateVariables.add("String $v = '';");
    return call('SynappPlacePicker', [
      'hintText: ${dartString(node.properties['hintText'] ?? 'Search address')}',
      'suggestions: const ${stringList(options(node.properties['suggestions'], const []))}',
      'onSelected: ${onChanged(node, v, 'value')}',
    ], getIndentString(indent));
  }
}

class HeroGenerator extends _SynappGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) =>
      call('Hero', ['tag: ${dartString(node.properties['tag'] ?? node.id)}', 'child: ${childOf(node, indent)}'], getIndentString(indent));
}

class AnimatedContainerGenerator extends _SynappGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final p = node.properties;
    final decoration = <String>[
      if (p['color'] != null) 'color: ${formatColor(p['color'])}',
      if (p['borderRadius'] != null) 'borderRadius: BorderRadius.circular(${number(p['borderRadius'], 0)})',
    ];
    return call('AnimatedContainer', [
      'duration: const Duration(milliseconds: ${number(p['durationMs'], 300).toInt()})',
      'curve: Curves.easeInOut',
      if (p['width'] != null) 'width: ${p['width']}',
      if (p['height'] != null) 'height: ${p['height']}',
      if (p['padding'] != null) 'padding: ${parseEdgeInsets(p['padding'])}',
      if (decoration.isNotEmpty) 'decoration: BoxDecoration(${decoration.join(', ')})',
      if (node.children.isNotEmpty) 'child: ${childOf(node, indent)}',
    ], getIndentString(indent));
  }
}

class AnimatedOpacityGenerator extends _SynappGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) => call('AnimatedOpacity', [
        'opacity: ${number(node.properties['opacity'], 1).clamp(0, 1)}',
        'duration: const Duration(milliseconds: ${number(node.properties['durationMs'], 300).toInt()})',
        'child: ${childOf(node, indent)}',
      ], getIndentString(indent));
}

class AnimatedSwitcherGenerator extends _SynappGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) => call('AnimatedSwitcher', [
        'duration: const Duration(milliseconds: ${number(node.properties['durationMs'], 300).toInt()})',
        'child: ${childOf(node, indent)}',
      ], getIndentString(indent));
}

class FlexWidgetGenerator extends _SynappGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final p = node.properties;
    String enumValue(String prefix, dynamic raw, String fallback) {
      final s = '${raw ?? fallback}';
      return s.startsWith('$prefix.') ? s : '$prefix.$s';
    }

    return '${getIndentString(indent)}Flex(\n'
        '${getChildIndentStr(indent)} direction: ${axisExpression(p['direction'] ?? 'horizontal')},\n'
        '${getChildIndentStr(indent)} mainAxisAlignment: ${enumValue('MainAxisAlignment', p['mainAxisAlignment'], 'start')},\n'
        '${getChildIndentStr(indent)} crossAxisAlignment: ${enumValue('CrossAxisAlignment', p['crossAxisAlignment'], 'center')},'
        '${generateChildren(node.children, indent: indent)}\n${getIndentString(indent)})';
  }
}

class DropdownGenerator extends _SynappGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final v = '_dropdown_${safeId(node)}';
    final items = options(node.properties['items'], const ['Option 1', 'Option 2', 'Option 3']);
    final initial = node.properties['value'];
    final valid = initial != null && items.contains('$initial');
    BaseWidgetGenerator.stateVariables.add('String? $v = ${valid ? dartString(initial) : 'null'};');
    final inner = getChildIndentStr(indent);
    return call('DropdownButton<String>', [
      'value: $v',
      'isExpanded: ${node.properties['isExpanded'] != false}',
      if (node.properties['hint'] != null) 'hint: Text(${dartString(node.properties['hint'])})',
      'items: const [${items.map((i) => 'DropdownMenuItem(value: ${dartString(i)}, child: Text(${dartString(i)}))').join(',\n$inner  ')}]',
      'onChanged: ${onChanged(node, v, 'value')}',
    ], getIndentString(indent));
  }
}

class CustomWidgetGenerator extends _SynappGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final name = node.properties['name'] as String?;
    final def = LogicCodegen.logic.customCode.where((c) => c.kind == 'widget' && c.name == name).firstOrNull;
    if (def == null) return '${getIndentString(indent)}const SizedBox.shrink()';
    LogicCodegen.imports.add('custom_code/widgets/${ProjectGenerator.customWidgetFileName(def.name)}');
    final given = node.properties['args'] as Map? ?? {};
    return call(LogicCodegen.typeName(def.name), [
      if (node.properties['width'] != null) 'width: ${node.properties['width']}',
      if (node.properties['height'] != null) 'height: ${node.properties['height']}',
      for (final arg in def.args)
        if (given[arg.name] != null || arg.required)
          '${LogicCodegen.ident(arg.name)}: ${given[arg.name] == null ? LogicCodegen.literal(arg.defaultValue, arg.type, isList: arg.isList) : LogicCodegen.coerce(given[arg.name], arg)}',
    ], getIndentString(indent));
  }
}

/// An instance of a project component with its arguments.
class ComponentInstanceGenerator extends _SynappGenerator {
  @override
  String generateCode(WidgetNode node, {int indent = 0}) {
    final component = ProjectGenerator.componentsById[node.properties['componentId']];
    if (component == null) return '${getIndentString(indent)}const SizedBox.shrink()';
    final file = ProjectGenerator.componentFileName(component);
    // Screens import components/x.dart; components import each other from the same folder via ../components/.
    LogicCodegen.imports.add('components/$file');
    final given = node.properties['args'] as Map? ?? {};
    final args = <String>[];
    for (final p in PageLogic.pageParams(component.properties)) {
      final value = given[p.name];
      if (p.type == VarTypes.action) {
        if (value is List && value.isNotEmpty) {
          args.add('${LogicCodegen.ident(p.name)}: () async {\n${LogicCodegen.statements(value, indent: '        ')}\n      }');
        } else if (p.required) {
          args.add('${LogicCodegen.ident(p.name)}: () async {}');
        }
        continue;
      }
      if (value == null && !p.required) continue;
      args.add('${LogicCodegen.ident(p.name)}: ${value == null ? LogicCodegen.literal(p.defaultValue, p.type, isList: p.isList) : LogicCodegen.coerce(value, p)}');
    }
    return call(ProjectGenerator.componentClassName(component), args, getIndentString(indent));
  }
}
