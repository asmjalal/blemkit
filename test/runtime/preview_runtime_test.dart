import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:designflutterkit/models/project_logic.dart';
import 'package:designflutterkit/models/widget_node.dart';
import 'package:designflutterkit/providers/widget_tree_provider.dart';
import 'package:designflutterkit/widgets/canvas_preview/builders/widget_builder_factory.dart';
import 'package:designflutterkit/widgets/canvas_preview/canvas_preview_mode.dart';

/// Test mode on the canvas: actions, bindings, visibility and navigation run
/// against preview state the same way the exported app would.
void main() {
  setUpAll(WidgetBuilderFactory.initialize);

  Future<void> pumpCanvas(WidgetTester tester, WidgetTreeProvider provider) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: Scaffold(
            body: CanvasPreviewMode(
              isLivePreview: true,
              child: Consumer<WidgetTreeProvider>(
                builder: (context, p, _) => WidgetBuilderFactory.buildWidget(context, p.rootNode!, null),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('button increments app state and a bound Text shows it', (tester) async {
    final provider = WidgetTreeProvider();
    provider.logic.appState.add(FieldDef(name: 'count', type: VarTypes.integer, defaultValue: 0));
    provider.setProject([
      WidgetNode(id: 'home', type: 'Scaffold', properties: {'pageName': 'Home'}, children: [
        WidgetNode(type: 'Column', children: [
          WidgetNode(type: 'Text', properties: {
            'text': 'x',
            'bindings': {'text': {'source': 'appState', 'name': 'count'}},
          }),
          WidgetNode(type: 'ElevatedButton', properties: {
            'text': 'Add',
            'actions': [
              {'type': 'updateAppState', 'name': 'count', 'op': 'increment'},
            ],
          }),
        ]),
      ]),
    ]);

    await pumpCanvas(tester, provider);
    expect(find.text('0'), findsOneWidget);

    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('conditional visibility follows page state', (tester) async {
    final provider = WidgetTreeProvider();
    provider.setProject([
      WidgetNode(id: 'home', type: 'Scaffold', properties: {
        'pageName': 'Home',
        'pageState': [FieldDef(name: 'open', type: VarTypes.boolean).toJson()],
      }, children: [
        WidgetNode(type: 'Column', children: [
          WidgetNode(type: 'Text', properties: {
            'text': 'Secret',
            'visibility': {'condition': {'left': {'source': 'pageState', 'name': 'open'}, 'op': 'isTrue'}},
          }),
          WidgetNode(type: 'ElevatedButton', properties: {
            'text': 'Toggle',
            'actions': [
              {'type': 'updatePageState', 'name': 'open', 'op': 'toggle'},
            ],
          }),
        ]),
      ]),
    ]);

    await pumpCanvas(tester, provider);
    expect(find.text('Secret'), findsNothing);
    await tester.tap(find.text('Toggle'));
    await tester.pumpAndSettle();
    expect(find.text('Secret'), findsOneWidget);
  });

  testWidgets('navigate passes typed parameters and back returns', (tester) async {
    final provider = WidgetTreeProvider();
    provider.setProject([
      WidgetNode(id: 'list', type: 'Scaffold', properties: {'pageName': 'List'}, children: [
        WidgetNode(type: 'ElevatedButton', properties: {
          'text': 'Open',
          'actions': [
            {
              'type': 'navigate',
              'targetScreenId': 'detail',
              'params': {'title': {'source': 'literal', 'value': 'Pizza'}},
            },
          ],
        }),
      ]),
      WidgetNode(id: 'detail', type: 'Scaffold', properties: {
        'pageName': 'Detail',
        'pageParams': [FieldDef(name: 'title').toJson()],
      }, children: [
        WidgetNode(type: 'Column', children: [
          WidgetNode(type: 'Text', properties: {'text': 'x', 'bindings': {'text': {'source': 'pageParam', 'name': 'title'}}}),
          WidgetNode(type: 'ElevatedButton', properties: {'text': 'Back', 'actions': [{'type': 'navigateBack'}]}),
        ]),
      ]),
    ]);

    await pumpCanvas(tester, provider);
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(provider.selectedScreen?.id, 'detail');
    expect(find.text('Pizza'), findsOneWidget);

    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(provider.selectedScreen?.id, 'list');
  });

  testWidgets('if/else runs the matching branch', (tester) async {
    final provider = WidgetTreeProvider();
    provider.logic.appState.addAll([
      FieldDef(name: 'score', type: VarTypes.integer, defaultValue: 7),
      FieldDef(name: 'result', defaultValue: ''),
    ]);
    provider.setProject([
      WidgetNode(id: 'home', type: 'Scaffold', properties: {'pageName': 'Home'}, children: [
        WidgetNode(type: 'Column', children: [
          WidgetNode(type: 'Text', properties: {'text': 'x', 'bindings': {'text': {'source': 'appState', 'name': 'result'}}}),
          WidgetNode(type: 'ElevatedButton', properties: {
            'text': 'Check',
            'actions': [
              {
                'type': 'conditional',
                'condition': {'left': {'source': 'appState', 'name': 'score'}, 'op': '>=', 'right': {'source': 'literal', 'value': '5'}},
                'then': [
                  {'type': 'updateAppState', 'name': 'result', 'op': 'set', 'value': {'source': 'literal', 'value': 'pass'}},
                ],
                'else': [
                  {'type': 'updateAppState', 'name': 'result', 'op': 'set', 'value': {'source': 'literal', 'value': 'fail'}},
                ],
              },
            ],
          }),
        ]),
      ]),
    ]);

    await pumpCanvas(tester, provider);
    await tester.tap(find.text('Check'));
    await tester.pumpAndSettle();
    expect(find.text('pass'), findsOneWidget);
  });

  testWidgets('component instance renders its argument and runs its callback', (tester) async {
    final provider = WidgetTreeProvider();
    provider.logic.appState.add(FieldDef(name: 'taps', type: VarTypes.integer));
    provider.components.add(WidgetNode(id: 'card', type: 'Column', properties: {
      'componentName': 'Card',
      'pageParams': [
        FieldDef(name: 'title').toJson(),
        FieldDef(name: 'onTap', type: VarTypes.action).toJson(),
      ],
    }, children: [
      WidgetNode(type: 'Text', properties: {'text': 'x', 'bindings': {'text': {'source': 'pageParam', 'name': 'title'}}}),
      WidgetNode(type: 'ElevatedButton', properties: {
        'text': 'Tap card',
        'actions': [
          {'type': 'callParameterAction', 'name': 'onTap'},
        ],
      }),
    ]));
    provider.setProject([
      WidgetNode(id: 'home', type: 'Scaffold', properties: {'pageName': 'Home'}, children: [
        WidgetNode(type: 'Column', children: [
          WidgetNode(type: 'Text', properties: {'text': 'x', 'bindings': {'text': {'source': 'appState', 'name': 'taps'}}}),
          WidgetNode(type: 'ComponentInstance', properties: {
            'componentId': 'card',
            'args': {
              'title': {'source': 'literal', 'value': 'Margherita'},
              'onTap': [
                {'type': 'updateAppState', 'name': 'taps', 'op': 'increment'},
              ],
            },
          }),
        ]),
      ]),
    ]);

    await pumpCanvas(tester, provider);
    expect(find.text('Margherita'), findsOneWidget);
    await tester.tap(find.text('Tap card'));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);
  });
}
