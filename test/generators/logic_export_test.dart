import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:designflutterkit/generators/project_generator.dart';
import 'package:designflutterkit/models/project_logic.dart';
import 'package:designflutterkit/models/supabase_connection_model.dart';
import 'package:designflutterkit/models/backend_query_model.dart';
import 'package:designflutterkit/models/widget_node.dart';

/// A project that uses every logic feature. `tool/check_export.sh` compiles
/// the export, so a codegen regression in any action, value source or
/// project file shows up as an analyzer error.
void main() {
  Map<String, dynamic> lit(dynamic v) => {'source': 'literal', 'value': v};
  Map<String, dynamic> app(String name) => {'source': 'appState', 'name': name};
  Map<String, dynamic> page(String name) => {'source': 'pageState', 'name': name};
  Map<String, dynamic> param(String name) => {'source': 'pageParam', 'name': name};

  final logic = ProjectLogic(
    appState: [
      FieldDef(name: 'counter', type: VarTypes.integer, defaultValue: 0, persisted: true),
      FieldDef(name: 'username', type: VarTypes.string, defaultValue: 'Guest', persisted: true),
      FieldDef(name: 'ratio', type: VarTypes.decimal, defaultValue: 0.5),
      FieldDef(name: 'isPro', type: VarTypes.boolean, persisted: true),
      FieldDef(name: 'accent', type: VarTypes.color, defaultValue: '0xFF4F46E5', persisted: true),
      FieldDef(name: 'tags', type: VarTypes.string, isList: true, persisted: true),
      FieldDef(name: 'scores', type: VarTypes.integer, isList: true, persisted: true),
      FieldDef(name: 'lastSeen', type: VarTypes.dateTime, persisted: true),
      FieldDef(name: 'payload', type: VarTypes.json, persisted: true),
      FieldDef(name: 'cart', type: 'DataType:CartItem', isList: true, persisted: true),
      FieldDef(name: 'status', type: 'Enum:OrderStatus', persisted: true),
    ],
    dataTypes: [
      CustomDataType(name: 'CartItem', fields: [
        FieldDef(name: 'title', type: VarTypes.string),
        FieldDef(name: 'qty', type: VarTypes.integer, defaultValue: 1),
        FieldDef(name: 'price', type: VarTypes.decimal),
        FieldDef(name: 'tags', type: VarTypes.string, isList: true),
        FieldDef(name: 'color', type: VarTypes.color),
        FieldDef(name: 'addedAt', type: VarTypes.dateTime),
        FieldDef(name: 'status', type: 'Enum:OrderStatus'),
      ]),
      CustomDataType(name: 'Order', fields: [
        FieldDef(name: 'items', type: 'DataType:CartItem', isList: true),
        FieldDef(name: 'main item', type: 'DataType:CartItem'),
      ]),
    ],
    enums: [CustomEnum(name: 'OrderStatus', values: ['pending', 'shipped', 'delivered'])],
    apiCalls: [
      ApiCallDef(
        id: 'api1',
        name: 'Get Posts',
        url: r'https://jsonplaceholder.typicode.com/posts?userId=[userId]',
        headers: {'Accept': 'application/json', 'X-User': '[userId]'},
        variables: [FieldDef(name: 'userId', type: VarTypes.integer, defaultValue: 1)],
        responseFields: [ApiResponseField(name: 'titles', jsonPath: r'$[*].title', isList: true)],
      ),
      ApiCallDef(id: 'api2', name: 'create post', method: 'POST', url: 'https://example.com/posts', bodyType: 'json', body: '{"title": "[title]", "price": "\$5"}',
          variables: [FieldDef(name: 'title')]),
    ],
    customCode: [
      CustomCodeDef(id: 'f1', kind: 'function', name: 'formatPrice', args: [FieldDef(name: 'amount', type: VarTypes.decimal)], returnType: VarTypes.string,
          code: r"return '\$${amount.toStringAsFixed(2)}';"),
      CustomCodeDef(id: 'f2', kind: 'function', name: 'emptyFn', returnType: VarTypes.integer, returnsList: true),
      CustomCodeDef(id: 'a1', kind: 'action', name: 'logEvent', args: [FieldDef(name: 'name')], code: "debugPrint('event: \$name');"),
      CustomCodeDef(id: 'a2', kind: 'action', name: 'fetchTotal', returnType: VarTypes.decimal),
      CustomCodeDef(id: 'w1', kind: 'widget', name: 'PriceTag', args: [FieldDef(name: 'label', required: true)],
          code: "return Container(width: widget.width, height: widget.height, color: Colors.amber, child: Text(widget.label));"),
    ],
    envValues: [
      EnvValue(name: 'apiBase', values: {'dev': 'https://dev.example.com', 'prod': 'https://example.com'}),
      EnvValue(name: 'pageSize', type: VarTypes.integer, values: {'dev': '10', 'prod': '50'}),
    ],
    dependencies: [PackageDep(name: 'collection', version: '^1.18.0')],
    authProvider: 'supabase',
    loginPageId: 'login',
    homePageId: 'home',
    languages: ['en', 'es'],
    translations: {
      'welcome': {'en': 'Welcome', 'es': 'Bienvenido'},
      'quote': {'en': "It's \$5", 'es': 'Cuesta \$5'},
    },
    rtl: true,
    themeMode: 'system',
  );

  WidgetNode button(String label, List<Map<String, dynamic>> actions) =>
      WidgetNode(type: 'ElevatedButton', properties: {'text': label, 'actions': actions});

  final home = WidgetNode(id: 'home', type: 'Scaffold', properties: {
    'pageName': 'Home',
    'pageState': [
      FieldDef(name: 'tab', type: VarTypes.integer).toJson(),
      FieldDef(name: 'query', type: VarTypes.string, defaultValue: "it's").toJson(),
      FieldDef(name: 'selected', type: VarTypes.string, isList: true).toJson(),
      FieldDef(name: 'showDetails', type: VarTypes.boolean, defaultValue: true).toJson(),
    ],
    'onPageLoad': [
      {'type': 'updateAppState', 'name': 'counter', 'op': 'increment'},
      {'type': 'apiCall', 'apiCallId': 'api1', 'outputName': 'posts', 'variables': {'userId': app('counter')}},
      {'type': 'updatePageState', 'name': 'query', 'op': 'set', 'value': {'source': 'actionOutput', 'name': 'posts', 'path': r'$[0].title'}},
    ],
  }, children: [
    WidgetNode(type: 'SingleChildScrollView', children: [
      WidgetNode(type: 'Column', children: [
        WidgetNode(type: 'Text', properties: {
          'text': 'fallback',
          'bindings': {'text': app('username'), 'color': app('accent')},
          'animation': {'type': 'slideUp', 'durationMs': 500, 'delayMs': 100},
          'semanticLabel': "User's name",
        }),
        WidgetNode(type: 'Text', properties: {'text': 'x', 'bindings': {'text': {'source': 'translation', 'key': 'quote'}}}),
        WidgetNode(type: 'Text', properties: {'text': 'x', 'bindings': {'text': {'source': 'function', 'name': 'formatPrice', 'args': {'amount': app('ratio')}}}}),
        WidgetNode(type: 'Text', properties: {'text': 'x', 'bindings': {'text': {'source': 'env', 'name': 'apiBase'}}}),
        WidgetNode(type: 'Text', properties: {'text': 'x', 'bindings': {'text': {'source': 'authUser', 'field': 'email'}}}),
        WidgetNode(type: 'Text', properties: {'text': 'x', 'bindings': {'text': app('tags')}}),
        WidgetNode(type: 'Text', properties: {'text': 'x', 'bindings': {'text': {'source': 'widgetState', 'widgetId': 'emailField', 'widgetType': 'TextField'}}}),
        WidgetNode(type: 'Container', properties: {
          'width': 100.0,
          'height': 40.0,
          'color': '0xFFFF0000',
          'bindings': {'width': app('ratio'), 'color': app('counter')},
          'visibility': {
            'condition': {
              'combine': 'and',
              'conditions': [
                {'left': app('isPro'), 'op': 'isTrue'},
                {'left': app('counter'), 'op': '>=', 'right': lit('3')},
                {'left': page('selected'), 'op': 'contains', 'right': lit('a')},
                {'left': {'source': 'screenWidth'}, 'op': '>', 'right': lit(300)},
              ],
            },
            'hideOn': ['desktop'],
          },
        }),
        WidgetNode(type: 'Image', properties: {'src': 'https://x.dev/a.png', 'bindings': {'src': app('username')}, 'visibility': {'hideOn': ['phone', 'tablet']}}),
        WidgetNode(id: 'emailField', type: 'TextField', properties: {'hintText': 'Email'}),
        WidgetNode(id: 'passwordField', type: 'TextField', properties: {'hintText': 'Password', 'obscureText': true}),
        WidgetNode(id: 'agree', type: 'Checkbox', properties: {'value': false}),
        WidgetNode(type: 'Container', properties: {
          'onLongPress': [
            {'type': 'haptic', 'style': 'heavy'}
          ],
          'onDoubleTap': [
            {'type': 'toggleThemeMode'}
          ],
          'actions': [
            {'type': 'copyToClipboard', 'text': lit("it's \$1")}
          ],
        }, children: [WidgetNode(type: 'Text', properties: {'text': 'Gestures'})]),
        button('State', [
          {'type': 'updateAppState', 'name': 'counter', 'op': 'set', 'value': lit('7')},
          {'type': 'updateAppState', 'name': 'counter', 'op': 'decrement', 'value': page('tab')},
          {'type': 'updateAppState', 'name': 'ratio', 'op': 'increment', 'value': lit(0.5)},
          {'type': 'updateAppState', 'name': 'isPro', 'op': 'toggle'},
          {'type': 'updateAppState', 'name': 'username', 'op': 'set', 'value': {'source': 'widgetState', 'widgetId': 'emailField', 'widgetType': 'TextField'}},
          {'type': 'updateAppState', 'name': 'username', 'op': 'set', 'value': app('counter')},
          {'type': 'updateAppState', 'name': 'tags', 'op': 'add', 'value': lit('new')},
          {'type': 'updateAppState', 'name': 'tags', 'op': 'remove', 'value': lit('old')},
          {'type': 'updateAppState', 'name': 'scores', 'op': 'clear'},
          {'type': 'updateAppState', 'name': 'accent', 'op': 'set', 'value': lit('#22C55E')},
          {'type': 'updateAppState', 'name': 'status', 'op': 'set', 'value': lit('shipped')},
          {'type': 'updateAppState', 'name': 'isPro', 'op': 'set', 'value': {'source': 'widgetState', 'widgetId': 'agree', 'widgetType': 'Checkbox'}},
          {'type': 'updatePageState', 'name': 'tab', 'op': 'increment'},
          {'type': 'updatePageState', 'name': 'showDetails', 'op': 'toggle'},
          {'type': 'updatePageState', 'name': 'selected', 'op': 'add', 'value': lit('a')},
          {'type': 'updateAppState', 'name': 'missing', 'op': 'set'},
        ]),
        button('Feedback', [
          {'type': 'showSnackbar', 'message': app('username'), 'durationMs': 1500},
          {'type': 'showDialog', 'title': lit("Hi 'there'"), 'message': app('counter'), 'confirmText': 'Got it'},
          {
            'type': 'confirmDialog',
            'title': lit('Delete?'),
            'message': lit('Sure?'),
            'then': [
              {'type': 'showBottomSheet', 'message': lit('Deleted')}
            ],
            'else': [
              {'type': 'terminate'}
            ],
          },
          {'type': 'haptic', 'style': 'selection'},
          {'type': 'wait', 'ms': 300},
          {'type': 'launchUrl', 'url': {'source': 'env', 'name': 'apiBase'}},
          {'type': 'setLanguage', 'language': 'es'},
          {'type': 'openDrawer'},
          {'type': 'customAction', 'name': 'logEvent', 'args': {'name': lit('tap')}},
          {'type': 'customAction', 'name': 'fetchTotal'},
        ]),
        button('Logic', [
          {
            'type': 'conditional',
            'condition': {'left': app('counter'), 'op': '==', 'right': lit('5')},
            'then': [
              {'type': 'navigate', 'targetScreenId': 'details', 'params': {'productId': app('counter'), 'title': lit('Five'), 'price': lit('9.5')}}
            ],
            'else': [
              {
                'type': 'conditional',
                'condition': {'combine': 'or', 'conditions': [
                  {'left': app('username'), 'op': 'isEmpty'},
                  {'left': app('payload'), 'op': '!=', 'right': lit('x')},
                ]},
                'then': [
                  {'type': 'navigate', 'targetScreenId': 'details', 'replace': 'yes'}
                ],
              }
            ],
          },
          {
            'type': 'apiCall',
            'apiCallId': 'api2',
            'variables': {'title': page('query')},
            'then': [
              {'type': 'showSnackbar', 'message': {'source': 'actionOutput', 'name': 'createPostResponse', 'path': r'$.id'}}
            ],
            'else': [
              {'type': 'showSnackbar', 'message': lit('Failed')}
            ],
          },
          {'type': 'navigateBack'},
        ]),
        button('Backend', [
          {'type': 'supabase_insert', 'tableName': 'products', 'payload': {
            'name': {'type': 'widget_state', 'value': 'emailField'},
            'price': {'type': 'static', 'value': '10'},
            'owner': {'type': 'query_data', 'value': 'id'},
            'note': app('username'),
          }},
          {'type': 'supabase_update', 'tableName': 'products', 'payload': {'name': {'type': 'static', 'value': "it's"}}},
          {'type': 'supabase_delete', 'tableName': 'products'},
          {'type': 'supabase_rpc', 'functionName': 'increment', 'params': {'amount': lit(1)}, 'outputName': 'rpcOut'},
          {'type': 'uploadFile', 'bucket': 'avatars', 'outputName': 'avatarUrl'},
          {'type': 'updateAppState', 'name': 'username', 'op': 'set', 'value': {'source': 'actionOutput', 'name': 'avatarUrl'}},
        ]),
        WidgetNode(type: 'ListView', properties: {
          'apiQuery': {'apiCallId': 'api1', 'listPath': r'$', 'variables': {'userId': lit(2)}},
        }, children: [
          WidgetNode(type: 'Text', properties: {'text': 'x', 'bindings': {'text': {'source': 'queryField', 'field': 'title'}}}),
        ]),
        WidgetNode(type: 'ListView', properties: {
          'backendQuery': {'queryId': 'q1'},
        }, children: [
          WidgetNode(type: 'ListTile', properties: {
            'title': WidgetNode(type: 'Text', properties: {'text': 'x', 'bindings': {'text': {'source': 'queryField', 'field': 'name'}}}),
            'actions': [
              {'type': 'navigate', 'targetScreenId': 'details', 'params': {'title': {'source': 'queryField', 'field': 'name'}}},
              {'type': 'supabase_delete', 'tableName': 'products'},
            ],
          }),
        ]),
        WidgetNode(type: 'CustomWidget', properties: {'name': 'PriceTag', 'width': 120.0, 'height': 40.0, 'args': {'label': app('username')}}),
        WidgetNode(type: 'ComponentInstance', properties: {
          'componentId': 'productCard',
          'args': {
            'title': app('username'),
            'price': app('counter'),
            'onAdd': [
              {'type': 'updateAppState', 'name': 'counter', 'op': 'increment'},
            ],
          },
        }),
        WidgetNode(type: 'ListView', properties: {
          'apiQuery': {'apiCallId': 'api1', 'listPath': r'$'},
        }, children: [
          WidgetNode(type: 'ComponentInstance', properties: {
            'componentId': 'productCard',
            'args': {
              'title': {'source': 'queryField', 'field': 'title'},
              'onOpen': [
                {'type': 'navigate', 'targetScreenId': 'details', 'params': {'productId': {'source': 'queryField', 'field': 'id'}}},
              ],
            },
          }),
        ]),
      ]),
    ]),
  ]);

  final productCard = WidgetNode(id: 'productCard', type: 'Card', properties: {
    'componentName': 'Product Card',
    'pageParams': [
      FieldDef(name: 'title', required: true).toJson(),
      FieldDef(name: 'price', type: VarTypes.decimal, defaultValue: 9.99).toJson(),
      FieldDef(name: 'onAdd', type: VarTypes.action).toJson(),
      FieldDef(name: 'onOpen', type: VarTypes.action, required: true).toJson(),
    ],
    'pageState': [FieldDef(name: 'liked', type: VarTypes.boolean).toJson()],
  }, children: [
    WidgetNode(type: 'Column', children: [
      WidgetNode(type: 'Text', properties: {'text': 'x', 'bindings': {'text': param('title')}}),
      WidgetNode(type: 'Text', properties: {'text': 'x', 'bindings': {'text': {'source': 'function', 'name': 'formatPrice', 'args': {'amount': param('price')}}}}),
      button('Add', [
        {'type': 'updatePageState', 'name': 'liked', 'op': 'toggle'},
        {'type': 'callParameterAction', 'name': 'onAdd'},
        {'type': 'callParameterAction', 'name': 'onOpen'},
      ]),
    ]),
  ]);

  final details = WidgetNode(id: 'details', type: 'Scaffold', properties: {
    'pageName': 'Product Details',
    'pageParams': [
      FieldDef(name: 'productId', type: VarTypes.integer, required: true).toJson(),
      FieldDef(name: 'title', type: VarTypes.string).toJson(),
      FieldDef(name: 'price', type: VarTypes.decimal).toJson(),
      FieldDef(name: 'item', type: 'DataType:CartItem').toJson(),
    ],
  }, children: [
    WidgetNode(type: 'Column', children: [
      WidgetNode(type: 'Text', properties: {'text': 'x', 'bindings': {'text': param('title')}}),
      WidgetNode(type: 'Text', properties: {'text': 'x', 'bindings': {'text': param('productId'), 'fontSize': param('price')}}),
      button('Buy', [
        {'type': 'updateAppState', 'name': 'counter', 'op': 'set', 'value': param('productId')},
        {'type': 'updateAppState', 'name': 'ratio', 'op': 'set', 'value': param('price')},
        {'type': 'authSignOut'},
      ]),
    ]),
  ]);

  final login = WidgetNode(id: 'login', type: 'Scaffold', properties: {'pageName': 'Login'}, children: [
    WidgetNode(type: 'Column', children: [
      WidgetNode(id: 'loginEmail', type: 'TextField', properties: {'hintText': 'Email'}),
      WidgetNode(id: 'loginPassword', type: 'TextField', properties: {'hintText': 'Password'}),
      button('Sign in', [
        {
          'type': 'authSignIn',
          'email': {'source': 'widgetState', 'widgetId': 'loginEmail', 'widgetType': 'TextField'},
          'password': {'source': 'widgetState', 'widgetId': 'loginPassword', 'widgetType': 'TextField'},
          'then': [
            {'type': 'navigate', 'targetScreenId': 'home', 'replace': 'yes'}
          ],
        }
      ]),
      button('Sign up', [
        {'type': 'authSignUp', 'email': lit('a@b.co'), 'password': lit('secret1'), 'else': [{'type': 'showSnackbar', 'message': lit('Nope')}]},
        {'type': 'authResetPassword', 'email': lit('a@b.co')},
      ]),
    ]),
  ]);

  test('logic fixture export', () {
    final connection = SupabaseConnection(
      id: 'c1',
      projectUrl: 'https://example.supabase.co',
      anonKey: 'anon',
      name: 'Test',
      createdAt: DateTime(2026),
      isConnected: true,
      tables: [SupabaseTable(name: 'products', columns: [])],
    );
    final files = ProjectGenerator.generateFullProject(
      [home, details, login],
      {},
      [],
      appName: "Logic Fixture's App",
      connection: connection,
      queries: [BackendQuery(id: 'q1', name: 'Fetch Products', tableName: 'products')],
      logic: logic,
      components: [productCard],
    );

    expect(files.keys, containsAll([
      'lib/app_state.dart',
      'lib/backend/api_calls.dart',
      'lib/backend/schema/data_types.dart',
      'lib/custom_code/custom_functions.dart',
      'lib/custom_code/custom_actions.dart',
      'lib/custom_code/widgets/price_tag.dart',
      'lib/env.dart',
      'lib/auth_gate.dart',
      'lib/l10n/translations.dart',
      'lib/synapp/synapp_widgets.dart',
      'lib/components/product_card_component.dart',
    ]));
    expect(files['lib/home_screen.dart'], contains('AppState.instance.counter'));
    expect(files['lib/home_screen.dart'], isNot(contains('// Unknown widget type')));

    final exportDir = Platform.environment['EXPORT_DIR'];
    if (exportDir != null) {
      files.forEach((path, content) {
        final out = File('$exportDir/logic_fixture/$path');
        out.parent.createSync(recursive: true);
        out.writeAsStringSync(content);
      });
    }
  });
}
