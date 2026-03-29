import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../models/widget_node.dart';
import '../../../utils/color_utils.dart';

abstract class BaseWidgetBuilder {
  Widget build(BuildContext context, WidgetNode node, WidgetNode? hoveredNode);
  
  // Helper methods for parsing properties from JSON
  Color? parseColor(dynamic value) {
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
    if (value is String) return double.tryParse(value);
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

  IconData? parseIconData(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      switch (value) {
        // Navigation & UI
        case 'Icons.search': return Icons.search;
        case 'Icons.search_outlined': return Icons.search_outlined;
        case 'Icons.more_vert': return Icons.more_vert;
        case 'Icons.add': return Icons.add;
        case 'Icons.add_circle': return Icons.add_circle;
        case 'Icons.add_circle_outline': return Icons.add_circle_outline;
        case 'Icons.close': return Icons.close;
        case 'Icons.menu': return Icons.menu;
        case 'Icons.arrow_back': return Icons.arrow_back;
        case 'Icons.arrow_forward': return Icons.arrow_forward;
        case 'Icons.arrow_forward_ios': return Icons.arrow_forward_ios;
        case 'Icons.chevron_right': return Icons.chevron_right;
        case 'Icons.expand_more': return Icons.expand_more;
        case 'Icons.help': return Icons.help;
        case 'Icons.info': return Icons.info;
        case 'Icons.info_outline': return Icons.info_outline;
        // People & Profile
        case 'Icons.person': return Icons.person;
        case 'Icons.person_outline': return Icons.person_outline;
        case 'Icons.person_add_alt_1': return Icons.person_add_alt_1;
        case 'Icons.group': return Icons.group;
        case 'Icons.account_circle': return Icons.account_circle;
        // Home & Navigation tabs
        case 'Icons.home': return Icons.home;
        case 'Icons.home_outlined': return Icons.home_outlined;
        case 'Icons.explore': return Icons.explore;
        case 'Icons.settings': return Icons.settings;
        case 'Icons.settings_outlined': return Icons.settings_outlined;
        // Communication
        case 'Icons.notifications': return Icons.notifications;
        case 'Icons.notifications_outlined': return Icons.notifications_outlined;
        case 'Icons.notifications_none': return Icons.notifications_none;
        case 'Icons.chat': return Icons.chat;
        case 'Icons.chat_bubble_outline': return Icons.chat_bubble_outline;
        case 'Icons.message': return Icons.message;
        case 'Icons.email': return Icons.email;
        case 'Icons.email_outlined': return Icons.email_outlined;
        case 'Icons.phone': return Icons.phone;
        case 'Icons.call': return Icons.call;
        // Commerce & Shopping
        case 'Icons.shopping_cart': return Icons.shopping_cart;
        case 'Icons.shopping_cart_outlined': return Icons.shopping_cart_outlined;
        case 'Icons.shopping_bag_outlined': return Icons.shopping_bag_outlined;
        case 'Icons.attach_money': return Icons.attach_money;
        case 'Icons.credit_card': return Icons.credit_card;
        case 'Icons.local_offer': return Icons.local_offer;
        case 'Icons.storefront': return Icons.storefront;
        // Devices & Tech
        case 'Icons.phone_android': return Icons.phone_android;
        case 'Icons.laptop_mac': return Icons.laptop_mac;
        case 'Icons.headphones': return Icons.headphones;
        case 'Icons.watch': return Icons.watch;
        case 'Icons.tv': return Icons.tv;
        case 'Icons.camera_alt': return Icons.camera_alt;
        // Clothing & Style
        case 'Icons.checkroom': return Icons.checkroom;
        // Sports & Fitness
        case 'Icons.sports_soccer': return Icons.sports_soccer;
        case 'Icons.fitness_center': return Icons.fitness_center;
        case 'Icons.directions_run': return Icons.directions_run;
        // Food & Delivery
        case 'Icons.restaurant': return Icons.restaurant;
        case 'Icons.local_pizza': return Icons.local_pizza;
        case 'Icons.local_drink': return Icons.local_drink;
        case 'Icons.delivery_dining': return Icons.delivery_dining;
        case 'Icons.ramen_dining': return Icons.ramen_dining;
        case 'Icons.rice_bowl': return Icons.rice_bowl;
        case 'Icons.fastfood': return Icons.fastfood;
        // Location
        case 'Icons.location_on': return Icons.location_on;
        case 'Icons.map': return Icons.map;
        case 'Icons.place': return Icons.place;
        // Finance & Analytics
        case 'Icons.bar_chart': return Icons.bar_chart;
        case 'Icons.pie_chart': return Icons.pie_chart;
        case 'Icons.trending_up': return Icons.trending_up;
        case 'Icons.dashboard': return Icons.dashboard;
        case 'Icons.dashboard_customize': return Icons.dashboard_customize;
        // Security & Auth
        case 'Icons.lock': return Icons.lock;
        case 'Icons.lock_outline': return Icons.lock_outline;
        case 'Icons.security': return Icons.security;
        case 'Icons.verified_user': return Icons.verified_user;
        case 'Icons.privacy_tip_outlined': return Icons.privacy_tip_outlined;
        // Actions
        case 'Icons.edit': return Icons.edit;
        case 'Icons.edit_outlined': return Icons.edit_outlined;
        case 'Icons.delete': return Icons.delete;
        case 'Icons.delete_outline': return Icons.delete_outline;
        case 'Icons.share': return Icons.share;
        case 'Icons.download': return Icons.download;
        case 'Icons.upload': return Icons.upload;
        case 'Icons.visibility': return Icons.visibility;
        case 'Icons.visibility_off': return Icons.visibility_off;
        case 'Icons.check': return Icons.check;
        case 'Icons.check_circle': return Icons.check_circle;
        case 'Icons.done': return Icons.done;
        // Media
        case 'Icons.play_arrow': return Icons.play_arrow;
        case 'Icons.pause': return Icons.pause;
        case 'Icons.skip_next': return Icons.skip_next;
        case 'Icons.music_note': return Icons.music_note;
        case 'Icons.image': return Icons.image;
        case 'Icons.photo_camera': return Icons.photo_camera;
        // Time
        case 'Icons.access_time': return Icons.access_time;
        case 'Icons.calendar_today': return Icons.calendar_today;
        case 'Icons.schedule': return Icons.schedule;
        // Ratings & Social
        case 'Icons.star': return Icons.star;
        case 'Icons.star_border': return Icons.star_border;
        case 'Icons.favorite': return Icons.favorite;
        case 'Icons.favorite_border': return Icons.favorite_border;
        case 'Icons.thumb_up': return Icons.thumb_up;
        // Misc
        case 'Icons.palette_outlined': return Icons.palette_outlined;
        case 'Icons.language': return Icons.language;
        case 'Icons.dark_mode': return Icons.dark_mode;
        case 'Icons.light_mode': return Icons.light_mode;
        case 'Icons.wb_sunny': return Icons.wb_sunny;
        case 'Icons.auto_awesome': return Icons.auto_awesome;
      }
    }
    return Icons.widgets; // fallback icon instead of null
  }

  String resolveDataBinding(WidgetNode node, String defaultValue) {
    final binding = node.properties['dataBinding'] as Map<String, dynamic>?;
    if (binding == null || binding['field'] == null || binding['field'].toString().isEmpty) {
      return defaultValue;
    }
    // For now, return a placeholder indicating what's bound
    return '{${binding['field']}}';
  }
}