import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/json_path.dart';
import '../models/project_logic.dart';
import '../providers/widget_tree_provider.dart';
import '../services/api_service.dart';
import '../ui/editor_theme.dart';
import '../ui/editor_widgets.dart';
import '../widgets/logic/field_list_editor.dart';

/// Project-wide logic: app state, data types, enums, API calls, custom code,
/// environments, packages, authentication, languages and app icon.
class ProjectLogicScreen extends StatefulWidget {
  final String initialSection;

  const ProjectLogicScreen({super.key, this.initialSection = 'appState'});

  @override
  State<ProjectLogicScreen> createState() => _ProjectLogicScreenState();
}

class _Section {
  final String id;
  final String label;
  final IconData icon;
  final String group;
  const _Section(this.id, this.label, this.icon, this.group);
}

const _sections = [
  _Section('appState', 'App State', Icons.public_rounded, 'Data'),
  _Section('dataTypes', 'Data Types', Icons.data_object_rounded, 'Data'),
  _Section('enums', 'Enums', Icons.format_list_bulleted_rounded, 'Data'),
  _Section('api', 'API Calls', Icons.api_rounded, 'Backend'),
  _Section('auth', 'Authentication', Icons.lock_outline_rounded, 'Backend'),
  _Section('env', 'Environments', Icons.dns_outlined, 'Backend'),
  _Section('code', 'Custom Code', Icons.code_rounded, 'Code'),
  _Section('packages', 'Packages', Icons.inventory_2_outlined, 'Code'),
  _Section('i18n', 'Languages', Icons.translate_rounded, 'App'),
  _Section('icon', 'App Icon & Splash', Icons.image_outlined, 'App'),
];

class _ProjectLogicScreenState extends State<ProjectLogicScreen> {
  late String _section = widget.initialSection;

  @override
  Widget build(BuildContext context) {
    final current = _sections.firstWhere((s) => s.id == _section, orElse: () => _sections.first);
    return Scaffold(
      backgroundColor: EditorColors.background,
      appBar: AppBar(
        backgroundColor: EditorColors.surface,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 0,
        title: const Text('Logic & Data', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        shape: const Border(bottom: BorderSide(color: EditorColors.border)),
      ),
      body: Row(
        children: [
          Container(
            width: 230,
            decoration: const BoxDecoration(color: EditorColors.surface, border: Border(right: BorderSide(color: EditorColors.border))),
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final group in const ['Data', 'Backend', 'Code', 'App']) ...[
                  EditorLabel(group),
                  for (final s in _sections.where((s) => s.group == group))
                    EditorListTile(icon: s.icon, title: s.label, selected: s.id == _section, onTap: () => setState(() => _section = s.id)),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(32, 28, 32, 48),
                  children: [
                    Row(children: [
                      Icon(current.icon, color: EditorColors.accent),
                      const SizedBox(width: 10),
                      Text(current.label, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    ]),
                    const SizedBox(height: 6),
                    Text(_descriptions[current.id] ?? '', style: const TextStyle(fontSize: 13.5, color: EditorColors.textMuted, height: 1.5)),
                    const SizedBox(height: 22),
                    _body(current.id),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _descriptions = {
    'appState': 'Variables shared by every page. Persisted values survive app restarts (shared_preferences). Bind them to widgets and change them with "Update App State".',
    'dataTypes': 'Structured types (like CartItem) for state variables, parameters and API data. Exported as Dart classes with fromMap/toMap.',
    'enums': 'Fixed sets of values, such as OrderStatus { pending, shipped }.',
    'api': 'REST calls with [variable] placeholders. Test them here, pick response fields, then use them in "API Call" actions or to fill a list.',
    'auth': 'Sign-in for the exported app. Uses Supabase Auth from the connected Supabase project.',
    'env': 'Values that differ per environment (API base URLs, keys). Pick the environment at build time with --dart-define=APP_ENV=…',
    'code': 'Write Dart for anything the visual editor cannot do. Functions are pure helpers, actions run async with BuildContext, widgets render custom UI.',
    'packages': 'Extra pub.dev packages added to the exported pubspec.yaml. Import them from custom code.',
    'i18n': 'Languages and translated texts. Bind a Text to "Translated text" and switch with the "Set Language" action.',
    'icon': 'Launcher icon and splash screen for the exported app (flutter_launcher_icons and flutter_native_splash).',
  };

  Widget _body(String id) {
    switch (id) {
      case 'appState':
        return const _AppStateSection();
      case 'dataTypes':
        return const _DataTypesSection();
      case 'enums':
        return const _EnumsSection();
      case 'api':
        return const _ApiCallsSection();
      case 'auth':
        return const _AuthSection();
      case 'env':
        return const _EnvSection();
      case 'code':
        return const _CustomCodeSection();
      case 'packages':
        return const _PackagesSection();
      case 'i18n':
        return const _LanguagesSection();
      case 'icon':
        return const _AppIconSection();
    }
    return const SizedBox.shrink();
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const _Card({required this.child, this.padding = const EdgeInsets.all(18)});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: padding,
      decoration: BoxDecoration(
        color: EditorColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EditorColors.border),
      ),
      child: child,
    );
  }
}

class _AppStateSection extends StatelessWidget {
  const _AppStateSection();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    return _Card(
      child: FieldListEditor(
        fields: provider.logic.appState,
        namePrefix: 'value',
        addLabel: 'Add app state variable',
        showPersisted: true,
        emptyMessage: 'No app state yet. Add e.g. cartCount (int) or isDarkMode (bool).',
        onChanged: (fields) => provider.updateLogic((l) => l.appState = fields),
      ),
    );
  }
}

class _DataTypesSection extends StatelessWidget {
  const _DataTypesSection();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final types = provider.logic.dataTypes;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < types.length; i++)
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Expanded(
                    child: EditorTextInput(
                      value: types[i].name,
                      hint: 'TypeName',
                      onChanged: (v) => provider.updateLogic((l) => l.dataTypes[i].name = v.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')),
                    ),
                  ),
                  EditorIconButton(icon: Icons.delete_outline_rounded, tooltip: 'Delete type', onPressed: () => provider.updateLogic((l) => l.dataTypes.removeAt(i))),
                ]),
                const SizedBox(height: 12),
                FieldListEditor(
                  fields: types[i].fields,
                  addLabel: 'Add field',
                  onChanged: (fields) => provider.updateLogic((l) => l.dataTypes[i].fields = fields),
                ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New data type'),
            onPressed: () => provider.updateLogic((l) => l.dataTypes.add(CustomDataType(name: 'Item${l.dataTypes.length + 1}', fields: [FieldDef(name: 'name')]))),
          ),
        ),
      ],
    );
  }
}

class _EnumsSection extends StatelessWidget {
  const _EnumsSection();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final enums = provider.logic.enums;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < enums.length; i++)
          _Card(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 200,
                  child: EditorField(
                    label: 'Name',
                    child: EditorTextInput(value: enums[i].name, onChanged: (v) => provider.updateLogic((l) => l.enums[i].name = v.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ''))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: EditorField(
                    label: 'Values (comma separated)',
                    child: EditorTextInput(
                      value: enums[i].values.join(', '),
                      onChanged: (v) => provider.updateLogic((l) => l.enums[i].values = v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()),
                    ),
                  ),
                ),
                EditorIconButton(icon: Icons.delete_outline_rounded, tooltip: 'Delete enum', onPressed: () => provider.updateLogic((l) => l.enums.removeAt(i))),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New enum'),
            onPressed: () => provider.updateLogic((l) => l.enums.add(CustomEnum(name: 'Status${l.enums.length + 1}', values: ['active', 'archived']))),
          ),
        ),
      ],
    );
  }
}

class _ApiCallsSection extends StatefulWidget {
  const _ApiCallsSection();

  @override
  State<_ApiCallsSection> createState() => _ApiCallsSectionState();
}

class _ApiCallsSectionState extends State<_ApiCallsSection> {
  String? _selectedId;
  ApiCallResult? _result;
  bool _running = false;
  final Map<String, String> _testValues = {};

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final calls = provider.logic.apiCalls;
    final selectedIndex = calls.indexWhere((c) => c.id == _selectedId);
    final call = selectedIndex == -1 ? (calls.isEmpty ? null : calls.first) : calls[selectedIndex];
    final index = call == null ? -1 : calls.indexOf(call);

    void update(void Function(ApiCallDef c) change) => provider.updateLogic((l) => change(l.apiCalls[index]));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final c in calls)
                EditorListTile(
                  icon: Icons.api_rounded,
                  title: c.name,
                  subtitle: '${c.method} ${c.url.replaceFirst(RegExp(r'^https?://'), '')}',
                  selected: c.id == call?.id,
                  onTap: () => setState(() {
                    _selectedId = c.id;
                    _result = null;
                  }),
                ),
              const SizedBox(height: 6),
              OutlinedButton.icon(
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('New API call'),
                onPressed: () {
                  final id = DateTime.now().microsecondsSinceEpoch.toString();
                  provider.updateLogic((l) => l.apiCalls.add(ApiCallDef(
                        id: id,
                        name: 'Get Posts ${l.apiCalls.length + 1}',
                        url: 'https://jsonplaceholder.typicode.com/posts',
                        responseFields: [ApiResponseField(name: 'titles', jsonPath: r'$[*].title', isList: true)],
                      )));
                  setState(() => _selectedId = id);
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: call == null
              ? const _Card(child: EditorEmptyState(icon: Icons.api_rounded, title: 'No API calls', message: 'Create one to fetch or send data to any REST backend.'))
              : _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: [
                        Expanded(child: EditorField(label: 'Name', child: EditorTextInput(value: call.name, onChanged: (v) => update((c) => c.name = v)))),
                        EditorIconButton(
                          icon: Icons.delete_outline_rounded,
                          tooltip: 'Delete API call',
                          onPressed: () {
                            provider.updateLogic((l) => l.apiCalls.removeAt(index));
                            setState(() => _selectedId = null);
                          },
                        ),
                      ]),
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        SizedBox(
                          width: 120,
                          child: EditorField(
                            label: 'Method',
                            child: EditorDropdown<String>(
                              value: call.method,
                              items: const ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
                              label: (m) => m,
                              onChanged: (m) => update((c) => c.method = m ?? 'GET'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: EditorField(
                            label: 'URL',
                            help: 'Use [name] for variables, e.g. https://api.example.com/users/[userId]',
                            child: EditorTextInput(value: call.url, monospace: true, onChanged: (v) => update((c) => c.url = v)),
                          ),
                        ),
                      ]),
                      const EditorLabel('Headers'),
                      _KeyValueEditor(
                        values: call.headers,
                        keyHint: 'Header',
                        valueHint: 'Value or [variable]',
                        onChanged: (h) => update((c) => c.headers = h),
                      ),
                      const SizedBox(height: 10),
                      EditorField(
                        label: 'Body',
                        child: Wrap(spacing: 6, children: [
                          for (final t in const ['none', 'json', 'form'])
                            EditorPill(label: t.toUpperCase(), selected: call.bodyType == t, onTap: () => update((c) => c.bodyType = t)),
                        ]),
                      ),
                      if (call.bodyType != 'none')
                        EditorTextInput(value: call.body, monospace: true, maxLines: 6, hint: '{"title": "[title]"}', onChanged: (v) => update((c) => c.body = v)),
                      const SizedBox(height: 14),
                      const EditorLabel('Variables'),
                      FieldListEditor(
                        fields: call.variables,
                        namePrefix: 'variable',
                        addLabel: 'Add variable',
                        allowCustomTypes: false,
                        emptyMessage: 'No variables. Add one and reference it as [name].',
                        onChanged: (v) => update((c) => c.variables = v),
                      ),
                      const SizedBox(height: 6),
                      const EditorLabel('Response fields'),
                      for (var i = 0; i < call.responseFields.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(children: [
                            Expanded(child: EditorTextInput(value: call.responseFields[i].name, hint: 'name', onChanged: (v) => update((c) => c.responseFields[i].name = v))),
                            const SizedBox(width: 6),
                            Expanded(
                              flex: 2,
                              child: EditorTextInput(value: call.responseFields[i].jsonPath, monospace: true, hint: r'$.data.items', onChanged: (v) => update((c) => c.responseFields[i].jsonPath = v)),
                            ),
                            if (_result != null)
                              SizedBox(
                                width: 140,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(
                                    _preview(JsonPath.read(_result!.body, call.responseFields[i].jsonPath)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 11.5, color: EditorColors.success, fontFamily: 'monospace'),
                                  ),
                                ),
                              ),
                            EditorIconButton(icon: Icons.close_rounded, tooltip: 'Remove', size: 15, onPressed: () => update((c) => c.responseFields.removeAt(i))),
                          ]),
                        ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () => update((c) => c.responseFields.add(ApiResponseField(name: 'field${c.responseFields.length + 1}', jsonPath: r'$'))),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Add response field'),
                        ),
                      ),
                      const Divider(height: 32),
                      Row(children: [
                        const Text('Test', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: _running
                              ? null
                              : () async {
                                  setState(() => _running = true);
                                  final vars = {for (final v in call.variables) v.name: _testValues[v.name] ?? v.defaultValue};
                                  final result = await ApiCallRunner.run(call, vars);
                                  if (mounted) {
                                    setState(() {
                                      _result = result;
                                      _running = false;
                                    });
                                  }
                                },
                          icon: _running
                              ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.play_arrow_rounded, size: 18),
                          label: const Text('Run'),
                        ),
                      ]),
                      for (final v in call.variables)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: EditorField(
                            label: 'Test value for ${v.name}',
                            child: EditorTextInput(value: _testValues[v.name] ?? '${v.defaultValue ?? ''}', onChanged: (t) => _testValues[v.name] = t),
                          ),
                        ),
                      if (_result != null) ...[
                        const SizedBox(height: 10),
                        Row(children: [
                          _StatusChip(result: _result!),
                          const SizedBox(width: 8),
                          Text('${_result!.elapsed.inMilliseconds} ms', style: const TextStyle(fontSize: 12, color: EditorColors.textFaint)),
                        ]),
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 320),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: EditorColors.background, borderRadius: BorderRadius.circular(8), border: Border.all(color: EditorColors.border)),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              _result!.error ?? _pretty(_result!.body),
                              style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: EditorColors.text, height: 1.4),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  String _pretty(dynamic body) {
    try {
      final text = const JsonEncoder.withIndent('  ').convert(body);
      return text.length > 20000 ? '${text.substring(0, 20000)}\n…' : text;
    } catch (_) {
      return '$body';
    }
  }

  String _preview(dynamic value) {
    if (value == null) return 'null';
    final text = value is String ? value : jsonEncode(value);
    return text.length > 60 ? '${text.substring(0, 60)}…' : text;
  }
}

class _StatusChip extends StatelessWidget {
  final ApiCallResult result;

  const _StatusChip({required this.result});

  @override
  Widget build(BuildContext context) {
    final ok = result.succeeded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (ok ? EditorColors.success : EditorColors.danger).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        result.error != null ? 'Error' : '${result.statusCode}',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: ok ? EditorColors.success : EditorColors.danger),
      ),
    );
  }
}

class _KeyValueEditor extends StatelessWidget {
  final Map<String, String> values;
  final ValueChanged<Map<String, String>> onChanged;
  final String keyHint;
  final String valueHint;

  const _KeyValueEditor({required this.values, required this.onChanged, this.keyHint = 'Key', this.valueHint = 'Value'});

  @override
  Widget build(BuildContext context) {
    final entries = values.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < entries.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(children: [
              Expanded(
                child: EditorTextInput(
                  value: entries[i].key,
                  hint: keyHint,
                  onChanged: (k) {
                    final next = <String, String>{};
                    for (var j = 0; j < entries.length; j++) {
                      next[j == i ? k : entries[j].key] = entries[j].value;
                    }
                    onChanged(next);
                  },
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                flex: 2,
                child: EditorTextInput(value: entries[i].value, hint: valueHint, onChanged: (v) => onChanged({...values, entries[i].key: v})),
              ),
              EditorIconButton(icon: Icons.close_rounded, tooltip: 'Remove', size: 15, onPressed: () => onChanged(Map.of(values)..remove(entries[i].key))),
            ]),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => onChanged({...values, '${keyHint.replaceAll(' ', '-')}-${values.length + 1}': ''}),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: Text('Add ${keyHint.toLowerCase()}'),
          ),
        ),
      ],
    );
  }
}

class _AuthSection extends StatelessWidget {
  const _AuthSection();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final logic = provider.logic;
    final pages = provider.screens;
    String pageName(String id) => '${pages.firstWhere((s) => s.id == id).properties['pageName'] ?? 'Page'}';
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EditorField(
            label: 'Provider',
            child: Wrap(spacing: 6, children: [
              EditorPill(label: 'None', selected: logic.authProvider == 'none', onTap: () => provider.updateLogic((l) => l.authProvider = 'none')),
              EditorPill(label: 'Supabase Auth', icon: Icons.bolt_rounded, selected: logic.authProvider == 'supabase', onTap: () => provider.updateLogic((l) => l.authProvider = 'supabase')),
            ]),
          ),
          if (logic.usesAuth) ...[
            if (provider.activeConnection == null)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text('Connect a Supabase project (Data tab) so the exported app can sign users in.', style: TextStyle(color: EditorColors.warning, fontSize: 12.5)),
              ),
            EditorField(
              label: 'Sign-in page',
              help: 'Shown when nobody is signed in.',
              child: EditorDropdown<String>(
                value: logic.loginPageId,
                items: pages.map((p) => p.id).toList(),
                hint: 'Choose a page',
                label: pageName,
                onChanged: (id) => provider.updateLogic((l) => l.loginPageId = id),
              ),
            ),
            EditorField(
              label: 'Home page (after sign-in)',
              child: EditorDropdown<String>(
                value: logic.homePageId,
                items: pages.map((p) => p.id).toList(),
                hint: 'First page',
                label: pageName,
                onChanged: (id) => provider.updateLogic((l) => l.homePageId = id),
              ),
            ),
            const Text(
              'Use the Sign In, Create Account, Reset Password and Sign Out actions, and bind widgets to “Authenticated user”.',
              style: TextStyle(fontSize: 12.5, color: EditorColors.textMuted, height: 1.45),
            ),
          ],
        ],
      ),
    );
  }
}

class _EnvSection extends StatelessWidget {
  const _EnvSection();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final logic = provider.logic;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EditorField(
                label: 'Environments (comma separated)',
                child: EditorTextInput(
                  value: logic.environments.join(', '),
                  onChanged: (v) => provider.updateLogic((l) => l.environments = v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()),
                ),
              ),
              EditorField(
                label: 'Active in the editor and default for builds',
                child: Wrap(spacing: 6, children: [
                  for (final env in logic.environments)
                    EditorPill(label: env, selected: logic.activeEnvironment == env, onTap: () => provider.updateLogic((l) => l.activeEnvironment = env)),
                ]),
              ),
            ],
          ),
        ),
        for (var i = 0; i < logic.envValues.length; i++)
          _Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(children: [
                  Expanded(child: EditorTextInput(value: logic.envValues[i].name, hint: 'name', onChanged: (v) => provider.updateLogic((l) => l.envValues[i].name = v))),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 140,
                    child: EditorDropdown<String>(
                      value: logic.envValues[i].type,
                      items: const [VarTypes.string, VarTypes.integer, VarTypes.decimal, VarTypes.boolean],
                      label: (t) => t,
                      onChanged: (t) => provider.updateLogic((l) => l.envValues[i].type = t ?? VarTypes.string),
                    ),
                  ),
                  EditorIconButton(icon: Icons.delete_outline_rounded, tooltip: 'Delete', onPressed: () => provider.updateLogic((l) => l.envValues.removeAt(i))),
                ]),
                const SizedBox(height: 10),
                for (final env in logic.environments)
                  EditorField(
                    label: env,
                    child: EditorTextInput(value: logic.envValues[i].values[env] ?? '', onChanged: (v) => provider.updateLogic((l) => l.envValues[i].values[env] = v)),
                  ),
              ],
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('New environment value'),
            onPressed: () => provider.updateLogic((l) => l.envValues.add(EnvValue(name: 'apiBaseUrl', values: {for (final e in l.environments) e: ''}))),
          ),
        ),
      ],
    );
  }
}

class _CustomCodeSection extends StatefulWidget {
  const _CustomCodeSection();

  @override
  State<_CustomCodeSection> createState() => _CustomCodeSectionState();
}

class _CustomCodeSectionState extends State<_CustomCodeSection> {
  String? _selectedId;

  static const _templates = {
    'function': r"return '\$${amount.toStringAsFixed(2)}';",
    'action': "ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hello from custom code')));",
    'widget': 'return Container(\n  width: widget.width,\n  height: widget.height,\n  alignment: Alignment.center,\n  child: const Text(\'Custom widget\'),\n);',
  };

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final items = provider.logic.customCode;
    final selected = items.where((c) => c.id == _selectedId).firstOrNull ?? (items.isEmpty ? null : items.first);
    final index = selected == null ? -1 : items.indexOf(selected);
    void update(void Function(CustomCodeDef c) change) => provider.updateLogic((l) => change(l.customCode[index]));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 220,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final c in items)
                EditorListTile(
                  icon: c.kind == 'widget' ? Icons.widgets_outlined : c.kind == 'action' ? Icons.bolt_rounded : Icons.functions_rounded,
                  title: c.name,
                  subtitle: c.kind[0].toUpperCase() + c.kind.substring(1),
                  selected: c.id == selected?.id,
                  onTap: () => setState(() => _selectedId = c.id),
                ),
              const SizedBox(height: 6),
              for (final kind in const ['function', 'action', 'widget'])
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text('New $kind'),
                    onPressed: () {
                      final id = DateTime.now().microsecondsSinceEpoch.toString();
                      provider.updateLogic((l) => l.customCode.add(CustomCodeDef(
                            id: id,
                            kind: kind,
                            name: kind == 'widget' ? 'MyWidget${l.customCode.length + 1}' : '${kind == 'function' ? 'formatPrice' : 'myAction'}${l.customCode.length + 1}',
                            args: kind == 'function' ? [FieldDef(name: 'amount', type: VarTypes.decimal)] : [],
                            returnType: kind == 'function' ? VarTypes.string : 'void',
                            code: _templates[kind]!,
                          )));
                      setState(() => _selectedId = id);
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: selected == null
              ? const _Card(child: EditorEmptyState(icon: Icons.code_rounded, title: 'No custom code', message: 'Add a function, action or widget written in Dart.'))
              : _Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(children: [
                        Expanded(
                          child: EditorField(
                            label: 'Name',
                            child: EditorTextInput(value: selected.name, onChanged: (v) => update((c) => c.name = v.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), ''))),
                          ),
                        ),
                        if (selected.kind != 'widget') ...[
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 150,
                            child: EditorField(
                              label: 'Returns',
                              child: EditorDropdown<String>(
                                value: selected.returnType,
                                items: ['void', ...VarTypes.primitives, ...provider.logic.dataTypes.map((t) => 'DataType:${t.name}')],
                                label: (t) => VarTypes.label(t),
                                onChanged: (t) => update((c) => c.returnType = t ?? 'void'),
                              ),
                            ),
                          ),
                        ],
                        EditorIconButton(
                          icon: Icons.delete_outline_rounded,
                          tooltip: 'Delete',
                          onPressed: () {
                            provider.updateLogic((l) => l.customCode.removeAt(index));
                            setState(() => _selectedId = null);
                          },
                        ),
                      ]),
                      const EditorLabel('Arguments'),
                      FieldListEditor(
                        fields: selected.args,
                        namePrefix: 'arg',
                        addLabel: 'Add argument',
                        showRequired: selected.kind == 'widget',
                        showDefault: false,
                        emptyMessage: 'No arguments.',
                        onChanged: (args) => update((c) => c.args = args),
                      ),
                      const SizedBox(height: 8),
                      EditorLabel(_signature(selected)),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF070B16),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: EditorColors.border),
                        ),
                        child: EditorTextInput(
                          key: ValueKey(selected.id),
                          value: selected.code,
                          monospace: true,
                          maxLines: 16,
                          onChanged: (v) => update((c) => c.code = v),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        selected.kind == 'widget'
                            ? 'Write the body of build(). Arguments are available as widget.<name>; size as widget.width / widget.height. Add it from the Custom Code palette or as a CustomWidget node.'
                            : selected.kind == 'action'
                                ? 'Write the body of an async function. `context` and your arguments are in scope. Call it with the "Custom Action" action.'
                                : 'Write the body of a pure function and return a value. Use it from any value picker via “Custom function”.',
                        style: const TextStyle(fontSize: 12, color: EditorColors.textMuted, height: 1.45),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  String _signature(CustomCodeDef c) {
    final args = c.args.map((a) => '${VarTypes.label(a.type, isList: a.isList)} ${a.name}').join(', ');
    if (c.kind == 'widget') return 'Widget build(BuildContext context)';
    if (c.kind == 'action') return 'Future<${VarTypes.label(c.returnType)}> ${c.name}(BuildContext context${args.isEmpty ? '' : ', $args'})';
    return '${VarTypes.label(c.returnType)} ${c.name}($args)';
  }
}

class _PackagesSection extends StatelessWidget {
  const _PackagesSection();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final deps = provider.logic.dependencies;
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < deps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Expanded(flex: 3, child: EditorTextInput(value: deps[i].name, hint: 'package_name', monospace: true, onChanged: (v) => provider.updateLogic((l) => l.dependencies[i].name = v.trim()))),
                const SizedBox(width: 8),
                Expanded(flex: 2, child: EditorTextInput(value: deps[i].version, hint: '^1.0.0', monospace: true, onChanged: (v) => provider.updateLogic((l) => l.dependencies[i].version = v.trim()))),
                EditorIconButton(icon: Icons.close_rounded, tooltip: 'Remove', onPressed: () => provider.updateLogic((l) => l.dependencies.removeAt(i))),
              ]),
            ),
          if (deps.isEmpty) const Text('No extra packages.', style: TextStyle(fontSize: 12.5, color: EditorColors.textFaint)),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () => provider.updateLogic((l) => l.dependencies.add(PackageDep(name: 'intl', version: '^0.20.2'))),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add package'),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguagesSection extends StatelessWidget {
  const _LanguagesSection();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final logic = provider.logic;
    final keys = logic.translations.keys.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              EditorField(
                label: 'Languages (codes, comma separated — first is the default)',
                child: EditorTextInput(
                  value: logic.languages.join(', '),
                  onChanged: (v) => provider.updateLogic((l) => l.languages = v.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()),
                ),
              ),
              Row(children: [
                const Expanded(child: Text('Right-to-left layout (Arabic, Hebrew, …)', style: TextStyle(fontSize: 13))),
                Switch(value: logic.rtl, onChanged: (v) => provider.updateLogic((l) => l.rtl = v)),
              ]),
              Row(children: [
                const Expanded(child: Text('Preview language on the canvas', style: TextStyle(fontSize: 13))),
                Wrap(spacing: 6, children: [
                  for (final lang in logic.languages)
                    EditorPill(label: lang, selected: (provider.previewLanguage ?? logic.languages.first) == lang, onTap: () => provider.setPreviewLanguage(lang)),
                ]),
              ]),
            ],
          ),
        ),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(children: [
                const SizedBox(width: 170, child: Text('Key', style: TextStyle(fontSize: 12, color: EditorColors.textFaint))),
                for (final lang in logic.languages)
                  Expanded(child: Text(lang, style: const TextStyle(fontSize: 12, color: EditorColors.textFaint))),
                const SizedBox(width: 34),
              ]),
              const SizedBox(height: 8),
              for (final key in keys)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(children: [
                    SizedBox(
                      width: 170,
                      child: Text(key, style: const TextStyle(fontSize: 13, fontFamily: 'monospace')),
                    ),
                    for (final lang in logic.languages)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: EditorTextInput(
                            value: logic.translations[key]?[lang] ?? '',
                            onChanged: (v) => provider.updateLogic((l) => l.translations.putIfAbsent(key, () => {})[lang] = v),
                          ),
                        ),
                      ),
                    EditorIconButton(icon: Icons.close_rounded, tooltip: 'Remove', size: 15, onPressed: () => provider.updateLogic((l) => l.translations.remove(key))),
                  ]),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => provider.updateLogic((l) => l.translations['text${l.translations.length + 1}'] = {for (final lang in l.languages) lang: ''}),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add text'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppIconSection extends StatelessWidget {
  const _AppIconSection();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final logic = provider.logic;
    final url = logic.appIconUrl ?? '';
    return _Card(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              color: EditorColors.background,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: EditorColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: url.isEmpty
                ? const Icon(Icons.image_outlined, color: EditorColors.textFaint, size: 36)
                : Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image_outlined, color: EditorColors.textFaint)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EditorField(
                  label: 'Icon image URL (1024×1024 PNG)',
                  help: 'The export adds flutter_launcher_icons and flutter_native_splash config; the README explains the two commands to run.',
                  child: EditorTextInput(value: url, hint: 'https://…/icon.png', onChanged: (v) => provider.updateLogic((l) => l.appIconUrl = v.trim().isEmpty ? null : v.trim())),
                ),
                EditorField(
                  label: 'Splash background color',
                  child: EditorTextInput(value: logic.splashColor ?? '#FFFFFF', onChanged: (v) => provider.updateLogic((l) => l.splashColor = v.trim())),
                ),
                EditorField(
                  label: 'Theme mode of the exported app',
                  child: Wrap(spacing: 6, children: [
                    for (final mode in const ['light', 'dark', 'system'])
                      EditorPill(label: mode, selected: logic.themeMode == mode, onTap: () => provider.updateLogic((l) => l.themeMode = mode)),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
