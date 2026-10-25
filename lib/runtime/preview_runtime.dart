import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../logic/json_path.dart';
import '../logic/logic_values.dart';
import '../models/project_logic.dart';
import '../models/widget_node.dart';
import '../providers/widget_tree_provider.dart';
import '../services/api_service.dart';
import '../utils/color_utils.dart';
import '../widgets/canvas_preview/builders/supabase_query_wrapper_builder.dart';
import '../widgets/canvas_preview/builders/component_instance_builder.dart';

/// Runs project logic inside the editor canvas (test mode): resolves values
/// and conditions against preview state and executes action lists.
///
/// The exported app gets the equivalent Dart from `logic_codegen.dart`; keep
/// both in step when adding an action type.
class PreviewRuntime {
  static WidgetTreeProvider _provider(BuildContext context) => Provider.of<WidgetTreeProvider>(context, listen: false);

  /// Default value for a variable before anything updates it.
  static dynamic defaultFor(FieldDef field) {
    if (field.defaultValue != null) {
      final raw = field.defaultValue;
      switch (field.type) {
        case VarTypes.integer:
          return raw is num ? raw.toInt() : int.tryParse(raw.toString()) ?? 0;
        case VarTypes.decimal:
          return raw is num ? raw.toDouble() : double.tryParse(raw.toString()) ?? 0.0;
        case VarTypes.boolean:
          return raw == true || raw.toString() == 'true';
      }
      return raw;
    }
    if (field.isList) return <dynamic>[];
    switch (field.type) {
      case VarTypes.integer:
        return 0;
      case VarTypes.decimal:
        return 0.0;
      case VarTypes.boolean:
        return false;
      case VarTypes.string:
        return '';
    }
    return null;
  }

  static Map<String, dynamic> _pageState(WidgetTreeProvider provider) {
    final screen = provider.selectedScreen;
    if (screen == null) return {};
    final state = provider.previewPageState.putIfAbsent(screen.id, () => {});
    for (final field in PageLogic.pageState(screen.properties)) {
      state.putIfAbsent(field.name, () => defaultFor(field));
    }
    return state;
  }

  static dynamic _appStateValue(WidgetTreeProvider provider, String? name) {
    if (name == null) return null;
    if (!provider.previewAppState.containsKey(name)) {
      final field = provider.logic.appStateVar(name);
      if (field != null) provider.previewAppState[name] = defaultFor(field);
    }
    return provider.previewAppState[name];
  }

  static dynamic resolve(BuildContext context, dynamic value) {
    if (!LogicValues.isValue(value)) return value;
    final provider = _provider(context);
    final v = value as Map;
    switch (v['source']) {
      case 'literal':
        return v['value'];
      case 'appState':
        return _appStateValue(provider, v['name'] as String?);
      case 'pageState':
        return _pageState(provider)[v['name']];
      case 'pageParam':
        final scope = ComponentScope.maybeOf(context);
        if (scope != null && scope.args.containsKey(v['name'])) return scope.args[v['name']];
        final screen = provider.selectedScreen;
        final params = screen == null ? null : provider.previewPageParams[screen.id];
        if (params != null && params.containsKey(v['name'])) return params[v['name']];
        final def = screen == null ? null : PageLogic.pageParams(screen.properties).where((p) => p.name == v['name']).firstOrNull;
        return def == null ? null : defaultFor(def);
      case 'widgetState':
        return provider.getWidgetState(v['widgetId']?.toString() ?? '');
      case 'queryField':
        final row = SupabaseRowDataContext.of(context) ?? provider.activeRowData;
        return row?[v['field']];
      case 'actionOutput':
        final out = provider.previewOutputs[v['name']];
        final path = v['path'] as String?;
        return path == null || path.isEmpty ? out : JsonPath.read(out, path);
      case 'env':
        final env = provider.logic.envValues.where((e) => e.name == v['name']).firstOrNull;
        return env?.values[provider.logic.activeEnvironment];
      case 'authUser':
        final user = provider.previewAppState['__authUser'] as Map?;
        if (v['field'] == 'isLoggedIn') return user != null;
        return user?[v['field'] ?? 'email'];
      case 'function':
        return '${v['name']}(…)';
      case 'translation':
        final language = provider.previewLanguage ?? provider.logic.languages.first;
        return provider.logic.translations[v['key']]?[language] ?? v['key'];
      case 'screenWidth':
        return MediaQuery.maybeSizeOf(context)?.width ?? 0;
    }
    return null;
  }

  static bool evaluate(BuildContext context, dynamic cond) {
    if (cond is! Map) return true;
    if (cond['conditions'] is List) {
      final results = (cond['conditions'] as List).map((c) => evaluate(context, c));
      return cond['combine'] == 'or' ? results.any((r) => r) : results.every((r) => r);
    }
    final left = resolve(context, cond['left']);
    final right = resolve(context, cond['right']);
    switch (cond['op'] as String? ?? '==') {
      case '==':
        return _loose(left) == _loose(right);
      case '!=':
        return _loose(left) != _loose(right);
      case '>':
        return _num(left) > _num(right);
      case '>=':
        return _num(left) >= _num(right);
      case '<':
        return _num(left) < _num(right);
      case '<=':
        return _num(left) <= _num(right);
      case 'contains':
        if (left is List) return left.map(_loose).contains(_loose(right));
        return left?.toString().contains(right?.toString() ?? '') ?? false;
      case 'isEmpty':
        return left == null || (left is String && left.isEmpty) || (left is List && left.isEmpty);
      case 'isNotEmpty':
        return !(left == null || (left is String && left.isEmpty) || (left is List && left.isEmpty));
      case 'isTrue':
        return left == true || left?.toString() == 'true';
      case 'isFalse':
        return !(left == true || left?.toString() == 'true');
    }
    return false;
  }

  /// Same semantics as `looseEquals` in the exported runtime: numbers and
  /// numeric strings compare by value.
  static dynamic _loose(dynamic v) {
    if (v is num) return v.toDouble();
    final parsed = num.tryParse('${v ?? ''}');
    return parsed != null ? parsed.toDouble() : (v?.toString() ?? '');
  }
  static double _num(dynamic v) => v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0;

  static dynamic _applyOp(dynamic current, String op, dynamic value, FieldDef? field) {
    switch (op) {
      case 'increment':
        return (current is num ? current : 0) + (value is num ? value : num.tryParse(value?.toString() ?? '') ?? 1);
      case 'decrement':
        return (current is num ? current : 0) - (value is num ? value : num.tryParse(value?.toString() ?? '') ?? 1);
      case 'toggle':
        return !(current == true);
      case 'clear':
        return field == null ? null : (field.isList ? <dynamic>[] : defaultFor(FieldDef(name: field.name, type: field.type)));
      case 'add':
        return [...(current is List ? current : const []), value];
      case 'remove':
        return [...(current is List ? current : const [])]..remove(value);
      default:
        if (field?.type == VarTypes.integer && value is! int) return int.tryParse(value?.toString() ?? '') ?? value;
        if (field?.type == VarTypes.decimal && value is! double) return double.tryParse(value?.toString() ?? '') ?? value;
        return value;
    }
  }

  /// Runs [actions] in order. Returns false when a "Stop Actions" ran.
  static Future<bool> run(BuildContext context, List? actions) async {
    if (actions == null) return true;
    final provider = _provider(context);
    for (final raw in actions) {
      if (raw is! Map) continue;
      final action = Map<String, dynamic>.from(raw);
      if (!context.mounted) return false;
      final keepGoing = await _runOne(context, provider, action);
      provider.previewChanged();
      if (!keepGoing) return false;
    }
    return true;
  }

  static Future<bool> _runOne(BuildContext context, WidgetTreeProvider provider, Map<String, dynamic> action) async {
    final type = action['type'] as String?;
    provider.logPreview(ActionCatalog.label(action));
    switch (type) {
      case 'navigate':
        final target = provider.screens.where((s) => s.id == action['targetScreenId']).firstOrNull;
        if (action['targetScreenId'] == '__back__') return _back(provider);
        if (target == null) return true;
        final params = <String, dynamic>{};
        (action['params'] as Map? ?? {}).forEach((k, v) => params[k.toString()] = resolve(context, v));
        provider.previewPageParams[target.id] = params;
        provider.previewPageState.remove(target.id);
        if (action['replace'] != 'yes' && provider.selectedScreen != null) provider.previewHistory.add(provider.selectedScreen!);
        provider.selectScreen(target);
        await run(context, PageLogic.onPageLoad(target.properties));
        return true;
      case 'navigateBack':
        return _back(provider);
      case 'openDrawer':
        Scaffold.maybeOf(context)?.openDrawer();
        return true;
      case 'updateAppState':
        final name = action['name'] as String?;
        if (name == null) return true;
        final field = provider.logic.appStateVar(name);
        provider.previewAppState[name] = _applyOp(_appStateValue(provider, name), action['op'] as String? ?? 'set', resolve(context, action['value']), field);
        return true;
      case 'updatePageState':
        final name = action['name'] as String?;
        if (name == null) return true;
        final state = _pageState(provider);
        final field = PageLogic.pageState(provider.selectedScreen?.properties ?? {}).where((f) => f.name == name).firstOrNull;
        state[name] = _applyOp(state[name], action['op'] as String? ?? 'set', resolve(context, action['value']), field);
        return true;
      case 'showSnackbar':
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
          content: Text('${resolve(context, action['message']) ?? ''}'),
          duration: Duration(milliseconds: (action['durationMs'] as num?)?.toInt() ?? 3000),
        ));
        return true;
      case 'showDialog':
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('${resolve(context, action['title']) ?? ''}'),
            content: Text('${resolve(context, action['message']) ?? ''}'),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(action['confirmText'] as String? ?? 'OK'))],
          ),
        );
        return true;
      case 'confirmDialog':
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('${resolve(context, action['title']) ?? ''}'),
            content: Text('${resolve(context, action['message']) ?? ''}'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Confirm')),
            ],
          ),
        );
        if (!context.mounted) return false;
        return run(context, (confirmed ?? false) ? action['then'] as List? : action['else'] as List?);
      case 'showBottomSheet':
        await showModalBottomSheet<void>(
          context: context,
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(24),
            child: Text('${resolve(context, action['message']) ?? ''}'),
          ),
        );
        return true;
      case 'haptic':
        return true;
      case 'conditional':
        final branch = evaluate(context, action['condition']) ? action['then'] : action['else'];
        return run(context, branch as List?);
      case 'wait':
        await Future<void>.delayed(Duration(milliseconds: (action['ms'] as num?)?.toInt() ?? 500));
        return true;
      case 'terminate':
        return false;
      case 'launchUrl':
        _toast(context, 'Opens ${resolve(context, action['url'])}');
        return true;
      case 'copyToClipboard':
        await Clipboard.setData(ClipboardData(text: '${resolve(context, action['text']) ?? ''}'));
        if (context.mounted) _toast(context, 'Copied to clipboard');
        return true;
      case 'share':
        _toast(context, 'Share sheet: ${resolve(context, action['text'])}');
        return true;
      case 'toggleThemeMode':
        provider.setPreviewDarkMode(!provider.previewDarkMode);
        return true;
      case 'setLanguage':
        provider.setPreviewLanguage(action['language'] as String?);
        return true;
      case 'apiCall':
        final call = provider.logic.apiCallById(action['apiCallId'] as String?);
        if (call == null) return true;
        final variables = <String, dynamic>{};
        for (final variable in call.variables) {
          variables[variable.name] = resolve(context, (action['variables'] as Map?)?[variable.name]) ?? variable.defaultValue;
        }
        final result = await ApiCallRunner.run(call, variables);
        final outputName = (action['outputName'] as String?)?.trim();
        provider.previewOutputs[outputName == null || outputName.isEmpty ? call.name : outputName] = result.body;
        provider.logPreview('${call.name} → ${result.statusCode}${result.error != null ? ' (${result.error})' : ''}');
        if (!context.mounted) return false;
        return run(context, (result.succeeded ? action['then'] : action['else']) as List?);
      case 'authSignIn':
      case 'authSignUp':
        final email = '${resolve(context, action['email']) ?? ''}';
        final ok = email.contains('@') && '${resolve(context, action['password']) ?? ''}'.length >= 6;
        if (ok) provider.previewAppState['__authUser'] = {'email': email, 'id': 'preview-user'};
        provider.logPreview(ok ? 'Signed in as $email (simulated)' : 'Sign-in failed (simulated: needs an email and a 6+ character password)');
        return run(context, (ok ? action['then'] : action['else']) as List?);
      case 'authSignOut':
        provider.previewAppState.remove('__authUser');
        return true;
      case 'authResetPassword':
        _toast(context, 'Password reset e-mail sent (simulated)');
        return true;
      case 'callParameterAction':
        final scope = ComponentScope.maybeOf(context);
        final callback = scope?.callbacks[action['name']];
        if (scope == null || callback == null) return true;
        return run(scope.parentContext, callback);
      case 'supabase_insert':
      case 'supabase_update':
      case 'supabase_delete':
      case 'supabase_rpc':
      case 'uploadFile':
      case 'customAction':
        provider.logPreview('${ActionCatalog.label(action)} runs in the exported app only');
        return true;
    }
    return true;
  }

  static bool _back(WidgetTreeProvider provider) {
    if (provider.previewHistory.isNotEmpty) {
      provider.selectScreen(provider.previewHistory.removeLast());
    }
    return true;
  }

  static void _toast(BuildContext context, String message) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2)));
  }

  /// Applies `properties['bindings']` (property -> value) on top of [node]'s
  /// literal properties.
  static Map<String, dynamic> applyBindings(BuildContext context, WidgetNode node, Map<String, dynamic> props) {
    final bindings = props['bindings'];
    if (bindings is! Map || bindings.isEmpty) return props;
    final resolved = Map<String, dynamic>.from(props);
    bindings.forEach((key, value) {
      final v = resolve(context, value);
      if (v == null) return;
      if (key.toString().toLowerCase().contains('color')) {
        resolved[key.toString()] = v is Color ? v.toARGB32() : v;
      } else if (v is List) {
        resolved[key.toString()] = v.join(', ');
      } else {
        resolved[key.toString()] = v is num || v is bool ? v : v.toString();
      }
    });
    return resolved;
  }

  /// Whether [node] is visible under its `visibility` rule at the current
  /// canvas width.
  static bool isVisible(BuildContext context, WidgetNode node) {
    final rule = node.properties['visibility'];
    if (rule is! Map) return true;
    final hideOn = (rule['hideOn'] as List?)?.cast<String>() ?? const [];
    if (hideOn.isNotEmpty) {
      final width = MediaQuery.maybeSizeOf(context)?.width ?? 400;
      final breakpoint = width < 600 ? 'phone' : width < 1024 ? 'tablet' : 'desktop';
      if (hideOn.contains(breakpoint)) return false;
    }
    if (rule['condition'] != null) return evaluate(context, rule['condition']);
    return true;
  }

  static Color? colorOf(dynamic value, Map<String, dynamic> theme) =>
      value == null ? null : ColorUtils.parseColor(value, theme, Colors.transparent);
}
