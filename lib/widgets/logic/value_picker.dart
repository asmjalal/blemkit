import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/logic_values.dart';
import '../../models/project_logic.dart';
import '../../models/widget_node.dart';
import '../../providers/widget_tree_provider.dart';
import '../../ui/editor_theme.dart';
import '../../ui/editor_widgets.dart';

/// Input widgets whose current value can be read as "Widget state".
const Set<String> kInputWidgetTypes = {
  'TextField', 'Checkbox', 'CheckboxListTile', 'Switch', 'SwitchListTile', 'Slider', 'DropdownButton', 'DropDown',
  'RatingBar', 'PinCode', 'CounterButton', 'ChoiceChips', 'CheckboxGroup', 'RadioGroup', 'PlacePicker',
};

/// Input widgets on [screen], for the "Widget state" source.
List<WidgetNode> inputWidgetsOn(WidgetNode? screen) {
  final found = <WidgetNode>[];
  void visit(dynamic value) {
    if (value is WidgetNode) {
      if (kInputWidgetTypes.contains(value.type)) found.add(value);
      value.children.forEach(visit);
      value.properties.values.forEach(visit);
    } else if (value is List) {
      value.forEach(visit);
    }
  }

  visit(screen);
  return found;
}

String inputLabel(WidgetNode node) {
  final hint = node.properties['labelText'] ?? node.properties['hintText'] ?? node.properties['label'] ?? node.properties['title'];
  final shortId = node.id.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
  return hint is String && hint.isNotEmpty ? '${node.type} · $hint' : '${node.type} · ${shortId.substring(0, shortId.length.clamp(0, 5))}';
}

/// Edits a value map (see `LogicValues`): where a value comes from and which
/// variable or literal it is.
class ValuePicker extends StatelessWidget {
  final dynamic value;
  final ValueChanged<Map<String, dynamic>?> onChanged;

  /// Sources to offer; defaults to everything that makes sense in [context].
  final List<String>? sources;
  final String? literalHint;
  final bool allowOutputs;

  const ValuePicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.sources,
    this.literalHint,
    this.allowOutputs = true,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final current = LogicValues.isValue(value) ? Map<String, dynamic>.from(value as Map) : LogicValues.literal(value ?? '');
    final source = current['source'] as String;
    final screenProps = provider.selectedScreen?.properties ?? const {};
    final available = sources ??
        LogicValues.sources.where((s) {
          switch (s) {
            case 'appState':
              return provider.logic.appState.isNotEmpty;
            case 'pageState':
              return PageLogic.pageState(screenProps).isNotEmpty;
            case 'pageParam':
              return PageLogic.pageParams(screenProps).isNotEmpty;
            case 'widgetState':
              return inputWidgetsOn(provider.selectedScreen).isNotEmpty;
            case 'actionOutput':
              return allowOutputs;
            case 'env':
              return provider.logic.envValues.isNotEmpty;
            case 'function':
              return provider.logic.customCode.any((c) => c.kind == 'function');
            case 'translation':
              return provider.logic.translations.isNotEmpty;
            case 'authUser':
              return provider.logic.usesAuth;
          }
          return true;
        }).toList();
    if (!available.contains(source)) available.insert(0, source);

    void set(Map<String, dynamic> next) => onChanged(next);

    Widget detail;
    switch (source) {
      case 'literal':
        detail = EditorTextInput(
          value: '${current['value'] ?? ''}',
          hint: literalHint ?? 'Value',
          // Stored as typed; codegen and the preview convert to the target type.
          onChanged: (v) => set({'source': 'literal', 'value': v}),
        );
        break;
      case 'appState':
        detail = _names(provider.logic.appState.map((f) => f.name).toList(), current['name'], (n) => set({'source': 'appState', 'name': n}));
        break;
      case 'pageState':
        detail = _names(PageLogic.pageState(screenProps).map((f) => f.name).toList(), current['name'], (n) => set({'source': 'pageState', 'name': n}));
        break;
      case 'pageParam':
        detail = _names(PageLogic.pageParams(screenProps).map((f) => f.name).toList(), current['name'], (n) => set({'source': 'pageParam', 'name': n}));
        break;
      case 'widgetState':
        final inputs = inputWidgetsOn(provider.selectedScreen);
        detail = EditorDropdown<String>(
          value: current['widgetId'] as String?,
          items: inputs.map((w) => w.id).toList(),
          hint: 'Choose an input',
          label: (id) => inputLabel(inputs.firstWhere((w) => w.id == id)),
          onChanged: (id) {
            final w = inputs.firstWhere((w) => w.id == id);
            set({'source': 'widgetState', 'widgetId': w.id, 'widgetType': w.type, 'widgetLabel': inputLabel(w)});
          },
        );
        break;
      case 'queryField':
        final columns = <String>{
          for (final t in provider.activeConnection?.tables ?? const []) ...t.columns.map((c) => c.name),
        }.toList()
          ..sort();
        detail = columns.isEmpty
            ? EditorTextInput(value: '${current['field'] ?? ''}', hint: 'Column name', onChanged: (v) => set({'source': 'queryField', 'field': v}))
            : _names(columns, current['field'], (n) => set({'source': 'queryField', 'field': n}));
        break;
      case 'actionOutput':
        detail = Row(children: [
          Expanded(child: EditorTextInput(value: '${current['name'] ?? ''}', hint: 'Output name', onChanged: (v) => set({...current, 'name': v}))),
          const SizedBox(width: 6),
          Expanded(child: EditorTextInput(value: '${current['path'] ?? ''}', hint: r'$.path', onChanged: (v) => set({...current, 'path': v}))),
        ]);
        break;
      case 'env':
        detail = _names(provider.logic.envValues.map((e) => e.name).toList(), current['name'], (n) => set({'source': 'env', 'name': n}));
        break;
      case 'authUser':
        detail = _names(const ['email', 'id', 'isLoggedIn'], current['field'] ?? 'email', (n) => set({'source': 'authUser', 'field': n}));
        break;
      case 'translation':
        detail = _names(provider.logic.translations.keys.toList(), current['key'], (n) => set({'source': 'translation', 'key': n}));
        break;
      case 'function':
        final fns = provider.logic.customCode.where((c) => c.kind == 'function').toList();
        final fn = fns.where((f) => f.name == current['name']).firstOrNull;
        final args = Map<String, dynamic>.from(current['args'] as Map? ?? {});
        detail = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _names(fns.map((f) => f.name).toList(), current['name'], (n) => set({'source': 'function', 'name': n, 'args': {}})),
          if (fn != null)
            for (final arg in fn.args)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 10),
                child: EditorField(
                  label: '${arg.name} (${VarTypes.label(arg.type, isList: arg.isList)})',
                  child: ValuePicker(
                    value: args[arg.name],
                    allowOutputs: allowOutputs,
                    onChanged: (v) => set({...current, 'args': {...args, arg.name: v}}),
                  ),
                ),
              ),
        ]);
        break;
      default:
        detail = const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: EditorColors.background.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EditorColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EditorDropdown<String>(
            value: source,
            items: available,
            label: (s) => LogicValues.sourceLabels[s] ?? s,
            leading: (s) => Icon(_sourceIcon(s), size: 14, color: EditorColors.accent),
            onChanged: (s) {
              if (s == null || s == source) return;
              set(s == 'literal' ? LogicValues.literal('') : {'source': s});
            },
          ),
          if (source != 'screenWidth') ...[const SizedBox(height: 6), detail],
        ],
      ),
    );
  }

  Widget _names(List<String> names, dynamic current, ValueChanged<String> onPick) {
    if (names.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(6),
        child: Text('Nothing defined yet.', style: TextStyle(fontSize: 12, color: EditorColors.textFaint)),
      );
    }
    return EditorDropdown<String>(
      value: current as String?,
      items: names,
      hint: 'Choose…',
      label: (n) => n,
      onChanged: (n) {
        if (n != null) onPick(n);
      },
    );
  }

  static IconData _sourceIcon(String s) {
    switch (s) {
      case 'appState':
        return Icons.public_rounded;
      case 'pageState':
        return Icons.description_outlined;
      case 'pageParam':
        return Icons.input_rounded;
      case 'widgetState':
        return Icons.edit_note_rounded;
      case 'queryField':
        return Icons.table_rows_outlined;
      case 'actionOutput':
        return Icons.output_rounded;
      case 'env':
        return Icons.dns_outlined;
      case 'authUser':
        return Icons.person_outline_rounded;
      case 'function':
        return Icons.functions_rounded;
      case 'translation':
        return Icons.translate_rounded;
      case 'screenWidth':
        return Icons.straighten_rounded;
    }
    return Icons.text_fields_rounded;
  }
}

/// Edits a condition: one comparison, or several joined with AND/OR.
class ConditionEditor extends StatelessWidget {
  final dynamic condition;
  final ValueChanged<Map<String, dynamic>?> onChanged;
  final bool allowOutputs;

  const ConditionEditor({super.key, required this.condition, required this.onChanged, this.allowOutputs = true});

  @override
  Widget build(BuildContext context) {
    final cond = condition is Map ? Map<String, dynamic>.from(condition as Map) : <String, dynamic>{'op': '=='};
    final parts = cond['conditions'] is List
        ? (cond['conditions'] as List).map((c) => Map<String, dynamic>.from(c as Map)).toList()
        : [cond];
    final combine = cond['combine'] == 'or' ? 'or' : 'and';

    void emit(List<Map<String, dynamic>> next, String joiner) {
      if (next.isEmpty) return onChanged(null);
      onChanged(next.length == 1 ? next.first : {'combine': joiner, 'conditions': next});
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < parts.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(children: [
                EditorPill(label: 'AND', selected: combine == 'and', onTap: () => emit(parts, 'and')),
                const SizedBox(width: 6),
                EditorPill(label: 'OR', selected: combine == 'or', onTap: () => emit(parts, 'or')),
              ]),
            ),
          _Comparison(
            comparison: parts[i],
            allowOutputs: allowOutputs,
            onChanged: (c) => emit([...parts]..[i] = c, combine),
            onRemove: parts.length > 1 ? () => emit([...parts]..removeAt(i), combine) : null,
          ),
        ],
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => emit([...parts, {'op': '=='}], combine),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Add condition'),
          ),
        ),
      ],
    );
  }
}

class _Comparison extends StatelessWidget {
  final Map<String, dynamic> comparison;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final VoidCallback? onRemove;
  final bool allowOutputs;

  const _Comparison({required this.comparison, required this.onChanged, this.onRemove, required this.allowOutputs});

  @override
  Widget build(BuildContext context) {
    final op = comparison['op'] as String? ?? '==';
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: EditorColors.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: EditorColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            const Expanded(child: Text('Value', style: TextStyle(fontSize: 11, color: EditorColors.textFaint))),
            if (onRemove != null)
              EditorIconButton(icon: Icons.close_rounded, tooltip: 'Remove condition', size: 14, onPressed: onRemove),
          ]),
          const SizedBox(height: 4),
          ValuePicker(value: comparison['left'], allowOutputs: allowOutputs, onChanged: (v) => onChanged({...comparison, 'left': v})),
          const SizedBox(height: 6),
          EditorDropdown<String>(
            value: op,
            items: LogicValues.operators,
            label: (o) => LogicValues.operatorLabels[o] ?? o,
            onChanged: (o) => onChanged({...comparison, 'op': o}),
          ),
          if (!LogicValues.isUnary(op)) ...[
            const SizedBox(height: 6),
            ValuePicker(value: comparison['right'], allowOutputs: allowOutputs, onChanged: (v) => onChanged({...comparison, 'right': v})),
          ],
        ],
      ),
    );
  }
}
