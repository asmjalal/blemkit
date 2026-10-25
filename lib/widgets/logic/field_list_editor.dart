import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/project_logic.dart';
import '../../providers/widget_tree_provider.dart';
import '../../ui/editor_theme.dart';
import '../../ui/editor_widgets.dart';

/// Edits a list of typed fields: app/page state, page parameters, data type
/// fields and API or custom-code arguments.
class FieldListEditor extends StatelessWidget {
  final List<FieldDef> fields;
  final ValueChanged<List<FieldDef>> onChanged;
  final String addLabel;
  final String namePrefix;
  final bool showPersisted;
  final bool showRequired;
  final bool showDefault;
  final bool allowCustomTypes;
  final bool allowActionType;
  final String emptyMessage;

  const FieldListEditor({
    super.key,
    required this.fields,
    required this.onChanged,
    this.addLabel = 'Add field',
    this.namePrefix = 'field',
    this.showPersisted = false,
    this.showRequired = false,
    this.showDefault = true,
    this.allowCustomTypes = true,
    this.allowActionType = false,
    this.emptyMessage = 'Nothing here yet.',
  });

  @override
  Widget build(BuildContext context) {
    final logic = Provider.of<WidgetTreeProvider>(context).logic;
    final types = [
      ...VarTypes.primitives,
      if (allowCustomTypes) ...logic.dataTypes.map((t) => 'DataType:${t.name}'),
      if (allowCustomTypes) ...logic.enums.map((e) => 'Enum:${e.name}'),
      if (allowActionType) VarTypes.action,
    ];

    void update(int index, FieldDef next) {
      final copy = fields.map((f) => f.copy()).toList();
      copy[index] = next;
      onChanged(copy);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (fields.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(emptyMessage, style: const TextStyle(fontSize: 12, color: EditorColors.textFaint)),
          ),
        for (var i = 0; i < fields.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
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
                  Expanded(
                    flex: 5,
                    child: EditorTextInput(
                      value: fields[i].name,
                      hint: 'name',
                      onChanged: (v) => update(i, fields[i].copy()..name = v.replaceAll(RegExp(r'[^a-zA-Z0-9_ ]'), '')),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    flex: 4,
                    child: EditorDropdown<String>(
                      value: types.contains(fields[i].type) ? fields[i].type : VarTypes.string,
                      items: types,
                      label: (t) => VarTypes.label(t),
                      onChanged: (t) => update(i, fields[i].copy()
                        ..type = t ?? VarTypes.string
                        ..defaultValue = null),
                    ),
                  ),
                  EditorIconButton(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Delete',
                    size: 16,
                    onPressed: () => onChanged([...fields]..removeAt(i)),
                  ),
                ]),
                const SizedBox(height: 6),
                Wrap(spacing: 6, runSpacing: 6, crossAxisAlignment: WrapCrossAlignment.center, children: [
                  EditorPill(
                    label: 'List',
                    icon: Icons.data_array_rounded,
                    selected: fields[i].isList,
                    onTap: () => update(i, fields[i].copy()..isList = !fields[i].isList),
                  ),
                  if (showPersisted)
                    EditorPill(
                      label: 'Persisted',
                      icon: Icons.save_outlined,
                      selected: fields[i].persisted,
                      onTap: () => update(i, fields[i].copy()..persisted = !fields[i].persisted),
                    ),
                  if (showRequired)
                    EditorPill(
                      label: 'Required',
                      icon: Icons.priority_high_rounded,
                      selected: fields[i].required,
                      onTap: () => update(i, fields[i].copy()..required = !fields[i].required),
                    ),
                ]),
                if (showDefault && !VarTypes.isDataType(fields[i].type) && fields[i].type != VarTypes.action) ...[
                  const SizedBox(height: 6),
                  EditorTextInput(
                    value: fields[i].defaultValue == null
                        ? ''
                        : (fields[i].defaultValue is List ? (fields[i].defaultValue as List).join(', ') : '${fields[i].defaultValue}'),
                    hint: fields[i].isList ? 'Default items, comma separated' : _defaultHint(fields[i].type, logic),
                    onChanged: (v) => update(i, fields[i].copy()..defaultValue = v.isEmpty ? null : v),
                  ),
                ],
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              var n = fields.length + 1;
              while (fields.any((f) => f.name == '$namePrefix$n')) {
                n++;
              }
              onChanged([...fields, FieldDef(name: '$namePrefix$n')]);
            },
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text(addLabel),
          ),
        ),
      ],
    );
  }

  String _defaultHint(String type, ProjectLogic logic) {
    switch (type) {
      case VarTypes.integer:
        return 'Default (e.g. 0)';
      case VarTypes.decimal:
        return 'Default (e.g. 0.0)';
      case VarTypes.boolean:
        return 'Default (true / false)';
      case VarTypes.color:
        return 'Default (#4F46E5)';
      case VarTypes.dateTime:
        return 'Default (2026-01-31)';
    }
    if (VarTypes.isEnum(type)) {
      final e = logic.enums.where((e) => e.name == VarTypes.refName(type)).firstOrNull;
      return 'Default (${e?.values.join(' / ') ?? 'value'})';
    }
    return 'Default value';
  }
}
