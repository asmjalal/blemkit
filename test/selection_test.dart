import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:designflutterkit/models/widget_node.dart';
import 'package:designflutterkit/providers/widget_tree_provider.dart';
import 'package:designflutterkit/widgets/canvas_preview/builders/widget_builder_factory.dart';
import 'package:designflutterkit/widgets/canvas_preview/selection_wrapper.dart';

void main() {
  setUpAll(() {
    WidgetBuilderFactory.initialize();
  });

  testWidgets('WidgetBuilderFactory wraps widgets with WidgetSelectionWrapper', (WidgetTester tester) async {
    final provider = WidgetTreeProvider();
    final node = WidgetNode(type: 'Text', properties: {'text': 'Hello'});

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: provider,
          child: Scaffold(
            body: WidgetBuilderFactory.buildWidget(null as dynamic, node, null),
          ),
        ),
      ),
    );

    // Verify that WidgetSelectionWrapper is present
    expect(find.byType(WidgetSelectionWrapper), findsOneWidget);
    expect(find.text('Hello'), findsOneWidget);
  });

  testWidgets('WidgetBuilderFactory DOES NOT wrap Expanded with WidgetSelectionWrapper', (WidgetTester tester) async {
    final provider = WidgetTreeProvider();
    final node = WidgetNode(type: 'Expanded', children: [
      WidgetNode(type: 'Text', properties: {'text': 'Inside Expanded'})
    ]);

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: provider,
          child: Scaffold(
            body: Column(
              children: [
                WidgetBuilderFactory.buildWidget(null as dynamic, node, null),
              ],
            ),
          ),
        ),
      ),
    );

    // Verify that Expanded is present but NOT wrapped directly
    expect(find.byType(Expanded), findsOneWidget);
    // The child of Expanded (the Text) SHOULD be wrapped though!
    expect(find.byType(WidgetSelectionWrapper), findsOneWidget);
    expect(find.text('Inside Expanded'), findsOneWidget);
  });
}
