import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../models/widget_node.dart';
import '../../../providers/widget_tree_provider.dart';
import '../../../utils/color_utils.dart';

abstract class BaseWidgetBuilder {
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode);
  
  // Helper methods for parsing properties from JSON
  Color? parseColor(dynamic value, BuildContext context) {
    if (value == null) return null;
    final theme = Provider.of<WidgetTreeProvider>(context, listen: false).themeProperties;
    return ColorUtils.parseColor(value, theme, Colors.transparent);
  }

  // Legacy support for builders that don't pass context yet
  Color? parseColorLegacy(dynamic value) {
    if (value == null) return null;
    return ColorUtils.parseColor(value);
  }

  EdgeInsets? parseEdgeInsets(dynamic value) {
    if (value == null) return null;
    if (value is num) {
      return EdgeInsets.all(value.toDouble());
    }
    if (value is Map<String, dynamic>) {
      return EdgeInsets.only(
        left: (value['left'] as num?)?.toDouble() ?? 0.0,
        top: (value['top'] as num?)?.toDouble() ?? 0.0,
        right: (value['right'] as num?)?.toDouble() ?? 0.0,
        bottom: (value['bottom'] as num?)?.toDouble() ?? 0.0,
      );
    }
    if (value is String) {
      if (value.startsWith('EdgeInsets.all(')) {
        final double size = double.parse(value.substring(15, value.length - 1));
        return EdgeInsets.all(size);
      } else if (value.startsWith('EdgeInsets.only(')) {
        final String inner = value.substring(16, value.length - 1);
        final Map<String, double> values = {};
        for (String part in inner.split(', ')) {
          final List<String> kv = part.split(': ');
          if (kv.length == 2) {
            values[kv[0]] = double.parse(kv[1]);
          }
        }
        return EdgeInsets.only(
          left: values['left'] ?? 0.0,
          top: values['top'] ?? 0.0,
          right: values['right'] ?? 0.0,
          bottom: values['bottom'] ?? 0.0,
        );
      } else if (value.startsWith('EdgeInsets.symmetric(')) {
        final String inner = value.substring(21, value.length - 1);
        final Map<String, double> values = {};
        for (String part in inner.split(', ')) {
          final List<String> kv = part.split(': ');
          if (kv.length == 2) {
            values[kv[0]] = double.parse(kv[1]);
          }
        }
        return EdgeInsets.symmetric(
          vertical: values['vertical'] ?? 0.0,
          horizontal: values['horizontal'] ?? 0.0,
        );
      }
    }
    return null;
  }

  double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      if (value == 'double.infinity') return double.infinity;
      if (value == 'double.maxFinite') return double.maxFinite;
      return double.tryParse(value);
    }
    return null;
  }

  FontWeight? parseFontWeight(dynamic value) {
    if (value == null) return FontWeight.normal;
    if (value is String) {
      switch (value) {
        case 'FontWeight.bold':
        case 'bold':
          return FontWeight.bold;
        case 'FontWeight.normal':
        case 'normal':
          return FontWeight.normal;
        case 'FontWeight.w100':
        case 'w100':
          return FontWeight.w100;
        case 'FontWeight.w200':
        case 'w200':
          return FontWeight.w200;
        case 'FontWeight.w300':
        case 'w300':
          return FontWeight.w300;
        case 'FontWeight.w400':
        case 'w400':
          return FontWeight.w400;
        case 'FontWeight.w500':
        case 'w500':
          return FontWeight.w500;
        case 'FontWeight.w600':
        case 'w600':
          return FontWeight.w600;
        case 'FontWeight.w700':
        case 'w700':
          return FontWeight.w700;
        case 'FontWeight.w800':
        case 'w800':
          return FontWeight.w800;
        case 'FontWeight.w900':
        case 'w900':
          return FontWeight.w900;
      }
    }
    return FontWeight.normal;
  }

  TextAlign? parseTextAlign(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      switch (value) {
        case 'TextAlign.left': return TextAlign.left;
        case 'TextAlign.center': return TextAlign.center;
        case 'TextAlign.right': return TextAlign.right;
        case 'TextAlign.justify': return TextAlign.justify;
        case 'TextAlign.end': return TextAlign.end;
        case 'TextAlign.start': return TextAlign.start;
      }
    }
    return null;
  }

  TextDecoration? parseTextDecoration(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      switch (value) {
        case 'TextDecoration.underline': return TextDecoration.underline;
        case 'TextDecoration.lineThrough': return TextDecoration.lineThrough;
        case 'TextDecoration.overline': return TextDecoration.overline;
        case 'TextDecoration.none': return TextDecoration.none;
      }
    }
    return null;
  }

  TextDecorationStyle? parseTextDecorationStyle(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      switch (value) {
        case 'TextDecorationStyle.solid': return TextDecorationStyle.solid;
        case 'TextDecorationStyle.double': return TextDecorationStyle.double;
        case 'TextDecorationStyle.dotted': return TextDecorationStyle.dotted;
        case 'TextDecorationStyle.dashed': return TextDecorationStyle.dashed;
        case 'TextDecorationStyle.wavy': return TextDecorationStyle.wavy;
      }
    }
    return null;
  }

  TextOverflow? parseTextOverflow(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      switch (value) {
        case 'TextOverflow.ellipsis': return TextOverflow.ellipsis;
        case 'TextOverflow.fade': return TextOverflow.fade;
        case 'TextOverflow.visible': return TextOverflow.visible;
        case 'TextOverflow.clip': return TextOverflow.clip;
      }
    }
    return null;
  }

  BoxFit? parseBoxFit(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      switch (value) {
        case 'BoxFit.fill': return BoxFit.fill;
        case 'BoxFit.contain': return BoxFit.contain;
        case 'BoxFit.cover': return BoxFit.cover;
        case 'BoxFit.fitWidth': return BoxFit.fitWidth;
        case 'BoxFit.fitHeight': return BoxFit.fitHeight;
        case 'BoxFit.none': return BoxFit.none;
        case 'BoxFit.scaleDown': return BoxFit.scaleDown;
      }
    }
    return null;
  }

  MainAxisAlignment parseMainAxisAlignment(dynamic value) {
    if (value == null) return MainAxisAlignment.start;
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
    return MainAxisAlignment.start;
  }

  CrossAxisAlignment parseCrossAxisAlignment(dynamic value) {
    if (value == null) return CrossAxisAlignment.start;
    if (value is String) {
      switch (value) {
        case 'CrossAxisAlignment.start': return CrossAxisAlignment.start;
        case 'CrossAxisAlignment.end': return CrossAxisAlignment.end;
        case 'CrossAxisAlignment.center': return CrossAxisAlignment.center;
        case 'CrossAxisAlignment.stretch': return CrossAxisAlignment.stretch;
        case 'CrossAxisAlignment.baseline': return CrossAxisAlignment.baseline;
      }
    }
    return CrossAxisAlignment.start;
  }

  AlignmentGeometry? parseAlignment(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      switch (value) {
        case 'Alignment.topLeft': return Alignment.topLeft;
        case 'Alignment.topCenter': return Alignment.topCenter;
        case 'Alignment.topRight': return Alignment.topRight;
        case 'Alignment.centerLeft': return Alignment.centerLeft;
        case 'Alignment.center': return Alignment.center;
        case 'Alignment.centerRight': return Alignment.centerRight;
        case 'Alignment.bottomLeft': return Alignment.bottomLeft;
        case 'Alignment.bottomCenter': return Alignment.bottomCenter;
        case 'Alignment.bottomRight': return Alignment.bottomRight;
      }
    }
    return null;
  }

  Gradient? parseGradient(dynamic value, BuildContext context) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) {
      final List<dynamic> colorsList = value['colors'] as List<dynamic>? ?? [];
      final List<Color> colors = colorsList.map((c) => parseColor(c, context) ?? Colors.transparent).toList();
      if (colors.length < 2) return null;
      
      return LinearGradient(
        colors: colors,
        begin: parseAlignment(value['begin']) as Alignment? ?? Alignment.centerLeft,
        end: parseAlignment(value['end']) as Alignment? ?? Alignment.centerRight,
      );
    }
    return null;
  }

  Axis? parseAxis(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      switch (value) {
        case 'Axis.horizontal': return Axis.horizontal;
        case 'Axis.vertical': return Axis.vertical;
        case 'horizontal': return Axis.horizontal;
        case 'vertical': return Axis.vertical;
      }
    }
    return null;
  }

  MainAxisSize? parseMainAxisSize(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      switch (value) {
        case 'MainAxisSize.min': return MainAxisSize.min;
        case 'MainAxisSize.max': return MainAxisSize.max;
      }
    }
    return null;
  }

  dynamic parseIconData(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      switch (value) {
        // Material Icons
        case 'Icons.access_time': return Icons.access_time;
        case 'Icons.account_balance': return Icons.account_balance;
        case 'Icons.account_balance_wallet': return Icons.account_balance_wallet;
        case 'Icons.account_circle': return Icons.account_circle;
        case 'Icons.account_tree_outlined': return Icons.account_tree_outlined;
        case 'Icons.add': return Icons.add;
        case 'Icons.add_box_outlined': return Icons.add_box_outlined;
        case 'Icons.add_circle': return Icons.add_circle;
        case 'Icons.add_circle_outline': return Icons.add_circle_outline;
        case 'Icons.align_horizontal_center': return Icons.align_horizontal_center;
        case 'Icons.all_inclusive': return Icons.all_inclusive;
        case 'Icons.alternate_email': return Icons.alternate_email;
        case 'Icons.analytics_outlined': return Icons.analytics_outlined;
        case 'Icons.animation': return Icons.animation;
        case 'Icons.arrow_back': return Icons.arrow_back;
        case 'Icons.arrow_back_ios_new_rounded': return Icons.arrow_back_ios_new_rounded;
        case 'Icons.arrow_drop_down': return Icons.arrow_drop_down;
        case 'Icons.arrow_drop_down_circle': return Icons.arrow_drop_down_circle;
        case 'Icons.arrow_forward': return Icons.arrow_forward;
        case 'Icons.arrow_forward_ios': return Icons.arrow_forward_ios;
        case 'Icons.arrow_right': return Icons.arrow_right;
        case 'Icons.aspect_ratio': return Icons.aspect_ratio;
        case 'Icons.attach_money': return Icons.attach_money;
        case 'Icons.auto_awesome': return Icons.auto_awesome;
        case 'Icons.auto_fix_high': return Icons.auto_fix_high;
        case 'Icons.badge': return Icons.badge;
        case 'Icons.bar_chart': return Icons.bar_chart;
        case 'Icons.battery_full': return Icons.battery_full;
        case 'Icons.bedtime': return Icons.bedtime;
        case 'Icons.bluetooth': return Icons.bluetooth;
        case 'Icons.blur_on': return Icons.blur_on;
        case 'Icons.bolt': return Icons.bolt;
        case 'Icons.book': return Icons.book;
        case 'Icons.bookmark': return Icons.bookmark;
        case 'Icons.bookmark_border': return Icons.bookmark_border;
        case 'Icons.bookmark_outline': return Icons.bookmark_outline;
        case 'Icons.broken_image': return Icons.broken_image;
        case 'Icons.calendar_month': return Icons.calendar_month;
        case 'Icons.calendar_today': return Icons.calendar_today;
        case 'Icons.calendar_view_day': return Icons.calendar_view_day;
        case 'Icons.calendar_view_month': return Icons.calendar_view_month;
        case 'Icons.calendar_view_week': return Icons.calendar_view_week;
        case 'Icons.call': return Icons.call;
        case 'Icons.call_received': return Icons.call_received;
        case 'Icons.camera_alt': return Icons.camera_alt;
        case 'Icons.center_focus_strong': return Icons.center_focus_strong;
        case 'Icons.chat': return Icons.chat;
        case 'Icons.chat_bubble_outline': return Icons.chat_bubble_outline;
        case 'Icons.check': return Icons.check;
        case 'Icons.check_box': return Icons.check_box;
        case 'Icons.check_box_outline_blank': return Icons.check_box_outline_blank;
        case 'Icons.check_circle': return Icons.check_circle;
        case 'Icons.check_circle_outline': return Icons.check_circle_outline;
        case 'Icons.checklist': return Icons.checklist;
        case 'Icons.checklist_rtl': return Icons.checklist_rtl;
        case 'Icons.checkroom': return Icons.checkroom;
        case 'Icons.chevron_right': return Icons.chevron_right;
        case 'Icons.circle': return Icons.circle;
        case 'Icons.close': return Icons.close;
        case 'Icons.cloud': return Icons.cloud;
        case 'Icons.cloud_download': return Icons.cloud_download;
        case 'Icons.cloud_outlined': return Icons.cloud_outlined;
        case 'Icons.code': return Icons.code;
        case 'Icons.copy': return Icons.copy;
        case 'Icons.create_outlined': return Icons.create_outlined;
        case 'Icons.credit_card': return Icons.credit_card;
        case 'Icons.credit_card_outlined': return Icons.credit_card_outlined;
        case 'Icons.crop_din': return Icons.crop_din;
        case 'Icons.crop_free': return Icons.crop_free;
        case 'Icons.crop_square': return Icons.crop_square;
        case 'Icons.dark_mode': return Icons.dark_mode;
        case 'Icons.dashboard': return Icons.dashboard;
        case 'Icons.dashboard_customize': return Icons.dashboard_customize;
        case 'Icons.dashboard_customize_outlined': return Icons.dashboard_customize_outlined;
        case 'Icons.dashboard_customize_rounded': return Icons.dashboard_customize_rounded;
        case 'Icons.dashboard_outlined': return Icons.dashboard_outlined;
        case 'Icons.delete': return Icons.delete;
        case 'Icons.delete_outline': return Icons.delete_outline;
        case 'Icons.delivery_dining': return Icons.delivery_dining;
        case 'Icons.description': return Icons.description;
        case 'Icons.description_outlined': return Icons.description_outlined;
        case 'Icons.design_services_rounded': return Icons.design_services_rounded;
        case 'Icons.directions': return Icons.directions;
        case 'Icons.directions_bike': return Icons.directions_bike;
        case 'Icons.directions_car': return Icons.directions_car;
        case 'Icons.directions_run': return Icons.directions_run;
        case 'Icons.directions_walk': return Icons.directions_walk;
        case 'Icons.done': return Icons.done;
        case 'Icons.download': return Icons.download;
        case 'Icons.edit': return Icons.edit;
        case 'Icons.edit_attributes': return Icons.edit_attributes;
        case 'Icons.edit_outlined': return Icons.edit_outlined;
        case 'Icons.email': return Icons.email;
        case 'Icons.email_outlined': return Icons.email_outlined;
        case 'Icons.emoji_events': return Icons.emoji_events;
        case 'Icons.expand': return Icons.expand;
        case 'Icons.expand_more': return Icons.expand_more;
        case 'Icons.explore': return Icons.explore;
        case 'Icons.explore_outlined': return Icons.explore_outlined;
        case 'Icons.exposure_plus_2': return Icons.exposure_plus_2;
        case 'Icons.fastfood': return Icons.fastfood;
        case 'Icons.favorite': return Icons.favorite;
        case 'Icons.favorite_border': return Icons.favorite_border;
        case 'Icons.file_open_outlined': return Icons.file_open_outlined;
        case 'Icons.filter_list': return Icons.filter_list;
        case 'Icons.fingerprint': return Icons.fingerprint;
        case 'Icons.fit_screen': return Icons.fit_screen;
        case 'Icons.fitness_center': return Icons.fitness_center;
        case 'Icons.flight': return Icons.flight;
        case 'Icons.folder': return Icons.folder;
        case 'Icons.folder_copy_outlined': return Icons.folder_copy_outlined;
        case 'Icons.folder_zip': return Icons.folder_zip;
        case 'Icons.format_bold': return Icons.format_bold;
        case 'Icons.format_italic': return Icons.format_italic;
        case 'Icons.format_underlined': return Icons.format_underlined;
        case 'Icons.grid_on': return Icons.grid_on;
        case 'Icons.grid_view': return Icons.grid_view;
        case 'Icons.group': return Icons.group;
        case 'Icons.headphones': return Icons.headphones;
        case 'Icons.height': return Icons.height;
        case 'Icons.help': return Icons.help;
        case 'Icons.help_outline': return Icons.help_outline;
        case 'Icons.history': return Icons.history;
        case 'Icons.home': return Icons.home;
        case 'Icons.home_filled': return Icons.home_filled;
        case 'Icons.home_outlined': return Icons.home_outlined;
        case 'Icons.horizontal_rule': return Icons.horizontal_rule;
        case 'Icons.hourglass_empty': return Icons.hourglass_empty;
        case 'Icons.image': return Icons.image;
        case 'Icons.image_search': return Icons.image_search;
        case 'Icons.indeterminate_check_box': return Icons.indeterminate_check_box;
        case 'Icons.info': return Icons.info;
        case 'Icons.info_outline': return Icons.info_outline;
        case 'Icons.input': return Icons.input;
        case 'Icons.insert_emoticon': return Icons.insert_emoticon;
        case 'Icons.inventory_2_outlined': return Icons.inventory_2_outlined;
        case 'Icons.keyboard_arrow_down': return Icons.keyboard_arrow_down;
        case 'Icons.keyboard_arrow_up': return Icons.keyboard_arrow_up;
        case 'Icons.label': return Icons.label;
        case 'Icons.language': return Icons.language;
        case 'Icons.laptop_mac': return Icons.laptop_mac;
        case 'Icons.layers': return Icons.layers;
        case 'Icons.layers_outlined': return Icons.layers_outlined;
        case 'Icons.library_music': return Icons.library_music;
        case 'Icons.light_mode': return Icons.light_mode;
        case 'Icons.line_weight': return Icons.line_weight;
        case 'Icons.link': return Icons.link;
        case 'Icons.link_off': return Icons.link_off;
        case 'Icons.list': return Icons.list;
        case 'Icons.list_alt': return Icons.list_alt;
        case 'Icons.local_activity': return Icons.local_activity;
        case 'Icons.local_drink': return Icons.local_drink;
        case 'Icons.local_fire_department': return Icons.local_fire_department;
        case 'Icons.local_offer': return Icons.local_offer;
        case 'Icons.local_pharmacy': return Icons.local_pharmacy;
        case 'Icons.local_pizza': return Icons.local_pizza;
        case 'Icons.local_shipping': return Icons.local_shipping;
        case 'Icons.location_on': return Icons.location_on;
        case 'Icons.lock': return Icons.lock;
        case 'Icons.lock_open': return Icons.lock_open;
        case 'Icons.lock_outline': return Icons.lock_outline;
        case 'Icons.login_rounded': return Icons.login_rounded;
        case 'Icons.logout': return Icons.logout;
        case 'Icons.logout_rounded': return Icons.logout_rounded;
        case 'Icons.map': return Icons.map;
        case 'Icons.map_outlined': return Icons.map_outlined;
        case 'Icons.medical_services': return Icons.medical_services;
        case 'Icons.menu': return Icons.menu;
        case 'Icons.menu_open': return Icons.menu_open;
        case 'Icons.message': return Icons.message;
        case 'Icons.mic': return Icons.mic;
        case 'Icons.more_horiz': return Icons.more_horiz;
        case 'Icons.more_vert': return Icons.more_vert;
        case 'Icons.music_note': return Icons.music_note;
        case 'Icons.navigation': return Icons.navigation;
        case 'Icons.notifications': return Icons.notifications;
        case 'Icons.notifications_none': return Icons.notifications_none;
        case 'Icons.notifications_outlined': return Icons.notifications_outlined;
        case 'Icons.opacity': return Icons.opacity;
        case 'Icons.open_in_full': return Icons.open_in_full;
        case 'Icons.padding': return Icons.padding;
        case 'Icons.palette_outlined': return Icons.palette_outlined;
        case 'Icons.password': return Icons.password;
        case 'Icons.pause': return Icons.pause;
        case 'Icons.payments': return Icons.payments;
        case 'Icons.person': return Icons.person;
        case 'Icons.person_add_alt_1': return Icons.person_add_alt_1;
        case 'Icons.person_outline': return Icons.person_outline;
        case 'Icons.phone': return Icons.phone;
        case 'Icons.phone_android': return Icons.phone_android;
        case 'Icons.photo_camera': return Icons.photo_camera;
        case 'Icons.pie_chart': return Icons.pie_chart;
        case 'Icons.place': return Icons.place;
        case 'Icons.play_arrow': return Icons.play_arrow;
        case 'Icons.play_circle_filled': return Icons.play_circle_filled;
        case 'Icons.play_circle_outline': return Icons.play_circle_outline;
        case 'Icons.pool': return Icons.pool;
        case 'Icons.privacy_tip_outlined': return Icons.privacy_tip_outlined;
        case 'Icons.qr_code_scanner': return Icons.qr_code_scanner;
        case 'Icons.radio_button_checked': return Icons.radio_button_checked;
        case 'Icons.radio_button_unchecked': return Icons.radio_button_unchecked;
        case 'Icons.ramen_dining': return Icons.ramen_dining;
        case 'Icons.receipt_long_outlined': return Icons.receipt_long_outlined;
        case 'Icons.redo': return Icons.redo;
        case 'Icons.refresh': return Icons.refresh;
        case 'Icons.remove': return Icons.remove;
        case 'Icons.remove_circle_outline': return Icons.remove_circle_outline;
        case 'Icons.remove_red_eye_outlined': return Icons.remove_red_eye_outlined;
        case 'Icons.repeat': return Icons.repeat;
        case 'Icons.restaurant': return Icons.restaurant;
        case 'Icons.rice_bowl': return Icons.rice_bowl;
        case 'Icons.rotate_left': return Icons.rotate_left;
        case 'Icons.roundabout_right': return Icons.roundabout_right;
        case 'Icons.rounded_corner': return Icons.rounded_corner;
        case 'Icons.save_outlined': return Icons.save_outlined;
        case 'Icons.schedule': return Icons.schedule;
        case 'Icons.school': return Icons.school;
        case 'Icons.search': return Icons.search;
        case 'Icons.search_outlined': return Icons.search_outlined;
        case 'Icons.security': return Icons.security;
        case 'Icons.self_improvement': return Icons.self_improvement;
        case 'Icons.send': return Icons.send;
        case 'Icons.send_outlined': return Icons.send_outlined;
        case 'Icons.send_rounded': return Icons.send_rounded;
        case 'Icons.settings': return Icons.settings;
        case 'Icons.settings_applications_sharp': return Icons.settings_applications_sharp;
        case 'Icons.settings_outlined': return Icons.settings_outlined;
        case 'Icons.share': return Icons.share;
        case 'Icons.shopping_bag': return Icons.shopping_bag;
        case 'Icons.shopping_bag_outlined': return Icons.shopping_bag_outlined;
        case 'Icons.shopping_cart': return Icons.shopping_cart;
        case 'Icons.shopping_cart_outlined': return Icons.shopping_cart_outlined;
        case 'Icons.show_chart': return Icons.show_chart;
        case 'Icons.shuffle': return Icons.shuffle;
        case 'Icons.skip_next': return Icons.skip_next;
        case 'Icons.skip_previous': return Icons.skip_previous;
        case 'Icons.smart_button': return Icons.smart_button;
        case 'Icons.sort': return Icons.sort;
        case 'Icons.spa': return Icons.spa;
        case 'Icons.space_bar': return Icons.space_bar;
        case 'Icons.space_dashboard': return Icons.space_dashboard;
        case 'Icons.sports_soccer': return Icons.sports_soccer;
        case 'Icons.star': return Icons.star;
        case 'Icons.star_border': return Icons.star_border;
        case 'Icons.star_half': return Icons.star_half;
        case 'Icons.star_outline': return Icons.star_outline;
        case 'Icons.storage_outlined': return Icons.storage_outlined;
        case 'Icons.storefront': return Icons.storefront;
        case 'Icons.swap_horiz': return Icons.swap_horiz;
        case 'Icons.swap_vert': return Icons.swap_vert;
        case 'Icons.swipe': return Icons.swipe;
        case 'Icons.tab': return Icons.tab;
        case 'Icons.table_chart': return Icons.table_chart;
        case 'Icons.text_fields': return Icons.text_fields;
        case 'Icons.text_fields_outlined': return Icons.text_fields_outlined;
        case 'Icons.text_snippet': return Icons.text_snippet;
        case 'Icons.thumb_up': return Icons.thumb_up;
        case 'Icons.toggle_off': return Icons.toggle_off;
        case 'Icons.toggle_on': return Icons.toggle_on;
        case 'Icons.token_outlined': return Icons.token_outlined;
        case 'Icons.trending_flat': return Icons.trending_flat;
        case 'Icons.trending_up': return Icons.trending_up;
        case 'Icons.tune': return Icons.tune;
        case 'Icons.tv': return Icons.tv;
        case 'Icons.undo': return Icons.undo;
        case 'Icons.upload': return Icons.upload;
        case 'Icons.verified_user': return Icons.verified_user;
        case 'Icons.verified_user_outlined': return Icons.verified_user_outlined;
        case 'Icons.vertical_align_center': return Icons.vertical_align_center;
        case 'Icons.view_agenda': return Icons.view_agenda;
        case 'Icons.view_carousel': return Icons.view_carousel;
        case 'Icons.view_column': return Icons.view_column;
        case 'Icons.view_kanban': return Icons.view_kanban;
        case 'Icons.view_module_outlined': return Icons.view_module_outlined;
        case 'Icons.view_sidebar': return Icons.view_sidebar;
        case 'Icons.view_week': return Icons.view_week;
        case 'Icons.visibility': return Icons.visibility;
        case 'Icons.visibility_off': return Icons.visibility_off;
        case 'Icons.visibility_outlined': return Icons.visibility_outlined;
        case 'Icons.vpn_key': return Icons.vpn_key;
        case 'Icons.warning': return Icons.warning;
        case 'Icons.watch': return Icons.watch;
        case 'Icons.water_drop': return Icons.water_drop;
        case 'Icons.wb_sunny': return Icons.wb_sunny;
        case 'Icons.web_asset': return Icons.web_asset;
        case 'Icons.web_asset_outlined': return Icons.web_asset_outlined;
        case 'Icons.widgets': return Icons.widgets;
        case 'Icons.widgets_outlined': return Icons.widgets_outlined;
        case 'Icons.width_full': return Icons.width_full;
        case 'Icons.wifi': return Icons.wifi;
        case 'Icons.work_outline': return Icons.work_outline;
        case 'Icons.wrap_text': return Icons.wrap_text;
        // FontAwesome Icons
        case 'FontAwesomeIcons.apple': return FontAwesomeIcons.apple;
        case 'FontAwesomeIcons.bars': return FontAwesomeIcons.bars;
        case 'FontAwesomeIcons.bell': return FontAwesomeIcons.bell;
        case 'FontAwesomeIcons.bookmark': return FontAwesomeIcons.bookmark;
        case 'FontAwesomeIcons.comment': return FontAwesomeIcons.comment;
        case 'FontAwesomeIcons.ellipsis': return FontAwesomeIcons.ellipsis;
        case 'FontAwesomeIcons.ellipsisVertical': return FontAwesomeIcons.ellipsisVertical;
        case 'FontAwesomeIcons.facebook': return FontAwesomeIcons.facebook;
        case 'FontAwesomeIcons.gear': return FontAwesomeIcons.gear;
        case 'FontAwesomeIcons.github': return FontAwesomeIcons.github;
        case 'FontAwesomeIcons.google': return FontAwesomeIcons.google;
        case 'FontAwesomeIcons.heart': return FontAwesomeIcons.heart;
        case 'FontAwesomeIcons.house': return FontAwesomeIcons.house;
        case 'FontAwesomeIcons.instagram': return FontAwesomeIcons.instagram;
        case 'FontAwesomeIcons.linkedin': return FontAwesomeIcons.linkedin;
        case 'FontAwesomeIcons.magnifyingGlass': return FontAwesomeIcons.magnifyingGlass;
        case 'FontAwesomeIcons.paperPlane': return FontAwesomeIcons.paperPlane;
        case 'FontAwesomeIcons.plus': return FontAwesomeIcons.plus;
        case 'FontAwesomeIcons.solidBell': return FontAwesomeIcons.solidBell;
        case 'FontAwesomeIcons.solidBookmark': return FontAwesomeIcons.solidBookmark;
        case 'FontAwesomeIcons.solidComment': return FontAwesomeIcons.solidComment;
        case 'FontAwesomeIcons.solidHeart': return FontAwesomeIcons.solidHeart;
        case 'FontAwesomeIcons.solidPaperPlane': return FontAwesomeIcons.solidPaperPlane;
        case 'FontAwesomeIcons.solidUser': return FontAwesomeIcons.solidUser;
        case 'FontAwesomeIcons.tiktok': return FontAwesomeIcons.tiktok;
        case 'FontAwesomeIcons.twitter': return FontAwesomeIcons.twitter;
        case 'FontAwesomeIcons.user': return FontAwesomeIcons.user;
        case 'FontAwesomeIcons.xmark': return FontAwesomeIcons.xmark;
        case 'FontAwesomeIcons.youtube': return FontAwesomeIcons.youtube;
      }
    }
    return Icons.widgets; // fallback icon instead of null
  }

  /// Safely extracts a display string from any property value.
  /// Handles String, num, bool, and nested widget Map (extracts 'text' from it).
  /// Never throws a _JsonMap cast error.
  String safeString(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    if (value is Map<String, dynamic>) {
      // AI returned a nested widget node — try to extract its text property
      final text = value['properties']?['text'];
      if (text != null) return safeString(text, fallback: fallback);
      // Fallback: try 'label'
      final label = value['properties']?['label'];
      if (label != null) return safeString(label, fallback: fallback);
      return fallback;
    }
    return fallback;
  }

  /// Safely builds a Widget from a property that may be a String, a Map (widget node), or a WidgetNode.
  /// If it's a String → wraps in Text. If it's a Map → builds via factory. Null → null.
  Widget? safeWidget(BuildContext context, dynamic value, WidgetNode? hoveredNode, {Widget? fallback}) {
    if (value == null) return fallback;
    if (value is WidgetNode) {
      return _buildSafe(context, value, hoveredNode);
    }
    if (value is Map<String, dynamic>) {
      try {
        final node = WidgetNode.fromJson(value);
        return _buildSafe(context, node, hoveredNode);
      } catch (_) {
        return fallback;
      }
    }
    if (value is String && value.isNotEmpty) {
      return Text(value);
    }
    return fallback;
  }

  Widget _buildSafe(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    // Lazy import via factory — avoids circular import
    // We re-use the factory through the static method.
    // This is safe because WidgetBuilderFactory is already initialised.
    try {
      // ignore: avoid_dynamic_calls
      return WidgetBuilderFactoryRef.build(context, node, hoveredNode);
    } catch (e) {
      return Text('Error: $e', style: const TextStyle(color: Colors.red, fontSize: 10));
    }
  }

  String resolveDataBinding(WidgetNode node, dynamic defaultValue) {
    final binding = node.properties['dataBinding'] as Map<String, dynamic>?;
    if (binding == null || binding['field'] == null || binding['field'].toString().isEmpty) {
      return safeString(defaultValue);
    }
    // For now, return a placeholder indicating what's bound
    return '{${binding['field']}}';
  }
}

/// Thin bridge to WidgetBuilderFactory to avoid circular imports in BaseWidgetBuilder.
class WidgetBuilderFactoryRef {
  static Widget Function(BuildContext, WidgetNode, WidgetNode?)? _fn;

  static void register(Widget Function(BuildContext, WidgetNode, WidgetNode?) fn) {
    _fn = fn;
  }

  static Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode) {
    if (_fn != null) return _fn!(context, node, hoveredNode);
    return const SizedBox(); // fallback before registration
  }
}