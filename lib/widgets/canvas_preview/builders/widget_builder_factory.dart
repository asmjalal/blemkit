import 'package:flutter/material.dart';
import '../../../models/widget_node.dart';
import '../selection_wrapper.dart';
import '../selection_preferred_size_wrapper.dart';
import 'base_widget_builder.dart';
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
import 'dropdown_button_builder.dart' as wb;
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
    _builders['DropdownButton'] = wb.DropdownButtonBuilder();
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
    print('WidgetBuilderFactory: Initialization complete. Registered ${_builders.length} builders.');
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

  static Widget buildWidget(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    if (_builders.isEmpty) initialize();
    
    print('WidgetBuilderFactory: Attempting to build widget of type: ${node.type}');
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

    // Don't wrap "parent-data" widgets as they must be direct children of their layout parents
    // (e.g., Expanded/Flexible must be children of Column/Row, Positioned must be child of Stack)
    if (node.type == 'Expanded' || 
        node.type == 'Flexible' || 
        node.type == 'Positioned' ||
        node.type == 'TableCell' ||
        node.type == 'Spacer') {
      return widget;
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