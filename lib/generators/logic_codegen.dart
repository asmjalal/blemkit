import '../logic/logic_values.dart';
import '../models/project_logic.dart';
import 'base_widget_generator.dart';
import 'project_generator.dart';
import 'theme_generator.dart';

/// Turns project logic (values, conditions, actions, state, API calls, custom
/// code) into Dart for exported projects. The editor-side equivalent is
/// `lib/runtime/preview_runtime.dart`.
///
/// State is per generation run: [begin] resets everything, [beginScreen]
/// resets per-screen state.
class LogicCodegen {
  static ProjectLogic logic = ProjectLogic();
  static bool hasSupabase = false;

  // Per screen
  static List<FieldDef> pageState = [];
  static List<FieldDef> pageParams = [];
  static final Set<String> imports = {};
  static final Map<String, String> widgetStateVars = {}; // var name -> declaration
  static final Set<String> _scopeOutputs = {};
  static int _counter = 0;

  // Per project
  static final Set<String> packages = {};

  static void begin(ProjectLogic projectLogic, {required bool supabase}) {
    logic = projectLogic;
    hasSupabase = supabase;
    packages.clear();
    _counter = 0;
  }

  static void beginScreen(Map<String, dynamic> screenProps) {
    pageState = PageLogic.pageState(screenProps);
    pageParams = PageLogic.pageParams(screenProps);
    imports.clear();
    widgetStateVars.clear();
    _scopeOutputs.clear();
  }

  // ---------------------------------------------------------------------------
  // Names and types

  static String ident(String raw) {
    var s = raw.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_');
    if (s.isEmpty) s = 'value';
    if (RegExp(r'^[0-9]').hasMatch(s)) s = 'v$s';
    const reserved = {'class', 'default', 'new', 'switch', 'case', 'if', 'else', 'for', 'while', 'return', 'this', 'super', 'null', 'true', 'false', 'is', 'in', 'var', 'final', 'const', 'void', 'enum', 'extends'};
    return reserved.contains(s) ? '${s}Value' : s;
  }

  static String typeName(String raw) {
    final words = raw.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), ' ').trim().split(' ').where((w) => w.isNotEmpty);
    final s = words.map((w) => w[0].toUpperCase() + w.substring(1)).join();
    if (s.isEmpty) return 'DataType';
    return RegExp(r'^[0-9]').hasMatch(s) ? 'T$s' : s;
  }

  static String dartType(String type, {bool isList = false}) {
    String base;
    if (VarTypes.isDataType(type) || VarTypes.isEnum(type)) imports.add('backend/schema/data_types.dart');
    if (VarTypes.isDataType(type)) {
      base = typeName(VarTypes.refName(type));
    } else if (VarTypes.isEnum(type)) {
      base = typeName(VarTypes.refName(type));
    } else {
      switch (type) {
        case VarTypes.integer:
          base = 'int';
          break;
        case VarTypes.decimal:
          base = 'double';
          break;
        case VarTypes.boolean:
          base = 'bool';
          break;
        case VarTypes.color:
          base = 'Color';
          break;
        case VarTypes.dateTime:
          base = 'DateTime?';
          break;
        case VarTypes.json:
          base = 'dynamic';
          break;
        case VarTypes.action:
          base = 'Future<void> Function()';
          break;
        default:
          base = 'String';
      }
    }
    if (isList) return 'List<${base.replaceAll('?', '')}>';
    return base;
  }

  static String fieldType(FieldDef f) => dartType(f.type, isList: f.isList);

  /// A Dart literal of [raw] for a slot of [type].
  static String literal(dynamic raw, String type, {bool isList = false}) {
    if (isList) {
      final items = raw is List ? raw : (raw == null || '$raw'.isEmpty ? const [] : '$raw'.split(',').map((e) => e.trim()).toList());
      final inner = dartType(type);
      return '<${inner.replaceAll('?', '')}>[${items.map((e) => literal(e, type)).join(', ')}]';
    }
    if (VarTypes.isDataType(type) || VarTypes.isEnum(type)) imports.add('backend/schema/data_types.dart');
    if (VarTypes.isDataType(type)) return '${typeName(VarTypes.refName(type))}()';
    if (VarTypes.isEnum(type)) {
      final e = logic.enums.where((e) => e.name == VarTypes.refName(type)).firstOrNull;
      final value = raw != null && '$raw'.isNotEmpty ? '$raw' : (e != null && e.values.isNotEmpty ? e.values.first : 'none');
      return '${typeName(VarTypes.refName(type))}.${ident(value)}';
    }
    switch (type) {
      case VarTypes.integer:
        return '${raw is num ? raw.toInt() : int.tryParse('${raw ?? ''}') ?? 0}';
      case VarTypes.decimal:
        return '${raw is num ? raw.toDouble() : double.tryParse('${raw ?? ''}') ?? 0.0}';
      case VarTypes.boolean:
        return '${raw == true || '$raw' == 'true'}';
      case VarTypes.color:
        final argb = ThemeGenerator.parseArgb(raw) ?? 0xFF000000;
        return 'const Color(0x${argb.toRadixString(16).padLeft(8, '0').toUpperCase()})';
      case VarTypes.dateTime:
        return raw == null || '$raw'.isEmpty ? 'null' : 'DateTime.tryParse(${_str(raw)})';
      case VarTypes.json:
        return raw == null ? 'null' : _str(raw);
      case VarTypes.action:
        return '() async {}';
    }
    return _str(raw ?? '');
  }

  static String _str(dynamic value) {
    final escaped = '${value ?? ''}'.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll(r'$', r'\$').replaceAll('\n', r'\n');
    return "'$escaped'";
  }

  /// Known type of [value], when it can be inferred.
  static FieldDef? typeOf(dynamic value) {
    if (!LogicValues.isValue(value)) return null;
    final v = value as Map;
    switch (v['source']) {
      case 'appState':
        return logic.appStateVar(v['name'] as String?);
      case 'pageState':
        return pageState.where((f) => f.name == v['name']).firstOrNull;
      case 'pageParam':
        return pageParams.where((f) => f.name == v['name']).firstOrNull;
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Values

  static void _useUtils() => imports.add('synapp/synapp_utils.dart');

  /// Dart expression for [value]. [expected] converts literals to that type.
  static String valueExpr(dynamic value, {String? expected, bool expectedList = false}) {
    if (!LogicValues.isValue(value)) {
      if (value == null) return 'null';
      return expected != null ? literal(value, expected, isList: expectedList) : _autoLiteral(value);
    }
    final v = value as Map;
    switch (v['source']) {
      case 'literal':
        return expected != null ? literal(v['value'], expected, isList: expectedList) : _autoLiteral(v['value']);
      case 'appState':
        final name = v['name'] as String?;
        if (logic.appStateVar(name) == null) return 'null';
        imports.add('app_state.dart');
        return 'AppState.instance.${ident(name!)}';
      case 'pageState':
        final name = v['name'] as String?;
        if (pageState.every((f) => f.name != name)) return 'null';
        return '_${ident(name!)}';
      case 'pageParam':
        final name = v['name'] as String?;
        if (pageParams.every((f) => f.name != name)) return 'null';
        return 'widget.${ident(name!)}';
      case 'widgetState':
        return _widgetStateExpr(v['widgetId']?.toString() ?? '', v['widgetType']?.toString());
      case 'queryField':
        final field = _str(v['field'] ?? '');
        if (ProjectGenerator.isInsideRepeatedList) return 'item[$field]';
        if (ProjectGenerator.queryBuilderDepth > 0) return '(data.isNotEmpty ? data[0][$field] : null)';
        return 'null';
      case 'actionOutput':
        final name = ident(v['name']?.toString() ?? 'output');
        if (!_scopeOutputs.contains(name)) return 'null';
        final path = v['path'] as String?;
        if (path == null || path.isEmpty) return name;
        _useUtils();
        return "getJsonField($name, r'${path.replaceAll("'", '')}')";
      case 'env':
        final env = logic.envValues.where((e) => e.name == v['name']).firstOrNull;
        if (env == null) return 'null';
        imports.add('env.dart');
        return 'Env.${ident(env.name)}';
      case 'authUser':
        if (!hasSupabase || !logic.usesAuth) return 'null';
        imports.add('package:supabase_flutter/supabase_flutter.dart');
        switch (v['field']) {
          case 'id':
            return 'Supabase.instance.client.auth.currentUser?.id';
          case 'isLoggedIn':
            return '(Supabase.instance.client.auth.currentUser != null)';
        }
        return 'Supabase.instance.client.auth.currentUser?.email';
      case 'function':
        final fn = logic.customCode.where((c) => c.kind == 'function' && c.name == v['name']).firstOrNull;
        if (fn == null) return 'null';
        imports.add('custom_code/custom_functions.dart');
        final args = (v['args'] as Map? ?? {});
        final argCode = fn.args.map((a) => coerce(args[a.name], a)).join(', ');
        return '${ident(fn.name)}($argCode)';
      case 'translation':
        imports.add('l10n/translations.dart');
        return 'tr(${_str(v['key'] ?? '')})';
      case 'screenWidth':
        return 'MediaQuery.sizeOf(context).width';
    }
    return 'null';
  }

  static String _autoLiteral(dynamic raw) {
    if (raw is num || raw is bool) return '$raw';
    return _str(raw ?? '');
  }

  /// String expression for display (Text, snack bars, URLs).
  static String stringExpr(dynamic value) {
    if (!LogicValues.isValue(value)) return _str(value ?? '');
    if ((value as Map)['source'] == 'literal') return _str(value['value'] ?? '');
    final expr = valueExpr(value);
    if (expr == 'null') return "''";
    final type = typeOf(value);
    if (type != null && type.type == VarTypes.string && !type.isList && value['source'] != 'pageParam') return expr;
    _useUtils();
    return 'valueToString($expr)';
  }

  /// Expression for a widget input's current value. Declares the backing
  /// variable when the widget lives on another screen.
  static String _widgetStateExpr(String widgetId, String? widgetType) {
    final safeId = widgetId.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    switch (widgetType) {
      case 'Checkbox':
      case 'CheckboxListTile':
        final name = '_checkbox_$safeId';
        widgetStateVars[name] = 'bool $name = false;';
        return name;
      case 'Switch':
      case 'SwitchListTile':
        final name = '_switch_$safeId';
        widgetStateVars[name] = 'bool $name = false;';
        return name;
      case 'Slider':
        final name = '_slider_$safeId';
        widgetStateVars[name] = 'double $name = 0.0;';
        return name;
      case 'RatingBar':
        final name = '_rating_$safeId';
        widgetStateVars[name] = 'double $name = 0.0;';
        return name;
      case 'PinCode':
        final name = '_pin_$safeId';
        widgetStateVars[name] = "String $name = '';";
        return name;
      case 'CounterButton':
        final name = '_counter_$safeId';
        widgetStateVars[name] = 'int $name = 0;';
        return name;
      case 'ChoiceChips':
      case 'CheckboxGroup':
        final name = '_choices_$safeId';
        widgetStateVars[name] = 'List<String> $name = [];';
        return name;
      case 'RadioGroup':
        final name = '_radio_$safeId';
        widgetStateVars[name] = 'String? $name;';
        return name;
      case 'DropdownButton':
      case 'DropDown':
        final name = '_dropdown_$safeId';
        widgetStateVars[name] = 'String? $name;';
        return name;
      case 'PlacePicker':
        final name = '_place_$safeId';
        widgetStateVars[name] = "String $name = '';";
        return name;
    }
    final name = '_controller_$safeId';
    widgetStateVars[name] = 'late final TextEditingController $name = TextEditingController();';
    return '$name.text';
  }

  // ---------------------------------------------------------------------------
  // Conditions

  static String conditionExpr(dynamic cond) {
    if (cond is! Map) return 'true';
    if (cond['conditions'] is List) {
      final parts = (cond['conditions'] as List).map(conditionExpr).toList();
      if (parts.isEmpty) return 'true';
      return '(${parts.join(cond['combine'] == 'or' ? ' || ' : ' && ')})';
    }
    _useUtils();
    final op = cond['op'] as String? ?? '==';
    final leftType = typeOf(cond['left']);
    final left = valueExpr(cond['left']);
    final right = valueExpr(cond['right'], expected: leftType?.isList == true ? null : leftType?.type);
    switch (op) {
      case '==':
        return 'looseEquals($left, $right)';
      case '!=':
        return '!looseEquals($left, $right)';
      case '>':
      case '>=':
      case '<':
      case '<=':
        return '(castToNum($left) $op castToNum($right))';
      case 'contains':
        return 'valueContains($left, $right)';
      case 'isEmpty':
        return 'valueIsEmpty($left)';
      case 'isNotEmpty':
        return '!valueIsEmpty($left)';
      case 'isTrue':
        return 'valueIsTruthy($left)';
      case 'isFalse':
        return '!valueIsTruthy($left)';
    }
    return 'true';
  }

  // ---------------------------------------------------------------------------
  // Actions

  static bool hasActions(dynamic actions) => actions is List && actions.isNotEmpty;

  static bool _needsAsync(List actions) {
    for (final a in actions.whereType<Map>()) {
      if (const {'callParameterAction', 'showDialog', 'confirmDialog', 'showBottomSheet', 'wait', 'customAction', 'launchUrl', 'copyToClipboard', 'share', 'apiCall', 'supabase_insert', 'supabase_update', 'supabase_delete', 'supabase_rpc', 'uploadFile', 'authSignIn', 'authSignUp', 'authResetPassword', 'authSignOut', 'navigate'}.contains(a['type'])) {
        return true;
      }
      for (final branch in ActionCatalog.branches(a)) {
        if (_needsAsync(branch)) return true;
      }
    }
    return false;
  }

  /// A closure such as `() async { ... }` running [actions].
  static String closure(List actions, {String indent = '      '}) {
    final body = statements(actions, indent: '$indent  ');
    if (body.trim().isEmpty) return '() {}';
    return '() ${_needsAsync(actions) ? 'async ' : ''}{\n$body\n$indent}';
  }

  static String statements(List actions, {String indent = '        '}) {
    final out = <String>[];
    for (final raw in actions) {
      if (raw is! Map) continue;
      final code = _action(Map<String, dynamic>.from(raw), indent);
      if (code.isNotEmpty) out.add(code);
    }
    return out.join('\n');
  }

  static String _branch(dynamic actions, String indent) => actions is List ? statements(actions, indent: indent) : '';

  static String _mountedGuard(String indent) => '${indent}if (!context.mounted) return;';

  static String _action(Map<String, dynamic> a, String i) {
    final inner = '$i  ';
    switch (a['type']) {
      case 'navigate':
        return _navigate(a, i);
      case 'navigateBack':
        return '${i}Navigator.maybePop(context);';
      case 'openDrawer':
        return '${i}_scaffoldKey.currentState?.openDrawer();';
      case 'updateAppState':
        final name = a['name'] as String?;
        final field = logic.appStateVar(name);
        if (field == null) return '$i// Update App State: choose a variable';
        imports.add('app_state.dart');
        return '${i}AppState.instance.${ident(field.name)} = ${_stateOpExpr('AppState.instance.${ident(field.name)}', field, a)};';
      case 'updatePageState':
        final name = a['name'] as String?;
        final field = pageState.where((f) => f.name == name).firstOrNull;
        if (field == null) return '$i// Update Page State: choose a variable';
        return '${i}setState(() => _${ident(field.name)} = ${_stateOpExpr('_${ident(field.name)}', field, a)});';
      case 'showSnackbar':
        final ms = (a['durationMs'] as num?)?.toInt() ?? 3000;
        return '${i}ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(${stringExpr(a['message'])}), duration: const Duration(milliseconds: $ms)));';
      case 'showDialog':
        return '''${i}await showDialog<void>(
$inner  context: context,
$inner  builder: (dialogContext) => AlertDialog(
$inner    title: Text(${stringExpr(a['title'])}),
$inner    content: Text(${stringExpr(a['message'])}),
$inner    actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(${_str(a['confirmText'] ?? 'OK')}))],
$inner  ),
$inner);
${_mountedGuard(i)}''';
      case 'confirmDialog':
        final v = 'confirmed${++_counter}';
        return '''${i}final $v = await showDialog<bool>(
$inner  context: context,
$inner  builder: (dialogContext) => AlertDialog(
$inner    title: Text(${stringExpr(a['title'])}),
$inner    content: Text(${stringExpr(a['message'])}),
$inner    actions: [
$inner      TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
$inner      FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Confirm')),
$inner    ],
$inner  ),
$inner) ?? false;
${_mountedGuard(i)}
${i}if ($v) {
${_branch(a['then'], inner)}
$i} else {
${_branch(a['else'], inner)}
$i}''';
      case 'showBottomSheet':
        return '''${i}await showModalBottomSheet<void>(
$inner  context: context,
$inner  builder: (sheetContext) => Padding(padding: const EdgeInsets.all(24), child: Text(${stringExpr(a['message'])})),
$inner);
${_mountedGuard(i)}''';
      case 'haptic':
        imports.add('package:flutter/services.dart');
        final method = const {'medium': 'mediumImpact', 'heavy': 'heavyImpact', 'selection': 'selectionClick'}[a['style']] ?? 'lightImpact';
        return '${i}HapticFeedback.$method();';
      case 'conditional':
        final elseCode = _branch(a['else'], inner);
        return '${i}if (${conditionExpr(a['condition'])}) {\n${_branch(a['then'], inner)}\n$i}${elseCode.trim().isEmpty ? '' : ' else {\n$elseCode\n$i}'}';
      case 'wait':
        return '${i}await Future<void>.delayed(const Duration(milliseconds: ${(a['ms'] as num?)?.toInt() ?? 500}));\n${_mountedGuard(i)}';
      case 'terminate':
        return '${i}return;';
      case 'callParameterAction':
        final param = pageParams.where((p) => p.name == a['name'] && p.type == VarTypes.action).firstOrNull;
        if (param == null) return '$i// Run Component Callback: choose an Action parameter of this component';
        return '${i}await widget.${ident(param.name)}${param.required ? '' : '?'}.call();\n${_mountedGuard(i)}';
      case 'customAction':
        final fn = logic.customCode.where((c) => c.kind == 'action' && c.name == a['name']).firstOrNull;
        if (fn == null) return '$i// Custom Action: choose an action';
        imports.add('custom_code/custom_actions.dart');
        final args = a['args'] as Map? ?? {};
        final argCode = ['context', ...fn.args.map((arg) => coerce(args[arg.name], arg))].join(', ');
        return '${i}await ${ident(fn.name)}($argCode);\n${_mountedGuard(i)}';
      case 'launchUrl':
        imports.add('package:url_launcher/url_launcher.dart');
        packages.add('url_launcher');
        return '${i}await launchUrl(Uri.parse(${stringExpr(a['url'])}));';
      case 'copyToClipboard':
        imports.add('package:flutter/services.dart');
        return '${i}await Clipboard.setData(ClipboardData(text: ${stringExpr(a['text'])}));';
      case 'share':
        imports.add('package:share_plus/share_plus.dart');
        packages.add('share_plus');
        return '${i}await Share.share(${stringExpr(a['text'])});';
      case 'toggleThemeMode':
        imports.add('app_state.dart');
        return '${i}AppState.instance.toggleThemeMode();';
      case 'setLanguage':
        imports.add('app_state.dart');
        return '${i}AppState.instance.languageCode = ${_str(a['language'] ?? 'en')};';
      case 'apiCall':
        return _apiCall(a, i);
      case 'supabase_insert':
      case 'supabase_update':
      case 'supabase_delete':
        return _supabaseMutation(a, i);
      case 'supabase_rpc':
        if (!hasSupabase) return '$i// Supabase is not connected: RPC skipped';
        imports.add('package:supabase_flutter/supabase_flutter.dart');
        final out = ident((a['outputName'] as String?)?.trim().isNotEmpty == true ? a['outputName'] as String : 'rpcResult${++_counter}');
        _scopeOutputs.add(out);
        final params = (a['params'] as Map? ?? {}).entries.map((e) => '${_str(e.key)}: ${valueExpr(e.value)}').join(', ');
        return '${i}final $out = await Supabase.instance.client.rpc(${_str(a['functionName'] ?? '')}, params: {$params});\n${_mountedGuard(i)}';
      case 'uploadFile':
        if (!hasSupabase) return '$i// Supabase is not connected: upload skipped';
        imports.add('package:supabase_flutter/supabase_flutter.dart');
        imports.add('package:file_picker/file_picker.dart');
        packages.add('file_picker');
        final out = ident((a['outputName'] as String?)?.trim().isNotEmpty == true ? a['outputName'] as String : 'uploadedUrl${++_counter}');
        _scopeOutputs.add(out);
        final bucket = _str(a['bucket'] ?? 'uploads');
        final picked = 'picked${++_counter}';
        return '''${i}final $picked = await FilePicker.platform.pickFiles(withData: true);
${i}String? $out;
${i}if ($picked != null && $picked.files.single.bytes != null) {
$inner final file = $picked.files.single;
$inner final path = '\${DateTime.now().millisecondsSinceEpoch}_\${file.name}';
$inner await Supabase.instance.client.storage.from($bucket).uploadBinary(path, file.bytes!);
$inner $out = Supabase.instance.client.storage.from($bucket).getPublicUrl(path);
$i}
${_mountedGuard(i)}''';
      case 'authSignIn':
      case 'authSignUp':
        if (!hasSupabase) return '$i// Supabase is not connected: authentication skipped';
        imports.add('package:supabase_flutter/supabase_flutter.dart');
        final call = a['type'] == 'authSignIn' ? 'signInWithPassword' : 'signUp';
        final elseCode = _branch(a['else'], '$inner  ');
        return '''${i}try {
$inner await Supabase.instance.client.auth.$call(email: ${stringExpr(a['email'])}, password: ${stringExpr(a['password'])});
$inner if (!context.mounted) return;
${_branch(a['then'], inner)}
$i} catch (e) {
$inner if (!context.mounted) return;
${elseCode.trim().isEmpty ? "$inner ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('\$e')));" : elseCode}
$i}''';
      case 'authResetPassword':
        if (!hasSupabase) return '$i// Supabase is not connected: password reset skipped';
        imports.add('package:supabase_flutter/supabase_flutter.dart');
        return '${i}await Supabase.instance.client.auth.resetPasswordForEmail(${stringExpr(a['email'])});';
      case 'authSignOut':
        if (!hasSupabase) return '$i// Supabase is not connected: sign-out skipped';
        imports.add('package:supabase_flutter/supabase_flutter.dart');
        return '${i}await Supabase.instance.client.auth.signOut();\n${_mountedGuard(i)}';
    }
    return '';
  }

  static String _stateOpExpr(String current, FieldDef field, Map a) {
    final op = a['op'] as String? ?? 'set';
    _useUtils();
    switch (op) {
      case 'increment':
      case 'decrement':
        final sign = op == 'increment' ? '+' : '-';
        final amount = a['value'] == null ? '1' : 'castToNum(${valueExpr(a['value'])})';
        final cast = field.type == VarTypes.decimal ? '.toDouble()' : '.toInt()';
        return '($current $sign $amount)$cast';
      case 'toggle':
        return '!$current';
      case 'clear':
        return field.isList ? literal(null, field.type, isList: true) : literal(field.defaultValue, field.type);
      case 'add':
        return '[...$current, ${valueExpr(a['value'], expected: field.type)}]';
      case 'remove':
        return '([...$current]..remove(${valueExpr(a['value'], expected: field.type)}))';
    }
    return coerce(a['value'], field);
  }

  /// [value] converted to [field]'s type.
  static String coerce(dynamic value, FieldDef field) {
    if (!LogicValues.isValue(value) || (value as Map)['source'] == 'literal') {
      return valueExpr(value, expected: field.type, expectedList: field.isList);
    }
    final known = typeOf(value);
    final expr = valueExpr(value);
    if (expr == 'null') return literal(field.defaultValue, field.type, isList: field.isList);
    if (known != null && known.type == field.type && known.isList == field.isList) {
      final nullable = value['source'] == 'pageParam' && !known.required && field.type != VarTypes.dateTime;
      return nullable ? '($expr ?? ${literal(field.defaultValue, field.type, isList: field.isList)})' : expr;
    }
    if (field.isList) return '($expr as List).cast<${dartType(field.type).replaceAll('?', '')}>()';
    switch (field.type) {
      case VarTypes.integer:
        return 'castToInt($expr)';
      case VarTypes.decimal:
        return 'castToDouble($expr)';
      case VarTypes.boolean:
        return 'valueIsTruthy($expr)';
      case VarTypes.string:
        return 'valueToString($expr)';
    }
    return '$expr as ${dartType(field.type)}';
  }

  static String _navigate(Map<String, dynamic> a, String i) {
    final targetId = a['targetScreenId'] as String?;
    if (targetId == '__back__') return '${i}Navigator.maybePop(context);';
    if (targetId == null || !BaseWidgetGenerator.idToClassName.containsKey(targetId)) return '$i// Navigate: choose a page';
    final className = BaseWidgetGenerator.idToClassName[targetId]!;
    final fileName = BaseWidgetGenerator.idToFileName[targetId];
    if (className != BaseWidgetGenerator.currentGeneratingScreenClass && fileName != null) {
      BaseWidgetGenerator.screenImports.add(fileName);
    }
    final targetParams = ProjectGenerator.pageParamsFor(targetId);
    final args = <String>[];
    if (ProjectGenerator.isInsideRepeatedList) args.add("idParam: item['id']?.toString()");
    final given = a['params'] as Map? ?? {};
    for (final p in targetParams) {
      if (given[p.name] == null) {
        if (p.required) args.add('${ident(p.name)}: ${literal(p.defaultValue, p.type, isList: p.isList)}');
        continue;
      }
      args.add('${ident(p.name)}: ${coerce(given[p.name], p)}');
    }
    final route = 'MaterialPageRoute(builder: (context) => $className(${args.join(', ')}))';
    return a['replace'] == 'yes' ? '${i}Navigator.pushReplacement(context, $route);' : '${i}Navigator.push(context, $route);';
  }

  static String _apiCall(Map<String, dynamic> a, String i) {
    final call = logic.apiCallById(a['apiCallId'] as String?);
    if (call == null) return '$i// API Call: choose a call';
    imports.add('backend/api_calls.dart');
    final result = 'apiResult${++_counter}';
    final out = ident((a['outputName'] as String?)?.trim().isNotEmpty == true ? a['outputName'] as String : '${ident(call.name)}Response');
    final given = a['variables'] as Map? ?? {};
    final args = call.variables
        .where((v) => given[v.name] != null)
        .map((v) => '${ident(v.name)}: ${coerce(given[v.name], FieldDef(name: v.name, type: v.type, isList: v.isList))}')
        .join(', ');
    _scopeOutputs.add(out);
    final thenCode = _branch(a['then'], '$i  ');
    final elseCode = _branch(a['else'], '$i  ');
    final branches = thenCode.trim().isEmpty && elseCode.trim().isEmpty
        ? ''
        : '\n${i}if ($result.succeeded) {\n$thenCode\n$i}${elseCode.trim().isEmpty ? '' : ' else {\n$elseCode\n$i}'}';
    return '''${i}final $result = await ApiCalls.${apiMethodName(call)}($args);
${i}final $out = $result.jsonBody;
${_mountedGuard(i)}$branches''';
  }

  static String _supabaseMutation(Map<String, dynamic> a, String i) {
    final table = a['tableName'] as String?;
    if (!hasSupabase || table == null || table.isEmpty) return '$i// Supabase is not connected: ${a['type']} skipped';
    final cap = table[0].toUpperCase() + table.substring(1);
    final idExpr = ProjectGenerator.isInsideRepeatedList
        ? "item['id']?.toString()"
        : (pageParams.any((p) => p.name == 'id') ? 'widget.id?.toString()' : 'widget.idParam');
    if (a['type'] == 'supabase_delete') {
      return '${i}await SupabaseService.instance.deleteFrom$cap($idExpr);\n${_mountedGuard(i)}';
    }
    final payload = (a['payload'] as Map? ?? {}).entries.map((e) => '${_str(e.key)}: ${_payloadValue(e.value)}').join(', ');
    final method = a['type'] == 'supabase_insert' ? 'insertInto$cap({$payload})' : 'update$cap($idExpr, {$payload})';
    return '${i}await SupabaseService.instance.$method;\n${_mountedGuard(i)}';
  }

  /// Payload entries use the original editor format
  /// `{'type': 'static' | 'widget_state' | 'query_data', 'value': ...}` or a value map.
  static String _payloadValue(dynamic v) {
    if (LogicValues.isValue(v)) return valueExpr(v);
    if (v is! Map) return _autoLiteral(v);
    final value = v['value']?.toString() ?? '';
    switch (v['type']) {
      case 'widget_state':
        return _widgetStateExpr(value, 'TextField');
      case 'query_data':
        return valueExpr({'source': 'queryField', 'field': value});
    }
    return _str(value);
  }

  // ---------------------------------------------------------------------------
  // Project files

  static String apiMethodName(ApiCallDef call) {
    final name = ident(call.name.replaceAll(RegExp(r'[^a-zA-Z0-9]+'), ' ').trim().split(' ').asMap().entries
        .map((e) => e.key == 0 ? e.value.toLowerCase() : (e.value.isEmpty ? '' : e.value[0].toUpperCase() + e.value.substring(1)))
        .join());
    return name.isEmpty ? 'apiCall' : name;
  }

  static String appStateFile() {
    final persisted = logic.appState.where((f) => f.persisted).toList();
    final fields = StringBuffer();
    final loads = StringBuffer();
    for (final f in logic.appState) {
      final name = ident(f.name);
      final type = fieldType(f);
      fields.writeln('  $type _$name = ${literal(f.defaultValue, f.type, isList: f.isList)};');
      fields.writeln('  $type get $name => _$name;');
      fields.writeln('  set $name($type value) {');
      fields.writeln('    _$name = value;');
      if (f.persisted) fields.writeln("    ${_persistWrite(f, "'ff_$name'", 'value')}");
      fields.writeln('    notifyListeners();');
      fields.writeln('  }');
      fields.writeln();
      if (f.persisted) loads.writeln('    ${_persistRead(f, "'ff_$name'", '_$name')}');
    }
    final defaultLanguage = logic.languages.isNotEmpty ? logic.languages.first : 'en';
    final themeMode = const {'dark': 'ThemeMode.dark', 'system': 'ThemeMode.system'}[logic.themeMode] ?? 'ThemeMode.light';
    final usesJson = persisted.any((f) => !_isSimplePersist(f));
    return '''import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
${usesJson ? "import 'dart:convert';\n" : ''}${logic.dataTypes.isNotEmpty || logic.enums.isNotEmpty ? "import 'backend/schema/data_types.dart';\n" : ''}
/// App-wide state. Widgets rebuild through `ListenableBuilder(listenable: AppState.instance, ...)`.
class AppState extends ChangeNotifier {
  AppState._();
  static final AppState instance = AppState._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTheme = _prefs!.getString('ff_themeMode');
    if (savedTheme != null) _themeMode = ThemeMode.values.firstWhere((m) => m.name == savedTheme, orElse: () => _themeMode);
    _languageCode = _prefs!.getString('ff_languageCode') ?? _languageCode;
$loads  }

  ThemeMode _themeMode = $themeMode;
  ThemeMode get themeMode => _themeMode;
  set themeMode(ThemeMode value) {
    _themeMode = value;
    _prefs?.setString('ff_themeMode', value.name);
    notifyListeners();
  }

  void toggleThemeMode() => themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

  String _languageCode = '$defaultLanguage';
  String get languageCode => _languageCode;
  set languageCode(String value) {
    _languageCode = value;
    _prefs?.setString('ff_languageCode', value);
    notifyListeners();
  }

$fields}
''';
  }

  static bool _isSimplePersist(FieldDef f) =>
      !f.isList && const {VarTypes.string, VarTypes.integer, VarTypes.decimal, VarTypes.boolean, VarTypes.color}.contains(f.type) ||
      (f.isList && f.type == VarTypes.string);

  static String _persistWrite(FieldDef f, String key, String value) {
    if (f.isList && f.type == VarTypes.string) return '_prefs?.setStringList($key, $value);';
    if (f.isList || VarTypes.isDataType(f.type) || f.type == VarTypes.json || f.type == VarTypes.dateTime || VarTypes.isEnum(f.type)) {
      if (VarTypes.isDataType(f.type)) {
        return f.isList ? '_prefs?.setString($key, jsonEncode($value.map((e) => e.toMap()).toList()));' : '_prefs?.setString($key, jsonEncode($value.toMap()));';
      }
      if (VarTypes.isEnum(f.type)) return f.isList ? '_prefs?.setStringList($key, $value.map((e) => e.name).toList());' : '_prefs?.setString($key, $value.name);';
      if (f.type == VarTypes.dateTime) return '_prefs?.setString($key, $value?.toIso8601String() ?? \'\');';
      return '_prefs?.setString($key, jsonEncode($value));';
    }
    switch (f.type) {
      case VarTypes.integer:
        return '_prefs?.setInt($key, $value);';
      case VarTypes.decimal:
        return '_prefs?.setDouble($key, $value);';
      case VarTypes.boolean:
        return '_prefs?.setBool($key, $value);';
      case VarTypes.color:
        return '_prefs?.setInt($key, $value.toARGB32());';
    }
    return '_prefs?.setString($key, $value);';
  }

  static String _persistRead(FieldDef f, String key, String target) {
    if (f.isList && f.type == VarTypes.string) return '$target = _prefs!.getStringList($key) ?? $target;';
    if (VarTypes.isDataType(f.type)) {
      final t = typeName(VarTypes.refName(f.type));
      return f.isList
          ? 'if (_prefs!.getString($key) != null) $target = (jsonDecode(_prefs!.getString($key)!) as List).map((e) => $t.fromMap(Map<String, dynamic>.from(e as Map))).toList();'
          : 'if (_prefs!.getString($key) != null) $target = $t.fromMap(Map<String, dynamic>.from(jsonDecode(_prefs!.getString($key)!) as Map));';
    }
    if (VarTypes.isEnum(f.type)) {
      final t = typeName(VarTypes.refName(f.type));
      return f.isList
          ? '$target = (_prefs!.getStringList($key) ?? []).map((n) => $t.values.firstWhere((e) => e.name == n, orElse: () => $t.values.first)).toList();'
          : 'final saved$target = _prefs!.getString($key); if (saved$target != null) $target = $t.values.firstWhere((e) => e.name == saved$target, orElse: () => $target);';
    }
    if (f.isList) return 'if (_prefs!.getString($key) != null) $target = (jsonDecode(_prefs!.getString($key)!) as List).cast<${dartType(f.type).replaceAll('?', '')}>();';
    switch (f.type) {
      case VarTypes.integer:
        return '$target = _prefs!.getInt($key) ?? $target;';
      case VarTypes.decimal:
        return '$target = _prefs!.getDouble($key) ?? $target;';
      case VarTypes.boolean:
        return '$target = _prefs!.getBool($key) ?? $target;';
      case VarTypes.color:
        return 'if (_prefs!.getInt($key) != null) $target = Color(_prefs!.getInt($key)!);';
      case VarTypes.dateTime:
        return '$target = DateTime.tryParse(_prefs!.getString($key) ?? \'\') ?? $target;';
      case VarTypes.json:
        return 'if (_prefs!.getString($key) != null) $target = jsonDecode(_prefs!.getString($key)!);';
    }
    return '$target = _prefs!.getString($key) ?? $target;';
  }

  static String dataTypesFile() {
    final out = StringBuffer("import 'package:flutter/material.dart';\n\n");
    for (final e in logic.enums) {
      final values = e.values.isEmpty ? ['none'] : e.values.map(ident).toList();
      out.writeln('enum ${typeName(e.name)} { ${values.join(', ')} }\n');
    }
    for (final t in logic.dataTypes) {
      final name = typeName(t.name);
      out.writeln('class $name {');
      out.writeln('  $name({${t.fields.map((f) => 'this.${ident(f.name)} = ${_constDefault(f)}').join(', ')}});');
      out.writeln();
      for (final f in t.fields) {
        out.writeln('  ${fieldType(f)}${VarTypes.isDataType(f.type) && !f.isList ? '?' : ''} ${ident(f.name)};');
      }
      out.writeln();
      out.writeln('  factory $name.fromMap(Map<String, dynamic> map) => $name(');
      for (final f in t.fields) {
        out.writeln("        ${ident(f.name)}: ${_fromMapExpr(f, "map['${f.name}']")},");
      }
      out.writeln('      );');
      out.writeln();
      out.writeln('  Map<String, dynamic> toMap() => {');
      for (final f in t.fields) {
        out.writeln("        '${f.name}': ${_toMapExpr(f, ident(f.name))},");
      }
      out.writeln('      };');
      out.writeln('}\n');
    }
    return out.toString();
  }

  static String _constDefault(FieldDef f) {
    if (f.isList) return 'const []';
    if (VarTypes.isDataType(f.type)) return 'null';
    final lit = literal(f.defaultValue, f.type);
    return lit.startsWith('DateTime.tryParse') ? 'null' : lit;
  }

  static String _fromMapExpr(FieldDef f, String raw) {
    if (VarTypes.isDataType(f.type)) {
      final t = typeName(VarTypes.refName(f.type));
      return f.isList
          ? '($raw as List? ?? []).map((e) => $t.fromMap(Map<String, dynamic>.from(e as Map))).toList()'
          : '$raw is Map ? $t.fromMap(Map<String, dynamic>.from($raw as Map)) : null';
    }
    if (VarTypes.isEnum(f.type)) {
      final t = typeName(VarTypes.refName(f.type));
      return '$t.values.firstWhere((e) => e.name == $raw, orElse: () => $t.values.first)';
    }
    if (f.isList) return '($raw as List? ?? []).cast<${dartType(f.type).replaceAll('?', '')}>()';
    switch (f.type) {
      case VarTypes.integer:
        return '($raw as num?)?.toInt() ?? ${_constDefault(f)}';
      case VarTypes.decimal:
        return '($raw as num?)?.toDouble() ?? ${_constDefault(f)}';
      case VarTypes.boolean:
        return '$raw as bool? ?? ${_constDefault(f)}';
      case VarTypes.color:
        return '$raw is int ? Color($raw as int) : ${_constDefault(f)}';
      case VarTypes.dateTime:
        return "DateTime.tryParse('\${$raw ?? ''}')";
      case VarTypes.json:
        return raw;
    }
    return "$raw?.toString() ?? ${_constDefault(f)}";
  }

  static String _toMapExpr(FieldDef f, String v) {
    if (VarTypes.isDataType(f.type)) return f.isList ? '$v.map((e) => e.toMap()).toList()' : '$v?.toMap()';
    if (VarTypes.isEnum(f.type)) return '$v.name';
    if (f.type == VarTypes.color && !f.isList) return '$v.toARGB32()';
    if (f.type == VarTypes.dateTime && !f.isList) return '$v?.toIso8601String()';
    return v;
  }

  static String apiCallsFile() {
    final methods = logic.apiCalls.map((call) {
      final params = call.variables.map((v) => '${fieldType(v).replaceAll('?', '')}? ${ident(v.name)}').join(', ');
      final vars = call.variables.map((v) => "'${v.name}': ${ident(v.name)} ?? ${literal(v.defaultValue, v.type, isList: v.isList)}").join(', ');
      final headers = call.headers.entries.map((e) => '${_str(e.key)}: fillTemplate(${_str(e.value)}, vars)').join(', ');
      final contentType = call.bodyType == 'json'
          ? "'Content-Type': 'application/json', "
          : call.bodyType == 'form'
              ? "'Content-Type': 'application/x-www-form-urlencoded', "
              : '';
      final hasBody = call.bodyType != 'none' && call.method.toUpperCase() != 'GET';
      final fields = call.responseFields
          .map((f) => "  static dynamic ${ident(f.name)}(dynamic body) => getJsonField(body, r'${f.jsonPath.replaceAll("'", '')}');")
          .join('\n');
      return '''
  /// ${call.method.toUpperCase()} ${call.url}
  static Future<ApiCallResponse> ${apiMethodName(call)}(${params.isEmpty ? '' : '{$params}'}) {
    final vars = <String, dynamic>{$vars};
    return _send(
      ${_str(call.method.toUpperCase())},
      fillTemplate(${_str(call.url)}, vars),
      headers: {$contentType$headers},
      body: ${hasBody ? 'fillTemplate(${_str(call.body)}, vars)' : 'null'},
    );
  }
${fields.isEmpty ? '' : '\n$fields\n'}''';
    }).join('\n');
    return '''import 'dart:convert';

import 'package:http/http.dart' as http;

import '../synapp/synapp_utils.dart';

class ApiCallResponse {
  const ApiCallResponse(this.statusCode, this.jsonBody, this.bodyText);

  final int statusCode;
  final dynamic jsonBody;
  final String bodyText;

  bool get succeeded => statusCode >= 200 && statusCode < 300;
}

class ApiCalls {
  static Future<ApiCallResponse> _send(String method, String url, {Map<String, String> headers = const {}, String? body}) async {
    try {
      final request = http.Request(method, Uri.parse(url))..headers.addAll(headers);
      if (body != null) request.body = body;
      final response = await http.Response.fromStream(await request.send());
      dynamic json;
      try {
        json = jsonDecode(response.body);
      } catch (_) {
        json = response.body;
      }
      return ApiCallResponse(response.statusCode, json, response.body);
    } catch (e) {
      return ApiCallResponse(0, null, e.toString());
    }
  }
$methods}
''';
  }

  static String customFunctionsFile() {
    final fns = logic.customCode.where((c) => c.kind == 'function').map((c) {
      final ret = c.returnType == 'void' ? 'dynamic' : dartType(c.returnType, isList: c.returnsList);
      final args = c.args.map((a) => '${fieldType(a)} ${ident(a.name)}').join(', ');
      final body = c.code.trim().isEmpty ? '  return ${c.returnType == 'void' ? 'null' : literal(null, c.returnType, isList: c.returnsList)};' : _indentBody(c.code);
      return '$ret ${ident(c.name)}($args) {\n$body\n}\n';
    }).join('\n');
    return "// Custom functions. Edit them in SynappKit › Logic › Custom Code.\nimport 'dart:math' as math;\n\nimport 'package:flutter/material.dart';\n${_schemaImport('../')}\n$fns";
  }

  static String customActionsFile() {
    final actions = logic.customCode.where((c) => c.kind == 'action').map((c) {
      final ret = c.returnType == 'void' ? 'void' : dartType(c.returnType, isList: c.returnsList);
      final args = ['BuildContext context', ...c.args.map((a) => '${fieldType(a)} ${ident(a.name)}')].join(', ');
      final body = c.code.trim().isEmpty ? (ret == 'void' ? '  // TODO: implement' : '  return ${literal(null, c.returnType, isList: c.returnsList)};') : _indentBody(c.code);
      return 'Future<$ret> ${ident(c.name)}($args) async {\n$body\n}\n';
    }).join('\n');
    return "// Custom actions. Edit them in SynappKit › Logic › Custom Code.\n// ignore_for_file: use_build_context_synchronously\nimport 'package:flutter/material.dart';\n${_schemaImport('../')}\n$actions";
  }

  static String customWidgetFile(CustomCodeDef c) {
    final className = typeName(c.name);
    final fields = c.args.map((a) => '  final ${fieldType(a)}${a.required ? '' : '?'} ${ident(a.name)};').join('\n');
    final params = c.args.map((a) => a.required ? 'required this.${ident(a.name)}' : 'this.${ident(a.name)}').join(', ');
    final body = c.code.trim().isEmpty ? '    return const Placeholder();' : _indentBody(c.code, indent: '    ');
    return '''// Custom widget. Edit it in SynappKit › Logic › Custom Code.
import 'package:flutter/material.dart';
${_schemaImport('../../')}
class $className extends StatefulWidget {
  const $className({super.key, this.width, this.height${params.isEmpty ? '' : ', $params'}});

  final double? width;
  final double? height;
$fields

  @override
  State<$className> createState() => _${className}State();
}

class _${className}State extends State<$className> {
  @override
  Widget build(BuildContext context) {
$body
  }
}
''';
  }

  static String _schemaImport(String prefix) =>
      logic.dataTypes.isNotEmpty || logic.enums.isNotEmpty ? "import '${prefix}backend/schema/data_types.dart';\n" : '';

  static String _indentBody(String code, {String indent = '  '}) =>
      code.trimRight().split('\n').map((l) => l.trim().isEmpty ? '' : '$indent$l').join('\n');

  static String envFile() {
    final envs = logic.environments.isEmpty ? ['dev'] : logic.environments;
    final getters = logic.envValues.map((e) {
      final type = dartType(e.type);
      final branches = envs.map((env) => "      '$env' => ${literal(e.values[env] ?? e.values.values.firstOrNull, e.type)},").join('\n');
      return '  static $type get ${ident(e.name)} => switch (environment) {\n$branches\n      _ => ${literal(e.values[envs.first], e.type)},\n    };';
    }).join('\n\n');
    return '''import 'package:flutter/material.dart';

/// Environment values. Pick the environment at build time:
///   flutter run --dart-define=APP_ENV=${envs.last}
class Env {
  static const String environment = String.fromEnvironment('APP_ENV', defaultValue: '${logic.activeEnvironment}');

$getters
}
''';
  }

  static String translationsFile() {
    final entries = logic.translations.entries.map((e) {
      final langs = e.value.entries.map((l) => '${_str(l.key)}: ${_str(l.value)}').join(', ');
      return '  ${_str(e.key)}: {$langs},';
    }).join('\n');
    return '''import '../app_state.dart';

const List<String> kSupportedLanguages = [${logic.languages.map(_str).join(', ')}];

const Map<String, Map<String, String>> kTranslations = {
$entries
};

/// Text for [key] in the current language, falling back to the default language.
String tr(String key) {
  final entry = kTranslations[key];
  if (entry == null) return key;
  return entry[AppState.instance.languageCode] ?? entry[kSupportedLanguages.first] ?? key;
}
''';
  }

  static String authGateFile(String loginClass, String loginFile, String homeClass, String homeFile) => '''import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '$loginFile';
import '$homeFile';

/// Shows [$homeClass] when signed in and [$loginClass] otherwise.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = Supabase.instance.client.auth.currentSession;
        return session == null ? const $loginClass() : const $homeClass();
      },
    );
  }
}
''';
}

/// A widget property bound to a value (`properties['bindings']`). Generators
/// that format properties through `dartString`, `formatColor` or string
/// interpolation emit the bound expression instead of the literal.
class BoundValue {
  final Map value;

  const BoundValue(this.value);

  String get stringCode => LogicCodegen.stringExpr(value);

  String get colorCode {
    final type = LogicCodegen.typeOf(value);
    final expr = LogicCodegen.valueExpr(value);
    if (expr == 'null') return 'Colors.transparent';
    if (type?.type == VarTypes.color) return expr;
    LogicCodegen._useUtils();
    return 'Color(castToInt($expr))';
  }

  /// Numeric use, e.g. `width: $value`.
  @override
  String toString() {
    final expr = LogicCodegen.valueExpr(value);
    if (expr == 'null') return 'null';
    LogicCodegen._useUtils();
    return 'castToDouble($expr)';
  }
}
