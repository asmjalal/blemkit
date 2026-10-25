import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../logic/logic_values.dart';
import '../../models/project_logic.dart';
import '../../models/widget_node.dart';
import '../../providers/widget_tree_provider.dart';
import '../../ui/editor_theme.dart';
import '../../ui/editor_widgets.dart';
import 'field_list_editor.dart';
import 'value_picker.dart';
import '../property_editors/action_flow_editor.dart';

/// Properties that can be bound to a value, by widget type. Generators read
/// these through `dartString`/`formatColor`/number interpolation, so a
/// binding becomes a Dart expression in the export.
const Map<String, List<String>> _bindableByType = {
  'Text': ['text', 'color', 'fontSize'],
  'SelectableText': ['text', 'color'],
  'Image': ['src', 'width', 'height'],
  'Avatar': ['src', 'radius'],
  'Container': ['color', 'width', 'height'],
  'AnimatedContainer': ['color', 'width', 'height'],
  'SizedBox': ['width', 'height'],
  'Button': ['text'],
  'ElevatedButton': ['text', 'backgroundColor', 'foregroundColor'],
  'TextButton': ['text'],
  'OutlinedButton': ['text'],
  'MaterialButton': ['text', 'color'],
  'Icon': ['color', 'size'],
  'Chip': ['label', 'backgroundColor'],
  'Badge': ['label'],
  'Tooltip': ['message'],
  'LinearProgressIndicator': ['value'],
  'CircularProgressIndicator': ['value'],
  'TextField': ['hintText', 'labelText'],
  'Card': ['color'],
  'RatingBar': ['rating'],
};

/// The Logic tab: bindings, conditional visibility, animation, accessibility,
/// API-backed lists, and page state/parameters for page roots.
class WidgetLogicPanel extends StatelessWidget {
  final WidgetNode node;

  const WidgetLogicPanel({super.key, required this.node});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final isPageRoot = provider.screens.any((s) => s.id == node.id);
    final isComponent = provider.isComponentRoot(node);
    final props = node.properties;

    return ListView(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 24),
      children: [
        if (isComponent) ...[
          EditorSection(
            title: 'Component parameters',
            icon: Icons.input_rounded,
            subtitle: 'Values and callbacks each instance provides',
            children: [
              FieldListEditor(
                fields: PageLogic.pageParams(props),
                namePrefix: 'param',
                addLabel: 'Add parameter',
                showRequired: true,
                allowActionType: true,
                emptyMessage: 'Add parameters such as title (String) or onTap (Action).',
                onChanged: (fields) => provider.setNodeProperty(node, 'pageParams', fields.map((f) => f.toJson()).toList()),
              ),
              const Text('Bind widgets inside to “Page parameter”. Run an Action parameter with “Run Component Callback”.',
                  style: TextStyle(fontSize: 11.5, color: EditorColors.textFaint, height: 1.4)),
            ],
          ),
          EditorSection(
            title: 'Component state',
            icon: Icons.description_outlined,
            children: [
              FieldListEditor(
                fields: PageLogic.pageState(props),
                namePrefix: 'value',
                addLabel: 'Add component state',
                emptyMessage: 'Local variables of each instance (e.g. isExpanded).',
                onChanged: (fields) => provider.setNodeProperty(node, 'pageState', fields.map((f) => f.toJson()).toList()),
              ),
            ],
          ),
        ],
        if (node.type == 'ComponentInstance') _ComponentArgsSection(node: node),
        if (isPageRoot) ...[
          EditorSection(
            title: 'Page parameters',
            icon: Icons.input_rounded,
            subtitle: 'Values passed when navigating to this page',
            children: [
              FieldListEditor(
                fields: PageLogic.pageParams(props),
                namePrefix: 'param',
                addLabel: 'Add parameter',
                showRequired: true,
                emptyMessage: 'No parameters. Add one (e.g. productId) and pass it from a Navigate action.',
                onChanged: (fields) => provider.setNodeProperty(node, 'pageParams', fields.map((f) => f.toJson()).toList()),
              ),
            ],
          ),
          EditorSection(
            title: 'Page state',
            icon: Icons.description_outlined,
            subtitle: 'Variables that live while this page is open',
            children: [
              FieldListEditor(
                fields: PageLogic.pageState(props),
                namePrefix: 'value',
                addLabel: 'Add page state',
                emptyMessage: 'No page state yet.',
                onChanged: (fields) {
                  provider.setNodeProperty(node, 'pageState', fields.map((f) => f.toJson()).toList());
                  provider.previewPageState.remove(node.id);
                },
              ),
            ],
          ),
        ],
        if (!isPageRoot && !isComponent) ...[
          _BindingsSection(node: node),
          _VisibilitySection(node: node),
          _AnimationSection(node: node),
          if (const {'ListView', 'GridView', 'Column', 'Row'}.contains(node.type)) _ApiListSection(node: node),
          if (node.type == 'CustomWidget') _CustomWidgetSection(node: node),
          EditorSection(
            title: 'Accessibility',
            icon: Icons.accessibility_new_rounded,
            initiallyExpanded: props['semanticLabel'] != null,
            children: [
              EditorField(
                label: 'Screen reader label',
                help: 'Read aloud by TalkBack and VoiceOver.',
                child: EditorTextInput(
                  value: '${props['semanticLabel'] ?? ''}',
                  hint: 'e.g. Add to cart',
                  onChanged: (v) => provider.setNodeProperty(node, 'semanticLabel', v.trim().isEmpty ? null : v),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _BindingsSection extends StatelessWidget {
  final WidgetNode node;

  const _BindingsSection({required this.node});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final bindings = Map<String, dynamic>.from(node.properties['bindings'] as Map? ?? {});
    final keys = {...?_bindableByType[node.type], ...bindings.keys}.toList();
    if (keys.isEmpty) return const SizedBox.shrink();

    return EditorSection(
      title: 'Bindings',
      icon: Icons.link_rounded,
      subtitle: 'Set properties from variables instead of fixed values',
      initiallyExpanded: bindings.isNotEmpty,
      children: [
        for (final key in keys)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Expanded(child: Text(key, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: EditorColors.textMuted))),
                  Switch(
                    value: bindings.containsKey(key),
                    onChanged: (on) {
                      final next = Map<String, dynamic>.from(bindings);
                      on ? next[key] = {'source': provider.logic.appState.isNotEmpty ? 'appState' : 'literal'} : next.remove(key);
                      provider.setNodeProperty(node, 'bindings', next);
                    },
                  ),
                ]),
                if (bindings.containsKey(key))
                  ValuePicker(
                    value: bindings[key],
                    allowOutputs: false,
                    onChanged: (v) => provider.setNodeProperty(node, 'bindings', {...bindings, key: v}),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _VisibilitySection extends StatelessWidget {
  final WidgetNode node;

  const _VisibilitySection({required this.node});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final rule = Map<String, dynamic>.from(node.properties['visibility'] as Map? ?? {});
    final hideOn = (rule['hideOn'] as List?)?.cast<String>() ?? <String>[];

    void save(Map<String, dynamic> next) {
      next.removeWhere((k, v) => v == null || (v is List && v.isEmpty));
      provider.setNodeProperty(node, 'visibility', next);
    }

    return EditorSection(
      title: 'Visibility',
      icon: Icons.visibility_outlined,
      subtitle: rule.isEmpty ? 'Always visible' : 'Conditional',
      initiallyExpanded: rule.isNotEmpty,
      children: [
        const EditorLabel('Hide on'),
        Wrap(spacing: 6, children: [
          for (final device in const ['phone', 'tablet', 'desktop'])
            EditorPill(
              label: device[0].toUpperCase() + device.substring(1),
              icon: device == 'phone' ? Icons.smartphone_rounded : device == 'tablet' ? Icons.tablet_mac_rounded : Icons.desktop_windows_outlined,
              selected: hideOn.contains(device),
              onTap: () => save({...rule, 'hideOn': hideOn.contains(device) ? (hideOn..remove(device)) : [...hideOn, device]}),
            ),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          const Expanded(child: Text('Show only when…', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: EditorColors.textMuted))),
          Switch(
            value: rule['condition'] != null,
            onChanged: (on) => save({...rule, 'condition': on ? {'op': 'isTrue'} : null}),
          ),
        ]),
        if (rule['condition'] != null)
          ConditionEditor(
            condition: rule['condition'],
            allowOutputs: false,
            onChanged: (c) => save({...rule, 'condition': c}),
          ),
        if (rule['condition'] != null)
          Text('Now: ${LogicValues.describeCondition(rule['condition'])}', style: const TextStyle(fontSize: 11, color: EditorColors.textFaint)),
      ],
    );
  }
}

class _AnimationSection extends StatelessWidget {
  final WidgetNode node;

  const _AnimationSection({required this.node});

  static const _types = {'none': 'None', 'fade': 'Fade', 'slideUp': 'Slide up', 'slideDown': 'Slide down', 'slideLeft': 'Slide left', 'slideRight': 'Slide right', 'scale': 'Scale', 'fadeScale': 'Pop'};

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final anim = Map<String, dynamic>.from(node.properties['animation'] as Map? ?? {});
    final type = anim['type'] as String? ?? 'none';

    void save(Map<String, dynamic> next) => provider.setNodeProperty(node, 'animation', next['type'] == 'none' ? null : next);

    return EditorSection(
      title: 'Entrance animation',
      icon: Icons.animation_rounded,
      subtitle: type == 'none' ? 'None' : _types[type],
      initiallyExpanded: type != 'none',
      trailing: type == 'none'
          ? null
          : EditorIconButton(
              icon: Icons.replay_rounded,
              tooltip: 'Replay',
              size: 16,
              onPressed: () => save({...anim, 'replay': DateTime.now().millisecondsSinceEpoch}),
            ),
      children: [
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final entry in _types.entries)
            EditorPill(label: entry.value, selected: type == entry.key, onTap: () => save({...anim, 'type': entry.key, 'durationMs': anim['durationMs'] ?? 400})),
        ]),
        if (type != 'none') ...[
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: EditorField(
                label: 'Duration (ms)',
                child: EditorTextInput(value: '${anim['durationMs'] ?? 400}', keyboardType: TextInputType.number, onChanged: (v) => save({...anim, 'durationMs': int.tryParse(v) ?? 400})),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: EditorField(
                label: 'Delay (ms)',
                child: EditorTextInput(value: '${anim['delayMs'] ?? 0}', keyboardType: TextInputType.number, onChanged: (v) => save({...anim, 'delayMs': int.tryParse(v) ?? 0})),
              ),
            ),
          ]),
        ],
      ],
    );
  }
}

class _ApiListSection extends StatelessWidget {
  final WidgetNode node;

  const _ApiListSection({required this.node});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final query = Map<String, dynamic>.from(node.properties['apiQuery'] as Map? ?? {});
    final call = provider.logic.apiCallById(query['apiCallId'] as String?);
    final vars = Map<String, dynamic>.from(query['variables'] as Map? ?? {});

    void save(Map<String, dynamic>? next) => provider.setNodeProperty(node, 'apiQuery', next);

    return EditorSection(
      title: 'API data',
      icon: Icons.api_rounded,
      subtitle: call == null ? 'Fill this ${node.type} from an API call' : call.name,
      initiallyExpanded: call != null,
      children: [
        if (provider.logic.apiCalls.isEmpty)
          const Text('Create an API call in Logic › API Calls first.', style: TextStyle(fontSize: 12, color: EditorColors.textFaint))
        else ...[
          EditorField(
            label: 'API call',
            child: EditorDropdown<String>(
              value: query['apiCallId'] as String?,
              items: ['', ...provider.logic.apiCalls.map((c) => c.id)],
              label: (id) => id.isEmpty ? 'None' : provider.logic.apiCallById(id)?.name ?? id,
              onChanged: (id) => save(id == null || id.isEmpty ? null : {'apiCallId': id, 'listPath': query['listPath'] ?? r'$'}),
            ),
          ),
          if (call != null) ...[
            EditorField(
              label: 'List path',
              help: r'JSON path to the list, e.g. $ or $.data.items. Each item is a row: bind children with “Supabase row field”.',
              child: EditorTextInput(value: '${query['listPath'] ?? r'$'}', onChanged: (v) => save({...query, 'listPath': v})),
            ),
            for (final v in call.variables)
              EditorField(label: 'Variable: ${v.name}', child: ValuePicker(value: vars[v.name], allowOutputs: false, onChanged: (val) => save({...query, 'variables': {...vars, v.name: val}}))),
          ],
        ],
      ],
    );
  }
}

class _CustomWidgetSection extends StatelessWidget {
  final WidgetNode node;

  const _CustomWidgetSection({required this.node});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final widgets = provider.logic.customCode.where((c) => c.kind == 'widget').toList();
    final def = widgets.where((w) => w.name == node.properties['name']).firstOrNull;
    final args = Map<String, dynamic>.from(node.properties['args'] as Map? ?? {});
    return EditorSection(
      title: 'Custom widget',
      icon: Icons.code_rounded,
      children: [
        EditorField(
          label: 'Widget',
          child: EditorDropdown<String>(
            value: node.properties['name'] as String?,
            items: widgets.map((w) => w.name).toList(),
            hint: 'Choose a custom widget',
            label: (n) => n,
            onChanged: (n) => provider.setNodeProperty(node, 'name', n),
          ),
        ),
        if (def != null)
          for (final arg in def.args)
            EditorField(
              label: '${arg.name}${arg.required ? ' *' : ''}',
              child: ValuePicker(value: args[arg.name], allowOutputs: false, onChanged: (v) => provider.setNodeProperty(node, 'args', {...args, arg.name: v})),
            ),
      ],
    );
  }
}

class _ComponentArgsSection extends StatelessWidget {
  final WidgetNode node;

  const _ComponentArgsSection({required this.node});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final component = provider.componentById(node.properties['componentId'] as String?);
    if (component == null) return const SizedBox.shrink();
    final args = Map<String, dynamic>.from(node.properties['args'] as Map? ?? {});
    final params = PageLogic.pageParams(component.properties);
    return EditorSection(
      title: PageLogic.componentName(component.properties) ?? 'Component',
      icon: Icons.extension_outlined,
      subtitle: 'Arguments for this instance',
      trailing: TextButton(onPressed: () => provider.selectScreen(component), child: const Text('Edit master')),
      children: [
        if (params.isEmpty) const Text('This component has no parameters.', style: TextStyle(fontSize: 12, color: EditorColors.textFaint)),
        for (final p in params)
          if (p.type == VarTypes.action)
            EditorField(
              label: '${p.name} (callback)${p.required ? ' *' : ''}',
              child: Container(
                padding: const EdgeInsets.only(left: 8),
                decoration: const BoxDecoration(border: Border(left: BorderSide(color: EditorColors.violet, width: 2))),
                child: ActionListEditor(
                  actions: (args[p.name] as List? ?? const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList(),
                  depth: 1,
                  onChanged: (list) => provider.setNodeProperty(node, 'args', {...args, p.name: list}),
                ),
              ),
            )
          else
            EditorField(
              label: '${p.name} · ${VarTypes.label(p.type, isList: p.isList)}${p.required ? ' *' : ''}',
              child: ValuePicker(value: args[p.name], allowOutputs: false, onChanged: (v) => provider.setNodeProperty(node, 'args', {...args, p.name: v})),
            ),
      ],
    );
  }
}
