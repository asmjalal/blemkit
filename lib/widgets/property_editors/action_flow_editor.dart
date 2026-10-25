import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/logic_values.dart';
import '../../models/project_logic.dart';
import '../../models/widget_node.dart';
import '../../providers/widget_tree_provider.dart';
import '../../ui/editor_theme.dart';
import '../../ui/editor_widgets.dart';
import '../logic/value_picker.dart';

/// Edits the action lists attached to a widget (tap, long press, double tap,
/// change, submit) or to a page (on page load).
class ActionFlowEditor extends StatefulWidget {
  final WidgetNode node;

  const ActionFlowEditor({super.key, required this.node});

  /// Triggers available for [node].
  static List<String> triggersFor(WidgetNode node, {required bool isPageRoot}) {
    if (isPageRoot) return const ['onPageLoad'];
    const inputs = {'TextField', 'Checkbox', 'Switch', 'Slider', 'DropdownButton', 'DropDown', 'RatingBar', 'PinCode', 'CounterButton', 'ChoiceChips', 'CheckboxGroup', 'RadioGroup', 'PlacePicker'};
    return [
      if (inputs.contains(node.type)) 'onChanged',
      if (node.type == 'TextField') 'onSubmitted',
      if (!inputs.contains(node.type) || node.type == 'Checkbox' || node.type == 'Switch') ...ActionCatalog.triggers,
    ];
  }

  @override
  State<ActionFlowEditor> createState() => _ActionFlowEditorState();
}

class _ActionFlowEditorState extends State<ActionFlowEditor> {
  String? _trigger;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final isPageRoot = provider.screens.any((s) => s.id == widget.node.id);
    final triggers = ActionFlowEditor.triggersFor(widget.node, isPageRoot: isPageRoot);
    final trigger = triggers.contains(_trigger) ? _trigger! : triggers.first;
    final actions = (widget.node.properties[trigger] as List? ?? const [])
        .whereType<Map>()
        .map((a) => Map<String, dynamic>.from(a))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 24),
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: triggers.map((t) {
            final count = (widget.node.properties[t] as List?)?.length ?? 0;
            return EditorPill(
              label: '${ActionCatalog.triggerLabels[t] ?? t}${count > 0 ? '  $count' : ''}',
              selected: t == trigger,
              onTap: () => setState(() => _trigger = t),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        if (actions.isEmpty)
          EditorEmptyState(
            icon: Icons.bolt_rounded,
            title: 'No actions yet',
            message: isPageRoot
                ? 'Run actions when this page opens: load data, set state, redirect…'
                : 'Add what should happen ${ActionCatalog.triggerLabels[trigger]?.toLowerCase() ?? ''}. Try them in Test mode.',
          ),
        ActionListEditor(
          actions: actions,
          onChanged: (next) => provider.setNodeProperty(widget.node, trigger, next),
        ),
      ],
    );
  }
}

/// An ordered list of actions; recursive for branches.
class ActionListEditor extends StatelessWidget {
  final List<Map<String, dynamic>> actions;
  final ValueChanged<List<Map<String, dynamic>>> onChanged;
  final int depth;

  const ActionListEditor({super.key, required this.actions, required this.onChanged, this.depth = 0});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < actions.length; i++)
          _ActionCard(
            key: ValueKey('$depth-$i-${actions[i]['type']}'),
            index: i,
            action: actions[i],
            depth: depth,
            onChanged: (a) => onChanged([...actions]..[i] = a),
            onDelete: () => onChanged([...actions]..removeAt(i)),
            onMoveUp: i == 0 ? null : () => onChanged([...actions]..removeAt(i)..insert(i - 1, actions[i])),
            onMoveDown: i == actions.length - 1 ? null : () => onChanged([...actions]..removeAt(i)..insert(i + 1, actions[i])),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
            label: Text(depth == 0 ? 'Add action' : 'Add'),
            onPressed: () async {
              final type = await showActionPicker(context);
              if (type != null) onChanged([...actions, _newAction(type)]);
            },
          ),
        ),
      ],
    );
  }

  static Map<String, dynamic> _newAction(String type) {
    switch (type) {
      case 'updateAppState':
      case 'updatePageState':
        return {'type': type, 'op': 'set'};
      case 'showSnackbar':
        return {'type': type, 'message': LogicValues.literal('Saved!')};
      case 'showDialog':
      case 'confirmDialog':
        return {'type': type, 'title': LogicValues.literal('Are you sure?'), 'message': LogicValues.literal('')};
      case 'haptic':
        return {'type': type, 'style': 'light'};
      case 'wait':
        return {'type': type, 'ms': 500};
      case 'conditional':
        return {'type': type, 'condition': {'op': '=='}, 'then': [], 'else': []};
    }
    return {'type': type};
  }
}

const Map<String, IconData> _categoryIcons = {
  'Navigation': Icons.alt_route_rounded,
  'State': Icons.data_object_rounded,
  'Feedback': Icons.chat_bubble_outline_rounded,
  'Logic': Icons.account_tree_outlined,
  'Utilities': Icons.handyman_outlined,
  'Backend': Icons.cloud_outlined,
  'Authentication': Icons.lock_outline_rounded,
};

IconData actionIcon(String? type) {
  switch (type) {
    case 'navigate':
      return Icons.arrow_forward_rounded;
    case 'navigateBack':
      return Icons.arrow_back_rounded;
    case 'openDrawer':
      return Icons.menu_open_rounded;
    case 'conditional':
      return Icons.call_split_rounded;
    case 'wait':
      return Icons.timer_outlined;
    case 'terminate':
      return Icons.stop_circle_outlined;
    case 'apiCall':
      return Icons.api_rounded;
    case 'launchUrl':
      return Icons.open_in_new_rounded;
    case 'copyToClipboard':
      return Icons.copy_rounded;
    case 'share':
      return Icons.ios_share_rounded;
    case 'haptic':
      return Icons.vibration_rounded;
    case 'toggleThemeMode':
      return Icons.dark_mode_outlined;
    case 'setLanguage':
      return Icons.translate_rounded;
    case 'customAction':
      return Icons.code_rounded;
  }
  final category = ActionCatalog.spec(type)?.category;
  return _categoryIcons[category] ?? Icons.bolt_rounded;
}

/// Searchable list of action types; returns the chosen type.
Future<String?> showActionPicker(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (context) => const _ActionPickerDialog(),
  );
}

class _ActionPickerDialog extends StatefulWidget {
  const _ActionPickerDialog();

  @override
  State<_ActionPickerDialog> createState() => _ActionPickerDialogState();
}

class _ActionPickerDialogState extends State<_ActionPickerDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final matches = ActionCatalog.all.where((a) => _query.isEmpty || a.label.toLowerCase().contains(_query.toLowerCase())).toList();
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Add action', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              TextField(
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Search actions', prefixIcon: Icon(Icons.search_rounded, size: 18)),
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView(
                  children: [
                    for (final category in ActionCatalog.categories)
                      if (matches.any((a) => a.category == category)) ...[
                        EditorLabel(category),
                        for (final spec in matches.where((a) => a.category == category))
                          EditorListTile(
                            icon: actionIcon(spec.type),
                            title: spec.label,
                            onTap: () => Navigator.pop(context, spec.type),
                          ),
                        const SizedBox(height: 6),
                      ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final int index;
  final Map<String, dynamic> action;
  final int depth;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final VoidCallback onDelete;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  const _ActionCard({
    super.key,
    required this.index,
    required this.action,
    required this.depth,
    required this.onChanged,
    required this.onDelete,
    this.onMoveUp,
    this.onMoveDown,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final action = widget.action;
    final spec = ActionCatalog.spec(action['type'] as String?);
    final summary = _summary(provider, action);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: EditorColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _expanded ? EditorColors.borderStrong : EditorColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(color: EditorColors.accentSoft, borderRadius: BorderRadius.circular(7)),
                    child: Icon(actionIcon(action['type'] as String?), size: 15, color: EditorColors.accent),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(spec?.label ?? '${action['type']}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                        if (summary.isNotEmpty)
                          Text(summary, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: EditorColors.textFaint)),
                      ],
                    ),
                  ),
                  EditorIconButton(icon: Icons.arrow_upward_rounded, tooltip: 'Move up', size: 14, onPressed: widget.onMoveUp),
                  EditorIconButton(icon: Icons.arrow_downward_rounded, tooltip: 'Move down', size: 14, onPressed: widget.onMoveDown),
                  EditorIconButton(icon: Icons.delete_outline_rounded, tooltip: 'Delete action', size: 15, onPressed: widget.onDelete),
                ],
              ),
            ),
          ),
          if (_expanded && spec != null && (spec.params.isNotEmpty || action['type'] == 'navigate'))
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [for (final param in spec.params) ..._paramEditor(context, provider, param)],
              ),
            ),
        ],
      ),
    );
  }

  void _set(String key, dynamic value) => widget.onChanged({...widget.action, key: value});

  List<Widget> _paramEditor(BuildContext context, WidgetTreeProvider provider, ActionParamSpec param) {
    final a = widget.action;
    switch (param.kind) {
      case ActionParamKind.value:
        return [EditorField(label: param.label, child: ValuePicker(value: a[param.key], onChanged: (v) => _set(param.key, v)))];
      case ActionParamKind.text:
        if (a['type'] == 'callParameterAction') {
          final callbacks = PageLogic.pageParams(provider.selectedScreen?.properties ?? const {}).where((p) => p.type == VarTypes.action).map((p) => p.name).toList();
          return [_namePicker(param, callbacks, 'Add an Action parameter to this component first (Logic tab of the component).')];
        }
        return [EditorField(label: param.label, child: EditorTextInput(value: '${a[param.key] ?? ''}', onChanged: (v) => _set(param.key, v)))];
      case ActionParamKind.number:
        return [
          EditorField(
            label: param.label,
            child: EditorTextInput(value: '${a[param.key] ?? ''}', keyboardType: TextInputType.number, onChanged: (v) => _set(param.key, int.tryParse(v))),
          )
        ];
      case ActionParamKind.choice:
        return [
          EditorField(
            label: param.label,
            child: Wrap(spacing: 6, runSpacing: 6, children: [
              for (final c in param.choices) EditorPill(label: c, selected: (a[param.key] ?? param.choices.first) == c, onTap: () => _set(param.key, c)),
            ]),
          )
        ];
      case ActionParamKind.stateOp:
        return [
          EditorField(
            label: param.label,
            child: Wrap(spacing: 6, runSpacing: 6, children: [
              for (final op in ActionCatalog.stateOps) EditorPill(label: op, selected: (a['op'] ?? 'set') == op, onTap: () => _set('op', op)),
            ]),
          )
        ];
      case ActionParamKind.appStateVar:
        return [_namePicker(param, provider.logic.appState.map((f) => f.name).toList(), 'Define app state in Logic › App State.')];
      case ActionParamKind.pageStateVar:
        return [
          _namePicker(param, PageLogic.pageState(provider.selectedScreen?.properties ?? const {}).map((f) => f.name).toList(),
              'Select the page and add page state in its Logic tab.')
        ];
      case ActionParamKind.page:
        final target = provider.screens.where((s) => s.id == a['targetScreenId']).firstOrNull;
        final params = target == null ? <FieldDef>[] : PageLogic.pageParams(target.properties);
        final given = Map<String, dynamic>.from(a['params'] as Map? ?? {});
        return [
          EditorField(
            label: param.label,
            child: EditorDropdown<String>(
              value: a['targetScreenId'] as String?,
              items: provider.screens.map((s) => s.id).toList(),
              hint: 'Choose a page',
              label: (id) => '${provider.screens.firstWhere((s) => s.id == id).properties['pageName'] ?? 'Page'}',
              onChanged: (id) => widget.onChanged({...a, 'targetScreenId': id, 'params': {}}),
            ),
          ),
          for (final p in params)
            EditorField(
              label: 'Parameter: ${p.name}${p.required ? ' *' : ''}',
              child: ValuePicker(value: given[p.name], onChanged: (v) => _set('params', {...given, p.name: v})),
            ),
        ];
      case ActionParamKind.apiCall:
        final call = provider.logic.apiCallById(a['apiCallId'] as String?);
        final vars = Map<String, dynamic>.from(a['variables'] as Map? ?? {});
        return [
          EditorField(
            label: param.label,
            help: provider.logic.apiCalls.isEmpty ? 'Create API calls in Logic › API Calls.' : null,
            child: EditorDropdown<String>(
              value: a['apiCallId'] as String?,
              items: provider.logic.apiCalls.map((c) => c.id).toList(),
              hint: 'Choose an API call',
              label: (id) => provider.logic.apiCallById(id)?.name ?? id,
              onChanged: (id) => widget.onChanged({...a, 'apiCallId': id, 'variables': {}}),
            ),
          ),
          if (call != null)
            for (final v in call.variables)
              EditorField(label: 'Variable: ${v.name}', child: ValuePicker(value: vars[v.name], onChanged: (val) => _set('variables', {...vars, v.name: val}))),
        ];
      case ActionParamKind.customAction:
        final actions = provider.logic.customCode.where((c) => c.kind == 'action').toList();
        final fn = actions.where((c) => c.name == a['name']).firstOrNull;
        final args = Map<String, dynamic>.from(a['args'] as Map? ?? {});
        return [
          EditorField(
            label: param.label,
            help: actions.isEmpty ? 'Write custom actions in Logic › Custom Code.' : null,
            child: EditorDropdown<String>(
              value: a['name'] as String?,
              items: actions.map((c) => c.name).toList(),
              hint: 'Choose a custom action',
              label: (n) => n,
              onChanged: (n) => widget.onChanged({...a, 'name': n, 'args': {}}),
            ),
          ),
          if (fn != null)
            for (final arg in fn.args)
              EditorField(label: 'Argument: ${arg.name}', child: ValuePicker(value: args[arg.name], onChanged: (v) => _set('args', {...args, arg.name: v}))),
        ];
      case ActionParamKind.table:
        final tables = provider.activeConnection?.tables ?? const [];
        final table = tables.where((t) => t.name == a['tableName']).firstOrNull;
        final payload = Map<String, dynamic>.from(a['payload'] as Map? ?? {});
        return [
          EditorField(
            label: param.label,
            help: tables.isEmpty ? 'Connect Supabase in the Data tab to pick a table.' : null,
            child: tables.isEmpty
                ? EditorTextInput(value: '${a['tableName'] ?? ''}', hint: 'table_name', onChanged: (v) => _set('tableName', v))
                : EditorDropdown<String>(
                    value: a['tableName'] as String?,
                    items: tables.map((t) => t.name).toList(),
                    hint: 'Choose a table',
                    label: (t) => t,
                    onChanged: (t) => widget.onChanged({...a, 'tableName': t, 'payload': {}}),
                  ),
          ),
          if (table != null && a['type'] != 'supabase_delete') ...[
            const EditorLabel('Row values'),
            for (final column in table.columns.where((c) => c.name != 'id' && c.name != 'created_at'))
              EditorField(
                label: '${column.name} · ${column.dataType}',
                child: ValuePicker(
                  value: _payloadAsValue(payload[column.name]),
                  onChanged: (v) => _set('payload', {...payload, column.name: v}),
                ),
              ),
          ],
          if (a['type'] != 'supabase_insert')
            const Text('Targets the row in the current list item, or the page’s idParam.', style: TextStyle(fontSize: 11, color: EditorColors.textFaint)),
        ];
      case ActionParamKind.condition:
        return [
          const EditorLabel('Condition'),
          ConditionEditor(condition: a['condition'], onChanged: (c) => _set('condition', c)),
          const SizedBox(height: 8),
        ];
      case ActionParamKind.actions:
        final branch = (a[param.key] as List? ?? const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        return [
          Container(
            margin: const EdgeInsets.only(top: 4, bottom: 6),
            padding: const EdgeInsets.fromLTRB(10, 6, 6, 4),
            decoration: const BoxDecoration(border: Border(left: BorderSide(color: EditorColors.accent, width: 2))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(param.label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: EditorColors.accent)),
                const SizedBox(height: 6),
                ActionListEditor(actions: branch, depth: widget.depth + 1, onChanged: (list) => _set(param.key, list)),
              ],
            ),
          ),
        ];
    }
  }

  /// Converts the legacy payload format to a value map.
  dynamic _payloadAsValue(dynamic entry) {
    if (LogicValues.isValue(entry) || entry is! Map) return entry;
    switch (entry['type']) {
      case 'widget_state':
        return {'source': 'widgetState', 'widgetId': entry['value'], 'widgetType': 'TextField'};
      case 'query_data':
        return {'source': 'queryField', 'field': entry['value']};
    }
    return LogicValues.literal(entry['value'] ?? '');
  }

  Widget _namePicker(ActionParamSpec param, List<String> names, String help) {
    return EditorField(
      label: param.label,
      help: names.isEmpty ? help : null,
      child: EditorDropdown<String>(
        value: widget.action[param.key] as String?,
        items: names,
        hint: 'Choose…',
        label: (n) => n,
        onChanged: (n) => _set(param.key, n),
      ),
    );
  }

  String _summary(WidgetTreeProvider provider, Map<String, dynamic> a) {
    switch (a['type']) {
      case 'navigate':
        final target = provider.screens.where((s) => s.id == a['targetScreenId']).firstOrNull;
        return target == null ? 'Choose a page' : '→ ${target.properties['pageName'] ?? 'Page'}';
      case 'updateAppState':
      case 'updatePageState':
        return a['name'] == null ? 'Choose a variable' : '${a['name']} · ${a['op'] ?? 'set'}${a['value'] != null ? ' ${LogicValues.describe(a['value'])}' : ''}';
      case 'showSnackbar':
        return LogicValues.describe(a['message']);
      case 'conditional':
        return 'If ${LogicValues.describeCondition(a['condition'])}';
      case 'apiCall':
        return provider.logic.apiCallById(a['apiCallId'] as String?)?.name ?? 'Choose an API call';
      case 'wait':
        return '${a['ms'] ?? 500} ms';
      case 'launchUrl':
        return LogicValues.describe(a['url']);
      case 'supabase_insert':
      case 'supabase_update':
      case 'supabase_delete':
        return '${a['tableName'] ?? 'Choose a table'}';
      case 'customAction':
        return '${a['name'] ?? 'Choose an action'}';
    }
    return '';
  }
}
