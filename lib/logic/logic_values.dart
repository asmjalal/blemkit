/// JSON shapes shared by the editor, the canvas preview runtime and the code
/// generator.
///
/// A *value* says where data comes from:
///   {'source': 'literal', 'value': 'Hello'}
///   {'source': 'appState', 'name': 'counter'}
///   {'source': 'pageState', 'name': 'isOpen'}
///   {'source': 'pageParam', 'name': 'productId'}
///   {'source': 'widgetState', 'widgetId': '...', 'widgetType': 'TextField'}
///   {'source': 'queryField', 'field': 'title'}      (current Supabase row)
///   {'source': 'actionOutput', 'name': 'response'}  (result of an earlier action)
///   {'source': 'env', 'name': 'apiBase'}
///   {'source': 'authUser', 'field': 'email' | 'id' | 'isLoggedIn'}
///   {'source': 'function', 'name': 'formatPrice', 'args': [value, ...]}
///   {'source': 'translation', 'key': 'welcome'}
///   {'source': 'screenWidth'}
///
/// A *condition* compares two values:
///   {'left': value, 'op': '==', 'right': value}
/// or combines several: {'combine': 'and' | 'or', 'conditions': [condition, ...]}
class LogicValues {
  static const List<String> sources = [
    'literal',
    'appState',
    'pageState',
    'pageParam',
    'widgetState',
    'queryField',
    'actionOutput',
    'env',
    'authUser',
    'function',
    'translation',
    'screenWidth',
  ];

  static const Map<String, String> sourceLabels = {
    'literal': 'Specific value',
    'appState': 'App state',
    'pageState': 'Page state',
    'pageParam': 'Page parameter',
    'widgetState': 'Widget state (input)',
    'queryField': 'Supabase row field',
    'actionOutput': 'Action output',
    'env': 'Environment value',
    'authUser': 'Authenticated user',
    'function': 'Custom function',
    'translation': 'Translated text',
    'screenWidth': 'Screen width',
  };

  static const List<String> operators = ['==', '!=', '>', '>=', '<', '<=', 'contains', 'isEmpty', 'isNotEmpty', 'isTrue', 'isFalse'];

  static const Map<String, String> operatorLabels = {
    '==': 'equals',
    '!=': 'does not equal',
    '>': 'is greater than',
    '>=': 'is at least',
    '<': 'is less than',
    '<=': 'is at most',
    'contains': 'contains',
    'isEmpty': 'is empty',
    'isNotEmpty': 'is not empty',
    'isTrue': 'is true',
    'isFalse': 'is false',
  };

  static bool isUnary(String? op) => const {'isEmpty', 'isNotEmpty', 'isTrue', 'isFalse'}.contains(op);

  static Map<String, dynamic> literal(dynamic value) => {'source': 'literal', 'value': value};

  static bool isValue(dynamic v) => v is Map && v['source'] is String;

  static String describe(dynamic value) {
    if (!isValue(value)) return value == null ? '—' : value.toString();
    final v = value as Map;
    switch (v['source']) {
      case 'literal':
        final raw = v['value'];
        return raw is String ? '"$raw"' : '$raw';
      case 'appState':
        return 'App › ${v['name']}';
      case 'pageState':
        return 'Page › ${v['name']}';
      case 'pageParam':
        return 'Param › ${v['name']}';
      case 'widgetState':
        return 'Input › ${v['widgetLabel'] ?? v['widgetType'] ?? 'widget'}';
      case 'queryField':
        return 'Row › ${v['field']}';
      case 'actionOutput':
        return 'Output › ${v['name']}${v['path'] != null ? '.${v['path']}' : ''}';
      case 'env':
        return 'Env › ${v['name']}';
      case 'authUser':
        return 'User › ${v['field'] ?? 'email'}';
      case 'function':
        return '${v['name']}(…)';
      case 'translation':
        return 'Text › ${v['key']}';
      case 'screenWidth':
        return 'Screen width';
    }
    return '?';
  }

  static String describeCondition(dynamic cond) {
    if (cond is! Map) return 'Always';
    if (cond['conditions'] is List) {
      final joiner = cond['combine'] == 'or' ? ' OR ' : ' AND ';
      return (cond['conditions'] as List).map(describeCondition).join(joiner);
    }
    final op = cond['op'] as String? ?? '==';
    final left = describe(cond['left']);
    if (isUnary(op)) return '$left ${operatorLabels[op]}';
    return '$left ${operatorLabels[op] ?? op} ${describe(cond['right'])}';
  }
}

/// Where an action parameter's value comes from in the editor form.
enum ActionParamKind { value, text, number, page, appStateVar, pageStateVar, stateOp, choice, apiCall, customAction, table, condition, actions }

class ActionParamSpec {
  final String key;
  final String label;
  final ActionParamKind kind;
  final List<String> choices;
  final bool optional;

  const ActionParamSpec(this.key, this.label, this.kind, {this.choices = const [], this.optional = false});
}

class ActionSpec {
  final String type;
  final String label;
  final String category;
  final List<ActionParamSpec> params;

  const ActionSpec(this.type, this.label, this.category, this.params);
}

/// Every action the action-flow editor can add. Codegen lives in
/// `lib/generators/logic_codegen.dart`, preview behaviour in
/// `lib/runtime/preview_runtime.dart`.
class ActionCatalog {
  static const List<String> triggers = ['actions', 'onLongPress', 'onDoubleTap'];
  static const Map<String, String> triggerLabels = {
    'actions': 'On Tap',
    'onLongPress': 'On Long Press',
    'onDoubleTap': 'On Double Tap',
    'onChanged': 'On Change',
    'onSubmitted': 'On Submit',
    'onPageLoad': 'On Page Load',
  };

  static const List<String> stateOps = ['set', 'increment', 'decrement', 'toggle', 'clear', 'add', 'remove'];

  static const List<ActionSpec> all = [
    // Navigation
    ActionSpec('navigate', 'Navigate To', 'Navigation', [
      ActionParamSpec('targetScreenId', 'Page', ActionParamKind.page),
      ActionParamSpec('replace', 'Replace current page', ActionParamKind.choice, choices: ['no', 'yes'], optional: true),
    ]),
    ActionSpec('navigateBack', 'Navigate Back', 'Navigation', []),
    ActionSpec('openDrawer', 'Open Drawer', 'Navigation', []),
    // State
    ActionSpec('updateAppState', 'Update App State', 'State', [
      ActionParamSpec('name', 'Variable', ActionParamKind.appStateVar),
      ActionParamSpec('op', 'Operation', ActionParamKind.stateOp),
      ActionParamSpec('value', 'Value', ActionParamKind.value, optional: true),
    ]),
    ActionSpec('updatePageState', 'Update Page State', 'State', [
      ActionParamSpec('name', 'Variable', ActionParamKind.pageStateVar),
      ActionParamSpec('op', 'Operation', ActionParamKind.stateOp),
      ActionParamSpec('value', 'Value', ActionParamKind.value, optional: true),
    ]),
    // Feedback
    ActionSpec('showSnackbar', 'Show Snack Bar', 'Feedback', [
      ActionParamSpec('message', 'Message', ActionParamKind.value),
      ActionParamSpec('durationMs', 'Duration (ms)', ActionParamKind.number, optional: true),
    ]),
    ActionSpec('showDialog', 'Show Alert Dialog', 'Feedback', [
      ActionParamSpec('title', 'Title', ActionParamKind.value),
      ActionParamSpec('message', 'Message', ActionParamKind.value),
      ActionParamSpec('confirmText', 'Button text', ActionParamKind.text, optional: true),
    ]),
    ActionSpec('confirmDialog', 'Confirm Dialog', 'Feedback', [
      ActionParamSpec('title', 'Title', ActionParamKind.value),
      ActionParamSpec('message', 'Message', ActionParamKind.value),
      ActionParamSpec('then', 'If confirmed', ActionParamKind.actions),
      ActionParamSpec('else', 'If cancelled', ActionParamKind.actions, optional: true),
    ]),
    ActionSpec('showBottomSheet', 'Show Bottom Sheet', 'Feedback', [
      ActionParamSpec('message', 'Message', ActionParamKind.value),
    ]),
    ActionSpec('haptic', 'Haptic Feedback', 'Feedback', [
      ActionParamSpec('style', 'Style', ActionParamKind.choice, choices: ['light', 'medium', 'heavy', 'selection']),
    ]),
    // Logic
    ActionSpec('conditional', 'If / Else', 'Logic', [
      ActionParamSpec('condition', 'Condition', ActionParamKind.condition),
      ActionParamSpec('then', 'Then', ActionParamKind.actions),
      ActionParamSpec('else', 'Else', ActionParamKind.actions, optional: true),
    ]),
    ActionSpec('wait', 'Wait (Delay)', 'Logic', [
      ActionParamSpec('ms', 'Milliseconds', ActionParamKind.number),
    ]),
    ActionSpec('terminate', 'Stop Actions', 'Logic', []),
    ActionSpec('callParameterAction', 'Run Component Callback', 'Logic', [
      ActionParamSpec('name', 'Callback parameter', ActionParamKind.text),
    ]),
    ActionSpec('customAction', 'Custom Action', 'Logic', [
      ActionParamSpec('name', 'Custom action', ActionParamKind.customAction),
    ]),
    // Utilities
    ActionSpec('launchUrl', 'Launch URL', 'Utilities', [
      ActionParamSpec('url', 'URL', ActionParamKind.value),
    ]),
    ActionSpec('copyToClipboard', 'Copy to Clipboard', 'Utilities', [
      ActionParamSpec('text', 'Text', ActionParamKind.value),
    ]),
    ActionSpec('share', 'Share Text', 'Utilities', [
      ActionParamSpec('text', 'Text', ActionParamKind.value),
    ]),
    ActionSpec('toggleThemeMode', 'Toggle Dark Mode', 'Utilities', []),
    ActionSpec('setLanguage', 'Set Language', 'Utilities', [
      ActionParamSpec('language', 'Language code', ActionParamKind.text),
    ]),
    // Backend
    ActionSpec('apiCall', 'API Call', 'Backend', [
      ActionParamSpec('apiCallId', 'API call', ActionParamKind.apiCall),
      ActionParamSpec('outputName', 'Save response as', ActionParamKind.text, optional: true),
      ActionParamSpec('then', 'On success', ActionParamKind.actions, optional: true),
      ActionParamSpec('else', 'On failure', ActionParamKind.actions, optional: true),
    ]),
    ActionSpec('supabase_insert', 'Supabase: Insert Row', 'Backend', [
      ActionParamSpec('tableName', 'Table', ActionParamKind.table),
    ]),
    ActionSpec('supabase_update', 'Supabase: Update Row', 'Backend', [
      ActionParamSpec('tableName', 'Table', ActionParamKind.table),
    ]),
    ActionSpec('supabase_delete', 'Supabase: Delete Row', 'Backend', [
      ActionParamSpec('tableName', 'Table', ActionParamKind.table),
    ]),
    ActionSpec('supabase_rpc', 'Supabase: Call Function (RPC)', 'Backend', [
      ActionParamSpec('functionName', 'Function name', ActionParamKind.text),
      ActionParamSpec('outputName', 'Save result as', ActionParamKind.text, optional: true),
    ]),
    ActionSpec('uploadFile', 'Upload File (Storage)', 'Backend', [
      ActionParamSpec('bucket', 'Bucket', ActionParamKind.text),
      ActionParamSpec('outputName', 'Save URL as', ActionParamKind.text, optional: true),
    ]),
    // Auth
    ActionSpec('authSignIn', 'Sign In (Email)', 'Authentication', [
      ActionParamSpec('email', 'Email', ActionParamKind.value),
      ActionParamSpec('password', 'Password', ActionParamKind.value),
      ActionParamSpec('then', 'On success', ActionParamKind.actions, optional: true),
      ActionParamSpec('else', 'On failure', ActionParamKind.actions, optional: true),
    ]),
    ActionSpec('authSignUp', 'Create Account (Email)', 'Authentication', [
      ActionParamSpec('email', 'Email', ActionParamKind.value),
      ActionParamSpec('password', 'Password', ActionParamKind.value),
      ActionParamSpec('then', 'On success', ActionParamKind.actions, optional: true),
      ActionParamSpec('else', 'On failure', ActionParamKind.actions, optional: true),
    ]),
    ActionSpec('authResetPassword', 'Reset Password', 'Authentication', [
      ActionParamSpec('email', 'Email', ActionParamKind.value),
    ]),
    ActionSpec('authSignOut', 'Sign Out', 'Authentication', []),
  ];

  static const List<String> categories = ['Navigation', 'State', 'Feedback', 'Logic', 'Utilities', 'Backend', 'Authentication'];

  static ActionSpec? spec(String? type) => all.where((a) => a.type == type).firstOrNull;

  static String label(Map action) => spec(action['type'] as String?)?.label ?? (action['type']?.toString() ?? 'Action');

  /// Nested action lists inside [action] (branches of conditionals, callbacks).
  static Iterable<List> branches(Map action) sync* {
    for (final key in const ['then', 'else']) {
      final branch = action[key];
      if (branch is List) yield branch;
    }
  }
}
