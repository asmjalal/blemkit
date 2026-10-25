import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import '../selection_wrapper.dart';
import '../selection_preferred_size_wrapper.dart';
import '../canvas_preview_mode.dart';
import 'base_widget_builder.dart';
import 'supabase_query_wrapper_builder.dart';
import '../../../providers/widget_tree_provider.dart';
import 'package:provider/provider.dart';
import 'scaffold_builder.dart' as wb;
import 'container_builder.dart' as wb;
import 'text_builder.dart' as wb;
import 'single_child_scroll_view_builder.dart' as wb;
import 'rich_text_builder.dart' as wb;
import 'image_builder.dart' as wb;
import 'icon_builder.dart' as wb;
import 'button_builder.dart' as wb;
import 'icon_button_builder.dart' as wb;
import 'list_tile_builder.dart' as wb;
import 'expanded_builder.dart' as wb;
import 'sized_box_builder.dart' as wb;
import 'padding_builder.dart' as wb;
import 'center_builder.dart' as wb;
import 'align_builder.dart' as wb;
import 'stack_builder.dart' as wb;
import 'positioned_builder.dart' as wb;
import 'gesture_detector_builder.dart' as wb;
import 'ink_well_builder.dart' as wb;
import 'elevated_button_builder.dart' as wb;
import 'text_button_builder.dart' as wb;
import 'outlined_button_builder.dart' as wb;
import 'material_button_builder.dart' as wb;
import 'popup_menu_button_builder.dart' as wb;
import 'checkbox_builder.dart' as wb;
import 'radio_builder.dart' as wb;
import 'switch_builder.dart' as wb;
import 'slider_builder.dart' as wb;
import 'form_builder.dart' as wb;
import 'form_field_builder.dart' as wb;
import 'checkbox_list_tile_builder.dart' as wb;
import 'switch_list_tile_builder.dart' as wb;
import 'radio_list_tile_builder.dart' as wb;
import 'navigator_builder.dart' as wb;
import 'material_page_route_builder.dart' as wb;
import 'page_view_builder.dart' as wb;
import 'bottom_navigation_bar_builder.dart' as wb;
import 'tab_bar_builder.dart' as wb;
import 'tab_bar_view_builder.dart' as wb;
import 'custom_scroll_view_builder.dart' as wb;
import 'reorderable_list_view_builder.dart' as wb;
import 'future_builder_builder.dart' as wb;
import 'stream_builder_builder.dart' as wb;
import 'layout_builder_builder.dart' as wb;
import 'media_query_builder.dart' as wb;
import 'orientation_builder_builder.dart' as wb;
import 'app_bar_builder.dart' as wb;
import 'bottom_app_bar_builder.dart' as wb;
import 'card_builder.dart' as wb;
import 'snack_bar_builder.dart' as wb;
import 'animated_builder_builder.dart' as wb;
import 'alert_dialog_builder.dart' as wb;
import 'bottom_sheet_builder.dart' as wb;
import 'chip_builder.dart' as wb;
import 'circle_avatar_builder.dart' as wb;
import 'tooltip_builder.dart' as wb;
import 'divider_builder.dart' as wb;
import 'expansion_tile_builder.dart' as wb;
import 'row_builder.dart' as wb;
import 'column_builder.dart' as wb;
import 'flexible_builder.dart' as wb;
import 'wrap_builder.dart' as wb;
import 'fitted_box_builder.dart' as wb;
import 'spacer_builder.dart' as wb;
import 'floating_action_button_builder.dart' as wb;
import 'drawer_builder.dart' as wb;
import 'text_field_builder.dart' as wb;
import 'list_view_builder.dart' as wb;
import 'grid_view_builder.dart' as wb;
import 'themed_widget_builder.dart' as wb;
import 'vertical_divider_builder.dart' as wb;
import 'carousel_builder.dart' as wb;
import 'expandable_builder.dart' as wb;
import 'safe_area_builder.dart' as wb;
import 'aspect_ratio_builder.dart' as wb;
import 'svg_image_builder.dart' as wb;
import 'badge_builder.dart' as wb;
import 'avatar_builder.dart' as wb;
import 'selectable_text_builder.dart' as wb;
import 'constrained_box_builder.dart' as wb;
import 'intrinsic_height_builder.dart' as wb;
import 'intrinsic_width_builder.dart' as wb;
import 'clip_r_rect_builder.dart' as wb;
import 'date_picker_builder.dart' as wb;
import 'time_picker_builder.dart' as wb;
import 'range_slider_builder.dart' as wb;
import 'search_field_builder.dart' as wb;
import 'auto_complete_builder.dart' as wb;
import 'toggle_buttons_builder.dart' as wb;
import 'segmented_button_builder.dart' as wb;
import 'navigation_rail_builder.dart' as wb;
import 'circular_progress_indicator_builder.dart' as wb;
import 'linear_progress_indicator_builder.dart' as wb;
import 'synapp_widget_builders.dart' as sw;
import 'api_query_wrapper.dart';
import 'component_instance_builder.dart';
import '../../../runtime/preview_runtime.dart';
import '../../../runtime/exported/synapp_widgets.dart';

class WidgetBuilderFactory {
  static final WidgetBuilderFactory _instance = WidgetBuilderFactory._internal();
  factory WidgetBuilderFactory() {
    return _instance;
  }
  WidgetBuilderFactory._internal();

  static final Map<String, BaseWidgetBuilder> _builders = {};

  static void initialize() {
    print('WidgetBuilderFactory: Initializing builders...');
    _builders.clear(); // Clear existing builders to re-initialize
    final factoryInstance = WidgetBuilderFactory(); // Get the singleton instance

    // Register the bridge so BaseWidgetBuilder.safeWidget() can call back here
    WidgetBuilderFactoryRef.register(
      (ctx, node, hovered) => buildWidget(ctx, node, hovered),
    );

    _builders['Scaffold'] = wb.ScaffoldBuilder(factoryInstance);
    _builders['Container'] = wb.ContainerBuilder();
    _builders['Text'] = wb.TextBuilder();
    _builders['SingleChildScrollView'] = wb.SingleChildScrollViewBuilder();
    _builders['RichText'] = wb.RichTextBuilder();
    _builders['Image'] = wb.ImageBuilder();
    _builders['Icon'] = wb.IconBuilder();
    _builders['Button'] = wb.ButtonBuilder();
    _builders['IconButton'] = wb.IconButtonBuilder();
    _builders['ListTile'] = wb.ListTileBuilder();
    _builders['Expanded'] = wb.ExpandedBuilder();
    _builders['SizedBox'] = wb.SizedBoxBuilder();
    _builders['Padding'] = wb.PaddingBuilder();
    _builders['Center'] = wb.CenterBuilder();
    _builders['Align'] = wb.AlignBuilder();
    _builders['Stack'] = wb.StackBuilder();
    _builders['Positioned'] = wb.PositionedBuilder();
    _builders['GestureDetector'] = wb.GestureDetectorBuilder();
    _builders['InkWell'] = wb.InkWellBuilder();
    _builders['ElevatedButton'] = wb.ElevatedButtonBuilder();
    _builders['TextButton'] = wb.TextButtonBuilder();
    _builders['OutlinedButton'] = wb.OutlinedButtonBuilder();
    _builders['MaterialButton'] = wb.MaterialButtonBuilder();
    _builders['PopupMenuButton'] = wb.PopupMenuButtonBuilder();
    _builders['Checkbox'] = wb.CheckboxBuilder();
    _builders['Radio'] = wb.RadioBuilder();
    _builders['Switch'] = wb.SwitchBuilder();
    _builders['Slider'] = wb.SliderBuilder();
    _builders['Form'] = wb.FormBuilder();
    _builders['FormField'] = wb.FormFieldBuilder();
    _builders['CheckboxListTile'] = wb.CheckboxListTileBuilder();
    _builders['SwitchListTile'] = wb.SwitchListTileBuilder();
    _builders['RadioListTile'] = wb.RadioListTileBuilder();
    _builders['Navigator'] = wb.NavigatorBuilder();
    _builders['MaterialPageRoute'] = wb.MaterialPageRouteBuilder();
    _builders['PageView'] = wb.PageViewBuilder();
    _builders['BottomNavigationBar'] = wb.BottomNavigationBarBuilder();
    _builders['TabBar'] = wb.TabBarBuilder();
    _builders['TabBarView'] = wb.TabBarViewBuilder();
    _builders['CustomScrollView'] = wb.CustomScrollViewBuilder();
    _builders['ReorderableListView'] = wb.ReorderableListViewBuilder();
    _builders['FutureBuilder'] = wb.FutureBuilderBuilder();
    _builders['StreamBuilder'] = wb.StreamBuilderBuilder();
    _builders['LayoutBuilder'] = wb.LayoutBuilderBuilder();
    _builders['MediaQuery'] = wb.MediaQueryBuilder();
    _builders['OrientationBuilder'] = wb.OrientationBuilderBuilder();
    _builders['AppBar'] = wb.AppBarBuilder(factoryInstance);
    _builders['BottomAppBar'] = wb.BottomAppBarBuilder();
    _builders['Card'] = wb.CardBuilder();
    _builders['SnackBar'] = wb.SnackBarBuilder();
    _builders['AnimatedBuilder'] = wb.AnimatedBuilderBuilder();
    _builders['AlertDialog'] = wb.AlertDialogBuilder();
    _builders['BottomSheet'] = wb.BottomSheetBuilder();
    _builders['Chip'] = wb.ChipBuilder();
    _builders['CircleAvatar'] = wb.CircleAvatarBuilder();
    _builders['Tooltip'] = wb.TooltipBuilder();
    _builders['Divider'] = wb.DividerBuilder();
    _builders['ExpansionTile'] = wb.ExpansionTileBuilder();
    _builders['Row'] = wb.RowBuilder();
    _builders['Column'] = wb.ColumnBuilder();
    _builders['Flexible'] = wb.FlexibleBuilder();
    _builders['Wrap'] = wb.WrapBuilder();
    _builders['FittedBox'] = wb.FittedBoxBuilder();
    _builders['Spacer'] = wb.SpacerBuilder();
    _builders['FloatingActionButton'] = wb.FloatingActionButtonBuilder();
    _builders['Drawer'] = wb.DrawerBuilder();
    _builders['TextField'] = wb.TextFieldBuilder();
    _builders['ListView'] = wb.ListViewBuilder();
    _builders['GridView'] = wb.GridViewBuilder();
    _builders['ThemedWidget'] = wb.ThemedWidgetBuilder();
    _builders['VerticalDivider'] = wb.VerticalDividerBuilder();
    _builders['Carousel'] = wb.CarouselBuilder();
    _builders['Expandable'] = wb.ExpandableBuilder();
    _builders['SafeArea'] = wb.SafeAreaBuilder();
    _builders['AspectRatio'] = wb.AspectRatioBuilder();
    _builders['SvgImage'] = wb.SvgImageBuilder();
    _builders['Badge'] = wb.BadgeBuilder();
    _builders['Avatar'] = wb.AvatarBuilder();
    _builders['SelectableText'] = wb.SelectableTextBuilder();
    _builders['ConstrainedBox'] = wb.ConstrainedBoxBuilder();
    _builders['IntrinsicHeight'] = wb.IntrinsicHeightBuilder();
    _builders['IntrinsicWidth'] = wb.IntrinsicWidthBuilder();
    _builders['ClipRRect'] = wb.ClipRRectBuilder();
    _builders['DatePicker'] = wb.DatePickerBuilder();
    _builders['TimePicker'] = wb.TimePickerBuilder();
    _builders['RangeSlider'] = wb.RangeSliderBuilder();
    _builders['SearchField'] = wb.SearchFieldBuilder();
    _builders['AutoComplete'] = wb.AutoCompleteBuilder();
    _builders['ToggleButtons'] = wb.ToggleButtonsBuilder();
    _builders['SegmentedButton'] = wb.SegmentedButtonBuilder();
    _builders['NavigationRail'] = wb.NavigationRailBuilder();
    _builders['CircularProgressIndicator'] = wb.CircularProgressIndicatorBuilder();
    _builders['LinearProgressIndicator'] = wb.LinearProgressIndicatorBuilder();
    _builders['DropdownButton'] = sw.DropdownBuilder();
    _builders['DropDown'] = sw.DropdownBuilder();
    _builders['EndDrawer'] = wb.DrawerBuilder();
    _builders['RatingBar'] = sw.RatingBarBuilder();
    _builders['PinCode'] = sw.PinCodeBuilder();
    _builders['CounterButton'] = sw.CounterButtonBuilder();
    _builders['ChoiceChips'] = sw.ChoiceChipsBuilder();
    _builders['CheckboxGroup'] = sw.CheckboxGroupBuilder();
    _builders['RadioGroup'] = sw.RadioGroupBuilder();
    _builders['Signature'] = sw.SignatureBuilder();
    _builders['DataTable'] = sw.DataTableBuilder();
    _builders['CreditCardForm'] = sw.CreditCardFormBuilder();
    _builders['SlidableListTile'] = sw.SlidableListTileBuilder();
    _builders['LoadingOverlay'] = sw.LoadingOverlayBuilder();
    _builders['PlacePicker'] = sw.PlacePickerBuilder();
    _builders['Hero'] = sw.PassThroughBuilder();
    _builders['AnimatedSwitcher'] = sw.PassThroughBuilder();
    _builders['AnimatedContainer'] = sw.AnimatedContainerBuilder();
    _builders['AnimatedOpacity'] = sw.AnimatedOpacityBuilder();
    _builders['Flex'] = sw.FlexWidgetBuilder();
    _builders['CustomWidget'] = sw.CustomWidgetBuilder();
    _builders['ComponentInstance'] = ComponentInstanceBuilder();
    print('WidgetBuilderFactory: Initialization complete. Registered ${_builders.length} builders.');
  }

  static bool hasBuilder(String type) {
    if (_builders.isEmpty) initialize();
    return _builders.containsKey(type);
  }

  static Widget buildBaseWidget(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final builder = _builders[node.type];
    if (builder != null) {
      return builder.build(context, node, hoveredNode);
    }
    return Container(
      color: Colors.red.withOpacity(0.3),
      child: Center(child: Text('Unknown: ${node.type}')),
    );
  }

  static WidgetNode _resolveBoundProperties(BuildContext context, WidgetNode node) {
    final bindings = node.properties['bindings'];
    if (bindings is Map && bindings.isNotEmpty) {
      node = WidgetNode(
        id: node.id,
        type: node.type,
        children: node.children,
        properties: PreviewRuntime.applyBindings(context, node, node.properties),
      );
    }
    if (node.dataBinding == null || node.dataBinding!.isEmpty) {
      return node;
    }

    final resolvedProps = Map<String, dynamic>.from(node.properties);
    final rowData = SupabaseRowDataContext.of(context);

    node.dataBinding!.forEach((propKey, bindingVal) {
      if (bindingVal is Map) {
        final field = bindingVal['field'] as String?;
        final queryId = bindingVal['queryId'] as String?;
        if (field == null || field.isEmpty) return;

        if (rowData != null && rowData.containsKey(field)) {
          resolvedProps[propKey] = rowData[field]?.toString();
        } else if (queryId != null) {
          final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
          final results = provider.queryResults[queryId];
          if (results != null && results.isNotEmpty) {
            final rowIndex = bindingVal['rowIndex'] as int? ?? 0;
            if (rowIndex < results.length) {
              final rowVal = results[rowIndex][field];
              resolvedProps[propKey] = rowVal?.toString();
            }
          }
        }
      }
    });

    return WidgetNode(
      id: node.id,
      type: node.type,
      children: node.children,
      properties: resolvedProps,
    );
  }

  static Axis? _parseAxis(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      if (value == 'Axis.horizontal' || value == 'horizontal') return Axis.horizontal;
      if (value == 'Axis.vertical' || value == 'vertical') return Axis.vertical;
    }
    return null;
  }

  static EdgeInsets? _parseEdgeInsets(dynamic value) {
    if (value == null) return null;
    if (value is num) return EdgeInsets.all(value.toDouble());
    if (value is Map) {
      return EdgeInsets.only(
        left: (value['left'] as num?)?.toDouble() ?? 0.0,
        top: (value['top'] as num?)?.toDouble() ?? 0.0,
        right: (value['right'] as num?)?.toDouble() ?? 0.0,
        bottom: (value['bottom'] as num?)?.toDouble() ?? 0.0,
      );
    }
    return null;
  }

  static MainAxisAlignment? _parseMainAxisAlignment(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      switch (value) {
        case 'MainAxisAlignment.start': return MainAxisAlignment.start;
        case 'MainAxisAlignment.end': return MainAxisAlignment.end;
        case 'MainAxisAlignment.center': return MainAxisAlignment.center;
        case 'MainAxisAlignment.spaceBetween': return MainAxisAlignment.spaceBetween;
        case 'MainAxisAlignment.spaceAround': return MainAxisAlignment.spaceAround;
        case 'MainAxisAlignment.spaceEvenly': return MainAxisAlignment.spaceEvenly;
      }
    }
    return null;
  }

  static CrossAxisAlignment? _parseCrossAxisAlignment(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      switch (value) {
        case 'CrossAxisAlignment.start': return CrossAxisAlignment.start;
        case 'CrossAxisAlignment.end': return CrossAxisAlignment.end;
        case 'CrossAxisAlignment.center': return CrossAxisAlignment.center;
        case 'CrossAxisAlignment.stretch': return CrossAxisAlignment.stretch;
        case 'CrossAxisAlignment.baseline': return CrossAxisAlignment.baseline;
      }
    }
    return null;
  }

  static Widget buildWidget(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    if (_builders.isEmpty) initialize();

    final resolvedNode = _resolveBoundProperties(context, node);

    if (!PreviewRuntime.isVisible(context, resolvedNode)) {
      if (CanvasPreviewMode.of(context)) return const SizedBox.shrink();
      // Keep hidden widgets selectable while editing.
      return Opacity(opacity: 0.3, child: _buildVisible(context, resolvedNode, hoveredNode));
    }
    return _buildVisible(context, resolvedNode, hoveredNode);
  }

  static Widget _buildVisible(BuildContext context, WidgetNode resolvedNode, WidgetNode? hoveredNode) {
    final apiQuery = resolvedNode.properties['apiQuery'];
    if (apiQuery is Map && apiQuery['apiCallId'] != null) {
      return ApiQueryWrapper(
        node: resolvedNode,
        builder: (context, rows) {
          if (['ListView', 'GridView'].contains(resolvedNode.type) && resolvedNode.children.isNotEmpty) {
            final template = resolvedNode.children.first;
            final items = rows
                .map((row) => SupabaseRowDataContext(
                      rowData: row,
                      child: Builder(builder: (c) => buildWidget(c, template, hoveredNode)),
                    ))
                .toList();
            final list = resolvedNode.type == 'ListView'
                ? ListView(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), children: items)
                : GridView.count(
                    crossAxisCount: (resolvedNode.properties['crossAxisCount'] as num?)?.toInt() ?? 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: items,
                  );
            return WidgetSelectionWrapper(node: resolvedNode, hoveredNode: hoveredNode, child: list);
          }
          return SupabaseRowDataContext(
            rowData: rows.isNotEmpty ? rows.first : const {},
            child: _buildInnerWidget(context, resolvedNode, hoveredNode),
          );
        },
      );
    }

    if (resolvedNode.backendQuery != null) {
      return SupabaseQueryWrapper(
        node: resolvedNode,
        hoveredNode: hoveredNode,
        builder: (context, data) {
          final rowData = data.isNotEmpty ? data.first : <String, dynamic>{};

          // ListView and GridView: list pattern — repeat children.first as a template for each row
          if (['ListView', 'GridView'].contains(resolvedNode.type) && resolvedNode.children.isNotEmpty) {
            final templateChild = resolvedNode.children.first;
            final childrenWidgets = data.map((rowData) {
              return SupabaseRowDataContext(
                rowData: rowData,
                child: Builder(
                  builder: (childContext) => buildWidget(childContext, templateChild, hoveredNode),
                ),
              );
            }).toList();

            Widget containerWidget;
            if (resolvedNode.type == 'ListView') {
              containerWidget = ListView(
                scrollDirection: _parseAxis(resolvedNode.properties['scrollDirection']) ?? Axis.vertical,
                padding: _parseEdgeInsets(resolvedNode.properties['padding']),
                shrinkWrap: resolvedNode.properties['shrinkWrap'] ?? true,
                children: childrenWidgets,
              );
            } else {
              final crossAxisCount = resolvedNode.properties['crossAxisCount'] as int? ?? 2;
              containerWidget = GridView.count(
                crossAxisCount: crossAxisCount,
                scrollDirection: _parseAxis(resolvedNode.properties['scrollDirection']) ?? Axis.vertical,
                padding: _parseEdgeInsets(resolvedNode.properties['padding']),
                shrinkWrap: resolvedNode.properties['shrinkWrap'] ?? true,
                crossAxisSpacing: (resolvedNode.properties['crossAxisSpacing'] as num?)?.toDouble() ?? 8.0,
                mainAxisSpacing: (resolvedNode.properties['mainAxisSpacing'] as num?)?.toDouble() ?? 8.0,
                children: childrenWidgets,
              );
            }

            return WidgetSelectionWrapper(
              node: resolvedNode,
              hoveredNode: hoveredNode,
              child: containerWidget,
            );
          }

          // Column and Row: detail pattern — inject the first row's data as context
          // and render ALL children normally so each bound child can resolve its field.
          if (['Column', 'Row'].contains(resolvedNode.type)) {
            final allChildren = resolvedNode.children.map((child) {
              return SupabaseRowDataContext(
                rowData: rowData,
                child: Builder(
                  builder: (childContext) => buildWidget(childContext, child, hoveredNode),
                ),
              );
            }).toList();

            Widget containerWidget;
            if (resolvedNode.type == 'Column') {
              containerWidget = Column(
                mainAxisAlignment: _parseMainAxisAlignment(resolvedNode.properties['mainAxisAlignment']) ?? MainAxisAlignment.start,
                crossAxisAlignment: _parseCrossAxisAlignment(resolvedNode.properties['crossAxisAlignment']) ?? CrossAxisAlignment.start,
                children: allChildren,
              );
            } else {
              containerWidget = Row(
                mainAxisAlignment: _parseMainAxisAlignment(resolvedNode.properties['mainAxisAlignment']) ?? MainAxisAlignment.start,
                crossAxisAlignment: _parseCrossAxisAlignment(resolvedNode.properties['crossAxisAlignment']) ?? CrossAxisAlignment.start,
                children: allChildren,
              );
            }

            return WidgetSelectionWrapper(
              node: resolvedNode,
              hoveredNode: hoveredNode,
              child: containerWidget,
            );
          }

          // All other widgets: provide first row's data to context
          return SupabaseRowDataContext(
            rowData: rowData,
            child: _buildInnerWidget(context, resolvedNode, hoveredNode),
          );
        },
      );
    }

    return _buildInnerWidget(context, resolvedNode, hoveredNode);
  }

  static Widget _buildInnerWidget(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    final builder = _builders[node.type];
    
    Widget widget;
    if (builder != null) {
      widget = builder.build(context, node, hoveredNode);
    } else {
      widget = Container(
        color: Colors.red.withOpacity(0.3),
        child: Center(
          child: Text('Unknown: ${node.type}'),
        ),
      );
    }

    if (node.type == 'Expanded' || 
        node.type == 'Flexible' || 
        node.type == 'Positioned' ||
        node.type == 'TableCell' ||
        node.type == 'Spacer') {
      return widget;
    }

    final bool hasActions = (node.properties['actions'] is List && (node.properties['actions'] as List).isNotEmpty) || 
                            node.properties['navigateTo'] != null;
    final bool isNativelyActionable = [
      'ElevatedButton', 'TextButton', 'OutlinedButton', 'Button',
      'IconButton', 'FloatingActionButton', 'FAB', 'MaterialButton',
      'InkWell', 'GestureDetector', 'ListTile', 'Checkbox', 'Radio', 'Switch', 'Slider'
    ].contains(node.type);
    final bool isExcludedFromActionWrapping = [
      'Scaffold', 'AppBar', 'Drawer', 'EndDrawer', 'AlertDialog', 'Dialog', 'BottomSheet',
      'Expanded', 'Flexible', 'Positioned', 'Spacer',
      'ListView', 'GridView', 'SingleChildScrollView', 'CustomScrollView', 'ReorderableListView'
    ].contains(node.type);

    final longPress = node.properties['onLongPress'];
    final doubleTap = node.properties['onDoubleTap'];
    final hasGestureActions = (longPress is List && longPress.isNotEmpty) || (doubleTap is List && doubleTap.isNotEmpty);

    if ((hasActions && !isNativelyActionable && !isExcludedFromActionWrapping) || (hasGestureActions && !isExcludedFromActionWrapping)) {
      final runTap = hasActions && !isNativelyActionable;
      widget = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: runTap
            ? () {
                if (!CanvasPreviewMode.of(context)) return;
                final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
                final rowData = SupabaseRowDataContext.of(context);
                if (rowData != null) provider.activeRowData = rowData;
                final actions = [...?(node.properties['actions'] as List?)];
                final navigateTo = node.properties['navigateTo'];
                if (actions.isEmpty && navigateTo != null) actions.add({'type': 'navigate', 'targetScreenId': navigateTo});
                PreviewRuntime.run(context, actions);
              }
            : null,
        onLongPress: longPress is List && longPress.isNotEmpty
            ? () {
                if (CanvasPreviewMode.of(context)) PreviewRuntime.run(context, longPress);
              }
            : null,
        onDoubleTap: doubleTap is List && doubleTap.isNotEmpty
            ? () {
                if (CanvasPreviewMode.of(context)) PreviewRuntime.run(context, doubleTap);
              }
            : null,
        child: widget,
      );
    }

    final semantic = node.properties['semanticLabel'];
    if (semantic is String && semantic.trim().isNotEmpty) {
      widget = Semantics(label: semantic, child: widget);
    }

    final animation = node.properties['animation'];
    if (animation is Map && animation['type'] != null && animation['type'] != 'none') {
      widget = SynappEntrance(
        // Replays when the animation settings change.
        key: ValueKey('${node.id}-${animation['type']}-${animation['durationMs']}-${animation['delayMs']}-${animation['replay']}'),
        type: animation['type'] as String,
        durationMs: (animation['durationMs'] as num?)?.toInt() ?? 400,
        delayMs: (animation['delayMs'] as num?)?.toInt() ?? 0,
        child: widget,
      );
    }

    if (node.type == 'AppBar' && widget is PreferredSizeWidget) {
      return SelectionPreferredSizeWrapper(
        node: node,
        hoveredNode: hoveredNode,
        child: widget,
      );
    }

    return WidgetSelectionWrapper(
      node: node,
      hoveredNode: hoveredNode,
      child: widget,
    );
  }
}