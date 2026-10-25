import '../models/widget_node.dart';
import './widget_generator_registry.dart';
import './theme_generator.dart';
import 'logic_codegen.dart';

abstract class BaseWidgetGenerator {
  /// Properties used by the editor and logic layer, never passed to widgets.
  static const Set<String> editorOnlyKeys = {
    'navigateTo', 'actions', 'id', 'children', 'pageName', 'description', 'paddingLinked',
    'backendQuery', 'dataBinding', 'bindings', 'visibility', 'animation', 'semanticLabel',
    'onLongPress', 'onDoubleTap', 'onChanged', 'onSubmitted', 'pageState', 'pageParams', 'onPageLoad',
    'apiQuery', 'comments', 'onPressed',
  };

  static Map<String, String> idToClassName = {};
  static Map<String, String> idToFileName = {};
  static Set<String> screenImports = {};
  static Map<String, dynamic> themeProps = {};
  static List<String> stateVariables = []; // Collects: "bool _isAccepted = false;"
  static List<String> disposeVariables = []; // Collects: "_controller.dispose();"

  String generateCode(WidgetNode node, {int indent = 0});
  
  String getIndentString(int indent) => '  ' * indent;
  String getChildIndentStr(int indent) => '  ' * (indent + 1);

  /// JSON often stores `"Axis.horizontal"`; avoid `Axis.Axis.horizontal` in Dart.
  String axisExpression(dynamic raw) {
    final s = raw?.toString().trim() ?? '';
    if (s.isEmpty) return 'Axis.vertical';
    if (s.startsWith('Axis.')) return s;
    return 'Axis.$s';
  }

  String generateNavigationCode(String? targetId) {
    if (targetId == null) return '() {}';
    return LogicCodegen.closure([
      {'type': 'navigate', 'targetScreenId': targetId}
    ]);
  }

  /// Closure running [actions] (see `LogicCodegen`); [fallbackTargetId] is the
  /// legacy `navigateTo` property.
  String generateActionFlowCode(List<dynamic>? actions, String? fallbackTargetId) {
    final list = [...?actions];
    if (list.isEmpty && fallbackTargetId != null) {
      list.add({'type': 'navigate', 'targetScreenId': fallbackTargetId});
    }
    if (list.isEmpty) return '() {}';
    return LogicCodegen.closure(list);
  }

  /// Navigation statement (without a closure) to [targetId], or '' if unknown.
  String generateNavigationBody(String? targetId) {
    if (targetId == null || !idToClassName.containsKey(targetId)) return '';
    if (idToClassName[targetId] == currentGeneratingScreenClass) return '';
    return LogicCodegen.statements([
      {'type': 'navigate', 'targetScreenId': targetId}
    ], indent: '').trim();
  }

  /// Expression for a Supabase row [field] in the current query context.
  String queryFieldExpr(dynamic field) {
    final expr = LogicCodegen.valueExpr({'source': 'queryField', 'field': field});
    return expr == 'null' ? "''" : "$expr?.toString() ?? ''";
  }

  static String currentGeneratingScreenClass = '';

  String generateProperties(Map<String, dynamic> properties, {int indent = 0}) {
    final props = <String>[];
    final currentIndent = getIndentString(indent);
    final nestedChildIndentStr = getChildIndentStr(indent + 1);
    final Map<String, dynamic> filteredProperties = Map.from(properties)..removeWhere((key, value) => 
      editorOnlyKeys.contains(key));
    
    filteredProperties.forEach((key, value) {
      if (value != null) {
        String formattedValue;
        if (value is WidgetNode) {
          formattedValue = WidgetGeneratorRegistry.generateCode(value, indent: indent + 1);
        } else if (value is Map<String, dynamic>) {
          // It's a nested WidgetNode property
          try {
            final WidgetNode nestedNode = WidgetNode.fromJson(value);
            formattedValue = WidgetGeneratorRegistry.generateCode(nestedNode, indent: indent + 1);
          } catch (e) {
            print('Error generating code for nested property $key: $e');
            formattedValue = value.toString(); // Fallback to raw string
          }
        } else if (value is List<dynamic>) {
          // It's a list of dynamic items, could be a list of WidgetNodes (e.g., actions)
          final List<String> listItems = [];
          for (var item in value) {
            if (item is WidgetNode) {
              listItems.add(WidgetGeneratorRegistry.generateCode(item, indent: indent + 2));
            } else if (item is Map<String, dynamic>) {
              try {
                final WidgetNode listItemNode = WidgetNode.fromJson(item);
                listItems.add(WidgetGeneratorRegistry.generateCode(listItemNode, indent: indent + 2));
              } catch (e) {
                print('Error generating code for list item in property $key: $e');
                listItems.add(item.toString());
              }
            } else if (item is String && item.startsWith('0x')) {
              listItems.add('Color($item)'); // Handle color strings in lists
            } else if (item is String) {
              listItems.add('\'$item\''); // Quote other string literals in lists
            } else {
              listItems.add(item.toString());
            }
          }
          formattedValue = '[\n$nestedChildIndentStr${listItems.join(',\n$nestedChildIndentStr')}\n$currentIndent]';
        } else if (value is String) {
          // Handle special string formats for Flutter constants/functions
          if (value.startsWith('0x') && value.length >= 8) {
            // Likely a color string like 0xFFRRGGBB
            formattedValue = 'Color($value)';
          } else if (value.contains('.')) {
            // Check for common Flutter constants/enums that shouldn't be quoted
            final List<String> flutterPrefixes = [
              'Icons.', 'EdgeInsets.', 'CrossAxisAlignment.', 'MainAxisAlignment.', 
              'MainAxisSize.', 'FontWeight.', 'TextAlign.', 'TextDecoration.', 
              'TextOverflow.', 'BoxFit.', 'Alignment.', 'FontStyle.', 'Axis.',
              'TextDirection.', 'VerticalDirection.', 'Clip.', 'BorderStyle.',
              'BoxShape.', 'Shadow.', 'Colors.'
            ];
            
            bool isFlutterConstant = false;
            for (final prefix in flutterPrefixes) {
              if (value.startsWith(prefix)) {
                isFlutterConstant = true;
                break;
              }
            }
            
            if (isFlutterConstant) {
              formattedValue = value;
            } else {
              formattedValue = '\'${escapeString(value)}\'';
            }
          } else if (value.startsWith('() {') && value.endsWith('}')) {
            // Likely an anonymous function string
            formattedValue = value; // Keep as is, e.g., () {}
          } else if (key.toLowerCase().contains('color') && (value.startsWith('0x') || int.tryParse(value) != null)) {
            // Handle hex strings or numeric strings for colors
            formattedValue = formatColor(value);
          } else {
            formattedValue = '\'${escapeString(value)}\''; // Quote other string literals
          }

        } else if (value is double || value is int || value is bool) {
          // Convert color integers to hex strings for better readability
          if (key.toLowerCase().contains('color') && value is int) {
            formattedValue = formatColor(value);
          } else {
            formattedValue = value.toString();
          }
        } else if (value is Map<String, dynamic> && 
                   (key.toLowerCase().contains('padding') || key.toLowerCase().contains('margin'))) {
          // Handle Map-based edge insets that didn't go through a specific generator
          final left = value['left'] ?? 0;
          final right = value['right'] ?? 0;
          final top = value['top'] ?? 0;
          final bottom = value['bottom'] ?? 0;
          formattedValue = 'EdgeInsets.only(left: $left, top: $top, right: $right, bottom: $bottom)';
        } else {
          formattedValue = value.toString(); // Generic fallback
        }

        props.add('$key: $formattedValue');
      }
    });
    return props.join(',\n$currentIndent ');
  }

  String formatColor(dynamic value) {
    if (value == null) return 'Colors.transparent';
    if (value is BoundValue) return value.colorCode;
    if (value is String) {
      if (value.startsWith('Colors.') || value.startsWith('AppTheme.')) return value;
      final token = ThemeGenerator.tokenForKey(value);
      if (token != null) return token;
    }
    final argb = ThemeGenerator.parseArgb(value);
    if (argb == null) return 'Colors.transparent';
    return ThemeGenerator.mapColorToToken('0x${argb.toRadixString(16).padLeft(8, '0').toUpperCase()}', themeProps);
  }

  String generateChildren(List<WidgetNode> children, {int indent = 0}) {
    if (children.isEmpty) return '';
    final childIndent = getChildIndentStr(indent);
    return '\n$childIndent children: [\n' + 
           children.map((c) => WidgetGeneratorRegistry.generateCode(c, indent: indent + 2)).join(',\n') + 
           '\n$childIndent],';
  }

  String escapeString(String value) {
    // Escape backslashes, single quotes, dollar signs, and newlines
    return value
        .replaceAll('\\', '\\\\')
        .replaceAll("'", "\\'")
        .replaceAll("\$", "\\\$")
        .replaceAll("\n", "\\n");
  }

  /// A single-quoted Dart string literal holding [value] verbatim.
  String dartString(dynamic value) {
    if (value is BoundValue) return value.stringCode;
    return "'${escapeString(value?.toString() ?? '')}'";
  }

  String parseEdgeInsets(dynamic value) {
    if (value is Map) {
      final left = value['left'] ?? 0;
      final right = value['right'] ?? 0;
      final top = value['top'] ?? 0;
      final bottom = value['bottom'] ?? 0;
      return 'EdgeInsets.only(left: $left, top: $top, right: $right, bottom: $bottom)';
    } else if (value is String) {
      if (value.startsWith('EdgeInsets.')) {
        return value;
      }
      return 'EdgeInsets.all($value)';
    } else {
      return 'EdgeInsets.all($value)';
    }
  }
}
 