import 'base_widget_generator.dart';
import 'container_generator.dart';
import 'text_generator.dart';
import 'rich_text_generator.dart';
import 'flex_generator.dart';
import 'scaffold_generator.dart';
import 'material_widgets/app_bar_generator.dart';
import 'material_widgets/bottom_app_bar_generator.dart';
import 'material_widgets/card_generator.dart';
import 'material_widgets/snack_bar_generator.dart';
import 'material_widgets/alert_dialog_generator.dart';
import 'material_widgets/bottom_sheet_generator.dart';
import 'material_widgets/chip_generator.dart';
import 'material_widgets/tooltip_generator.dart';
import 'material_widgets/divider_generator.dart';
import 'list_grid/list_view_generator.dart';
import 'list_grid/grid_view_generator.dart';
import 'list_grid/single_child_scroll_view_generator.dart';
import 'list_grid/custom_scroll_view_generator.dart';
import 'list_grid/reorderable_list_view_generator.dart';
import 'builder_widgets/future_builder_generator.dart';
import 'builder_widgets/stream_builder_generator.dart';
import 'builder_widgets/layout_builder_generator.dart';
import 'builder_widgets/media_query_generator.dart';
import 'builder_widgets/orientation_builder_generator.dart';
import 'builder_widgets/animated_builder_generator.dart';
import 'floating_action_button_generator.dart';
import 'drawer_generator.dart';
import 'expansion_tile_generator.dart';
import 'image_generator.dart';
import 'icon_generator.dart';
import 'button_generator.dart';
import 'icon_button_generator.dart';
import 'list_tile_generator.dart';
import 'form_widgets/text_field_generator.dart';
import 'expanded_generator.dart';
import 'sized_box_generator.dart';
import 'padding_generator.dart';
import 'center_generator.dart';
import 'align_generator.dart';
import 'stack_generator.dart';
import 'positioned_generator.dart';
import 'gesture_detector_generator.dart';
import 'ink_well_generator.dart';
import 'elevated_button_generator.dart';
import 'text_button_generator.dart';
import 'outlined_button_generator.dart';
import 'dropdown_button_generator.dart';
import 'popup_menu_button_generator.dart';
import 'checkbox_generator.dart';
import 'radio_generator.dart';
import 'switch_generator.dart';
import 'slider_generator.dart';
import 'form_widgets/form_generator.dart';
import 'form_widgets/form_field_generator.dart';
import 'form_widgets/checkbox_list_tile_generator.dart';
import 'form_widgets/switch_list_tile_generator.dart';
import 'form_widgets/radio_list_tile_generator.dart';
import 'navigation_routes/navigator_generator.dart';
import 'navigation_routes/material_page_route_generator.dart';
import 'navigation_routes/page_view_generator.dart';
import 'navigation_routes/bottom_navigation_bar_generator.dart';
import 'navigation_routes/tab_bar_generator.dart';
import 'material_widgets/drawer_header_generator.dart';
import 'spacer_generator.dart';
import 'themed_widget_generator.dart';
import 'vertical_divider_generator.dart';
import 'carousel_generator.dart';
import 'expandable_generator.dart';
import 'wrap_generator.dart';
import 'safe_area_generator.dart';
import 'aspect_ratio_generator.dart';
import 'svg_image_generator.dart';
import 'badge_generator.dart';
import 'avatar_generator.dart';
import 'selectable_text_generator.dart';
import 'constrained_box_generator.dart';
import 'intrinsic_height_generator.dart';
import 'intrinsic_width_generator.dart';
import 'clip_r_rect_generator.dart';
import 'date_picker_generator.dart';
import 'time_picker_generator.dart';
import 'range_slider_generator.dart';
import 'search_field_generator.dart';
import 'auto_complete_generator.dart';
import 'toggle_buttons_generator.dart';
import 'segmented_button_generator.dart';
import 'navigation_rail_generator.dart';
import 'flexible_generator.dart';
import 'fitted_box_generator.dart';
import 'material_button_generator.dart';
import 'circular_progress_indicator_generator.dart';
import 'linear_progress_indicator_generator.dart';
import '../models/widget_node.dart';
import 'project_generator.dart';

class WidgetGeneratorRegistry {
  static final Map<String, BaseWidgetGenerator> _generators = {
    'Container': ContainerGenerator(),
    'Text': TextGenerator(),
    'RichText': RichTextGenerator(),
    'Row': FlexGenerator(isRow: true),
    'Column': FlexGenerator(isRow: false),
    'Scaffold': ScaffoldGenerator(),
    'AppBar': AppBarGenerator(),
    'BottomAppBar': BottomAppBarGenerator(),
    'Card': CardGenerator(),
    'SnackBar': SnackBarGenerator(),
    'AlertDialog': AlertDialogGenerator(),
    'BottomSheet': BottomSheetGenerator(),
    'Chip': ChipGenerator(),
    'CircleAvatar': CircleAvatarGenerator(),
    'Tooltip': TooltipGenerator(),
    'Divider': DividerGenerator(),
    'ListView': ListViewGenerator(),
    'ListView.builder': ListViewBuilderGenerator(),
    'GridView': GridViewGenerator(),
    'GridView.builder': GridViewBuilderGenerator(),
    'SingleChildScrollView': SingleChildScrollViewGenerator(),
    'CustomScrollView': CustomScrollViewGenerator(),
    'ReorderableListView': ReorderableListViewGenerator(),
    'FutureBuilder': FutureBuilderGenerator(),
    'StreamBuilder': StreamBuilderGenerator(),
    'LayoutBuilder': LayoutBuilderGenerator(),
    'MediaQuery': MediaQueryGenerator(),
    'OrientationBuilder': OrientationBuilderGenerator(),
    'AnimatedBuilder': AnimatedBuilderGenerator(),
    'FAB': FloatingActionButtonGenerator(),
    'FloatingActionButton': FloatingActionButtonGenerator(),
    'Drawer': DrawerGenerator(),
    'EndDrawer': DrawerGenerator(),
    'ExpansionTile': ExpansionTileGenerator(),
    'Image': ImageGenerator(),
    'Icon': IconGenerator(),
    'Button': ButtonGenerator(),
    'IconButton': IconButtonGenerator(),
    'ListTile': ListTileGenerator(),
    'TextField': TextFieldGenerator(),
    'Expanded': ExpandedGenerator(),
    'SizedBox': SizedBoxGenerator(),
    'Padding': PaddingGenerator(),
    'Center': CenterGenerator(),
    'Align': AlignGenerator(),
    'Stack': StackGenerator(),
    'Positioned': PositionedGenerator(),
    'GestureDetector': GestureDetectorGenerator(),
    'InkWell': InkWellGenerator(),
    'ElevatedButton': ElevatedButtonGenerator(),
    'TextButton': TextButtonGenerator(),
    'OutlinedButton': OutlinedButtonGenerator(),
    'DropdownButton': DropdownButtonGenerator(),
    'PopupMenuButton': PopupMenuButtonGenerator(),
    'Checkbox': CheckboxGenerator(),
    'Radio': RadioGenerator(),
    'Switch': SwitchGenerator(),
    'Slider': SliderGenerator(),
    'Form': FormGenerator(),
    'FormField': FormFieldGenerator(),
    'CheckboxListTile': CheckboxListTileGenerator(),
    'SwitchListTile': SwitchListTileGenerator(),
    'RadioListTile': RadioListTileGenerator(),
    'Navigator': NavigatorGenerator(),
    'MaterialPageRoute': MaterialPageRouteGenerator(),
    'PageView': PageViewGenerator(),
    'BottomNavigationBar': BottomNavigationBarGenerator(),
    'TabBar': TabBarGenerator(),
    'TabBarView': TabBarViewGenerator(),
    'DrawerHeader': DrawerHeaderGenerator(),
    'Spacer': SpacerGenerator(),
    'ThemedWidget': ThemedWidgetGenerator(),
    'VerticalDivider': VerticalDividerGenerator(),
    'Carousel': CarouselGenerator(),
    'Expandable': ExpandableGenerator(),
    'Wrap': WrapGenerator(),
    'SafeArea': SafeAreaGenerator(),
    'AspectRatio': AspectRatioGenerator(),
    'SvgImage': SvgImageGenerator(),
    'Badge': BadgeGenerator(),
    'Avatar': AvatarGenerator(),
    'SelectableText': SelectableTextGenerator(),
    'ConstrainedBox': ConstrainedBoxGenerator(),
    'IntrinsicHeight': IntrinsicHeightGenerator(),
    'IntrinsicWidth': IntrinsicWidthGenerator(),
    'ClipRRect': ClipRRectGenerator(),
    'DatePicker': DatePickerGenerator(),
    'TimePicker': TimePickerGenerator(),
    'RangeSlider': RangeSliderGenerator(),
    'SearchField': SearchFieldGenerator(),
    'AutoComplete': AutoCompleteGenerator(),
    'ToggleButtons': ToggleButtonsGenerator(),
    'SegmentedButton': SegmentedButtonGenerator(),
    'NavigationRail': NavigationRailGenerator(),
    'Flexible': FlexibleGenerator(),
    'FittedBox': FittedBoxGenerator(),
    'MaterialButton': MaterialButtonGenerator(),
    'CircularProgressIndicator': CircularProgressIndicatorGenerator(),
    'LinearProgressIndicator': LinearProgressIndicatorGenerator(),
  };

  static String generateCode(WidgetNode node, {int indent = 0}) {
    final indentStr = '  ' * indent;
    final childIndentStr = '  ' * (indent + 1);

    if (node.backendQuery != null && ProjectGenerator.activeQueries.isNotEmpty) {
      final queryId = node.backendQuery!['queryId'] as String;
      final query = ProjectGenerator.activeQueries.where((q) => q.id == queryId).firstOrNull;

      if (query != null) {
        final rawMethodName = query.name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), ' ').split(' ').map((s) => s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : '').join('');
        final methodName = rawMethodName.isNotEmpty ? rawMethodName[0].toLowerCase() + rawMethodName.substring(1) : 'fetchData';

        final methodParams = <String>[];
        for (final f in query.filters) {
          final valStr = f.value?.toString() ?? '';
          final isDynamic = f.value == null || 
                            valStr.isEmpty || 
                            valStr == 'idParam' || 
                            valStr == 'widget.idParam' ||
                            (valStr.startsWith('{{') && valStr.endsWith('}}')) ||
                            f.column == 'id' || 
                            f.column.endsWith('_id');
          if (isDynamic) {
            final paramName = '${f.column}Param';
            methodParams.add('$paramName: widget.idParam');
          }
        }
        final methodArgs = methodParams.isNotEmpty ? methodParams.join(', ') : '';

        final isStream = query.enableRealtime;
        final builderType = isStream ? 'StreamBuilder' : 'FutureBuilder';
        final connectionField = isStream 
            ? 'stream: SupabaseService.instance.stream$rawMethodName($methodArgs)' 
            : 'future: SupabaseService.instance.$methodName($methodArgs)';

        final wasInsideRepeated = ProjectGenerator.isInsideRepeatedList;
        ProjectGenerator.isInsideRepeatedList = true;

        String innerContainerCode = '';
        if (node.children.isNotEmpty) {
          final templateChild = node.children.first;
          final templateChildCode = generateCode(templateChild, indent: indent + 4).trimLeft();

          if (node.type == 'ListView') {
            innerContainerCode = '''${indentStr}ListView.builder(
$childIndentStr  itemCount: data.length,
$childIndentStr  shrinkWrap: true,
$childIndentStr  itemBuilder: (context, index) {
$childIndentStr    final item = data[index];
$childIndentStr    return $templateChildCode;
$childIndentStr  },
$childIndentStr)''';
          } else if (node.type == 'GridView') {
            innerContainerCode = '''${indentStr}GridView.builder(
$childIndentStr  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
$childIndentStr    crossAxisCount: 2,
$childIndentStr    crossAxisSpacing: 8,
$childIndentStr    mainAxisSpacing: 8,
$childIndentStr  ),
$childIndentStr  itemCount: data.length,
$childIndentStr  shrinkWrap: true,
$childIndentStr  itemBuilder: (context, index) {
$childIndentStr    final item = data[index];
$childIndentStr    return $templateChildCode;
$childIndentStr  },
$childIndentStr)''';
          } else if (node.type == 'Column' || node.type == 'Row') {
            ProjectGenerator.isInsideRepeatedList = false;
            final childrenCodes = node.children.map((c) => generateCode(c, indent: indent + 4)).join(',\n');
            innerContainerCode = '''${indentStr}${node.type}(
$childIndentStr children: [
${childrenCodes}
$childIndentStr ],
$indentStr)''';
          } else {
            ProjectGenerator.isInsideRepeatedList = false;
            final generator = _generators[node.type];
            final normalCode = generator != null 
                ? generator.generateCode(node, indent: indent + 2).trimLeft()
                : '// Unknown widget type: ${node.type}';
            innerContainerCode = '${indentStr}$normalCode';
          }
        } else {
          ProjectGenerator.isInsideRepeatedList = false;
          final generator = _generators[node.type];
          final normalCode = generator != null 
              ? generator.generateCode(node, indent: indent + 2).trimLeft()
              : '// Unknown widget type: ${node.type}';
          innerContainerCode = '${indentStr}$normalCode';
        }

        ProjectGenerator.isInsideRepeatedList = wasInsideRepeated;

        return '''$indentStr$builderType<List<Map<String, dynamic>>>(
$childIndentStr$connectionField,
$childIndentStr  builder: (context, snapshot) {
$childIndentStr  if (snapshot.connectionState == ConnectionState.waiting) {
$childIndentStr    return const Center(child: CircularProgressIndicator());
$childIndentStr  }
$childIndentStr  if (snapshot.hasError) {
$childIndentStr    return Center(child: Text('Error: \${snapshot.error}'));
$childIndentStr  }
$childIndentStr  final data = snapshot.data ?? [];
$childIndentStr  if (data.isEmpty) {
$childIndentStr    return const Center(child: Text('No data found'));
$childIndentStr  }
$childIndentStr  return ${innerContainerCode.trimLeft()};
$childIndentStr},
$indentStr)''';
      }
    }

    final generator = _generators[node.type];
    if (generator != null) {
      var code = generator.generateCode(node, indent: indent);

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

      if (hasActions && !isNativelyActionable && !isExcludedFromActionWrapping) {
        final fallbackNavigateTo = node.properties['navigateTo'];
        final actions = node.properties['actions'];
        final actionCode = generator.generateActionFlowCode(actions as List?, fallbackNavigateTo?.toString());
        final cleanCode = code.trimLeft();
        code = '${indentStr}GestureDetector(\n'
               '${childIndentStr}onTap: $actionCode,\n'
               '${childIndentStr}child: $cleanCode,\n'
               '$indentStr)';
      }
      return code;
    }
    return '${'  ' * indent}// Unknown widget type: ${node.type}';
  }

  static void registerGenerator(String type, BaseWidgetGenerator generator) {
    _generators[type] = generator;
  }

  static bool hasGenerator(String type) {
    return _generators.containsKey(type);
  }

  static List<String> getSupportedWidgetTypes() {
    return _generators.keys.toList();
  }
}