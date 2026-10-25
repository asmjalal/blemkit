import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/widget_node.dart';
import '../../../providers/widget_tree_provider.dart';
import '../../../runtime/exported/synapp_widgets.dart';
import '../../../runtime/preview_runtime.dart';
import '../canvas_preview_mode.dart';
import 'base_widget_builder.dart';
import 'widget_builder_factory.dart';

/// Canvas builders for widgets backed by the SynappKit runtime library. They
/// render the same classes the exported app uses; input values are stored as
/// preview widget state so actions and bindings can read them.
abstract class _SynappBuilder extends BaseWidgetBuilder {
  List<String> options(dynamic raw, List<String> fallback) {
    if (raw is List) return raw.map((e) => e is Map ? '${e['value'] ?? e['label'] ?? ''}' : e.toString()).toList();
    if (raw is String && raw.trim().isNotEmpty) return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return fallback;
  }

  double number(dynamic raw, double fallback) => parseDouble(raw) ?? fallback;

  void Function(T) changed<T>(BuildContext context, WidgetNode node) => (T value) {
        final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
        provider.setWidgetState(node.id, value);
        if (CanvasPreviewMode.of(context)) PreviewRuntime.run(context, node.properties['onChanged'] as List?);
      };

  Widget child(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) => node.children.isEmpty
      ? const SizedBox(height: 40, child: Center(child: Text('Add a child', style: TextStyle(color: Colors.black38))))
      : WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode);
}

class RatingBarBuilder extends _SynappBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) => SynappRatingBar(
        rating: number(node.properties['rating'], 3),
        itemCount: number(node.properties['itemCount'], 5).toInt(),
        itemSize: number(node.properties['itemSize'], 28),
        color: parseColor(node.properties['color'], context) ?? const Color(0xFFFFB300),
        allowHalf: node.properties['allowHalf'] == true,
        onChanged: changed<double>(context, node),
      );
}

class PinCodeBuilder extends _SynappBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) => SynappPinCode(
        length: number(node.properties['length'], 4).toInt(),
        obscureText: node.properties['obscureText'] == true,
        boxSize: number(node.properties['boxSize'], 52),
        activeColor: parseColor(node.properties['activeColor'], context) ?? const Color(0xFF4F46E5),
        onChanged: changed<String>(context, node),
      );
}

class CounterButtonBuilder extends _SynappBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) => Align(
        alignment: Alignment.centerLeft,
        child: SynappCounter(
          value: number(node.properties['value'], 1).toInt(),
          min: number(node.properties['min'], 0).toInt(),
          max: number(node.properties['max'], 99).toInt(),
          color: parseColor(node.properties['color'], context) ?? const Color(0xFF4F46E5),
          onChanged: changed<int>(context, node),
        ),
      );
}

class ChoiceChipsBuilder extends _SynappBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) => SynappChoiceChips(
        options: options(node.properties['options'], const ['Option A', 'Option B', 'Option C']),
        initiallySelected: options(node.properties['selected'], const []),
        multiSelect: node.properties['multiSelect'] == true,
        selectedColor: parseColor(node.properties['selectedColor'], context) ?? const Color(0xFF4F46E5),
        onChanged: changed<List<String>>(context, node),
      );
}

class CheckboxGroupBuilder extends _SynappBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) => SynappCheckboxGroup(
        options: options(node.properties['options'], const ['Option A', 'Option B', 'Option C']),
        initiallySelected: options(node.properties['selected'], const []),
        activeColor: parseColor(node.properties['activeColor'], context) ?? const Color(0xFF4F46E5),
        onChanged: changed<List<String>>(context, node),
      );
}

class RadioGroupBuilder extends _SynappBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) => SynappRadioGroup(
        options: options(node.properties['options'], const ['Option A', 'Option B']),
        initialValue: node.properties['value']?.toString(),
        horizontal: node.properties['horizontal'] == true,
        activeColor: parseColor(node.properties['activeColor'], context) ?? const Color(0xFF4F46E5),
        onChanged: changed<String?>(context, node),
      );
}

class SignatureBuilder extends _SynappBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) => SynappSignature(
        height: number(node.properties['height'], 160),
        penColor: parseColor(node.properties['penColor'], context) ?? const Color(0xFF0F172A),
        backgroundColor: parseColor(node.properties['backgroundColor'], context) ?? const Color(0xFFF8FAFC),
      );
}

class DataTableBuilder extends _SynappBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final raw = node.properties['rows'];
    final rows = <List<String>>[
      if (raw is List)
        for (final r in raw) r is List ? r.map((e) => '$e').toList() : '$r'.split(',').map((e) => e.trim()).toList()
      else if (raw is String)
        for (final line in raw.split('\n').where((l) => l.trim().isNotEmpty)) line.split(',').map((e) => e.trim()).toList()
    ];
    return SynappDataTable(
      columns: options(node.properties['columns'], const ['Name', 'Status']),
      rows: rows,
      headerColor: parseColor(node.properties['headerColor'], context) ?? const Color(0xFFF1F5F9),
    );
  }
}

class CreditCardFormBuilder extends _SynappBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) =>
      SynappCreditCardForm(cardColor: parseColor(node.properties['cardColor'], context) ?? const Color(0xFF312E81));
}

class SlidableListTileBuilder extends _SynappBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) => SynappSlidableTile(
        title: safeString(node.properties['title'], fallback: 'Slidable List Tile'),
        subtitle: safeString(node.properties['subtitle']),
        actionLabel: safeString(node.properties['actionLabel'], fallback: 'Delete'),
        actionColor: parseColor(node.properties['actionColor'], context) ?? const Color(0xFFEF4444),
        onAction: () {
          if (CanvasPreviewMode.of(context)) PreviewRuntime.run(context, node.properties['actions'] as List?);
        },
      );
}

class LoadingOverlayBuilder extends _SynappBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) => SynappLoadingOverlay(
        isLoading: node.properties['isLoading'] != false,
        child: child(context, node, hoveredNode),
      );
}

class PlacePickerBuilder extends _SynappBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) => SynappPlacePicker(
        hintText: safeString(node.properties['hintText'], fallback: 'Search address'),
        suggestions: options(node.properties['suggestions'], const []),
        onSelected: changed<String>(context, node),
      );
}

class PassThroughBuilder extends _SynappBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) => child(context, node, hoveredNode);
}

class AnimatedContainerBuilder extends _SynappBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) => AnimatedContainer(
        duration: Duration(milliseconds: number(node.properties['durationMs'], 300).toInt()),
        width: parseDouble(node.properties['width']),
        height: parseDouble(node.properties['height']),
        padding: parseEdgeInsets(node.properties['padding']),
        decoration: BoxDecoration(
          color: parseColor(node.properties['color'], context),
          borderRadius: BorderRadius.circular(number(node.properties['borderRadius'], 0)),
        ),
        child: node.children.isEmpty ? null : WidgetBuilderFactory.buildWidget(context, node.children.first, hoveredNode),
      );
}

class AnimatedOpacityBuilder extends _SynappBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) => AnimatedOpacity(
        opacity: number(node.properties['opacity'], 1).clamp(0, 1),
        duration: Duration(milliseconds: number(node.properties['durationMs'], 300).toInt()),
        child: child(context, node, hoveredNode),
      );
}

class FlexWidgetBuilder extends _SynappBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) => Flex(
        direction: parseAxis(node.properties['direction']) ?? Axis.horizontal,
        mainAxisAlignment: parseMainAxisAlignment(node.properties['mainAxisAlignment']),
        crossAxisAlignment: parseCrossAxisAlignment(node.properties['crossAxisAlignment']),
        children: node.children.map((c) => WidgetBuilderFactory.buildWidget(context, c, hoveredNode)).toList(),
      );
}

class DropdownBuilder extends _SynappBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final items = options(node.properties['items'], const ['Option 1', 'Option 2', 'Option 3']);
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    final current = provider.getWidgetState(node.id) ?? node.properties['value'];
    return DropdownButton<String>(
      value: items.contains(current) ? current as String : null,
      isExpanded: node.properties['isExpanded'] != false,
      hint: Text(safeString(node.properties['hint'], fallback: 'Select an option')),
      items: items.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
      onChanged: (value) {
        changed<String?>(context, node)(value);
        provider.previewChanged();
      },
    );
  }
}

/// Placeholder for a user-written custom widget (compiled only in the export).
class CustomWidgetBuilder extends _SynappBuilder {
  @override
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    return Container(
      width: parseDouble(node.properties['width']) ?? double.infinity,
      height: parseDouble(node.properties['height']) ?? 80,
      decoration: BoxDecoration(
        color: const Color(0x1A6366F1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0x806366F1)),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.code_rounded, size: 18, color: Color(0xFF6366F1)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              safeString(node.properties['name'], fallback: 'Custom widget'),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
