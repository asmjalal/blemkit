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
import '../models/widget_node.dart';

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
  };

  static String generateCode(WidgetNode node, {int indent = 0}) {
    final generator = _generators[node.type];
    if (generator != null) {
      return generator.generateCode(node, indent: indent);
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