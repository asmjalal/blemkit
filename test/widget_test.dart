import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:designflutterkit/models/widget_node.dart';
import 'package:designflutterkit/providers/widget_tree_provider.dart';
import 'package:designflutterkit/widgets/canvas_preview/builders/widget_builder_factory.dart';

void main() {
  setUpAll(WidgetBuilderFactory.initialize);

  testWidgets('canvas renders a simple screen', (tester) async {
    final provider = WidgetTreeProvider();
    final screen = WidgetNode(type: 'Scaffold', children: [
      WidgetNode(type: 'Center', children: [
        WidgetNode(type: 'Text', properties: {'text': 'Hello SynappKit'}),
      ]),
    ]);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: Builder(builder: (context) => WidgetBuilderFactory.buildWidget(context, screen, null)),
        ),
      ),
    );

    expect(find.text('Hello SynappKit'), findsOneWidget);
  });
}
