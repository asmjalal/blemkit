import 'package:flutter/material.dart';

/// Device frames the canvas can preview. Sizes are logical pixels.
class DevicePreset {
  final String id;
  final String label;
  final IconData icon;
  final Size size;
  final double radius;
  final bool hasNotch;
  final bool isDesktop;

  const DevicePreset(this.id, this.label, this.icon, this.size, {this.radius = 0, this.hasNotch = false, this.isDesktop = false});

  String get breakpoint => size.width < 600 ? 'phone' : size.width < 1024 ? 'tablet' : 'desktop';
}

class DevicePresets {
  static const List<DevicePreset> all = [
    DevicePreset('iphone15', 'iPhone 15', Icons.phone_iphone_rounded, Size(393, 852), radius: 52, hasNotch: true),
    DevicePreset('pixel8', 'Pixel 8', Icons.smartphone_rounded, Size(412, 915), radius: 40),
    DevicePreset('iphoneSE', 'iPhone SE', Icons.phone_android_rounded, Size(375, 667), radius: 28),
    DevicePreset('ipad', 'iPad', Icons.tablet_mac_rounded, Size(820, 1180), radius: 28),
    DevicePreset('desktop', 'Desktop', Icons.desktop_windows_outlined, Size(1280, 800), radius: 12, isDesktop: true),
  ];

  static DevicePreset byId(String id) => all.firstWhere((d) => d.id == id, orElse: () => all.first);
}
