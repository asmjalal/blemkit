import 'package:flutter/material.dart';

class ColorUtils {
  static Color parseColor(dynamic value, [dynamic themeOrColor, Color? defaultColor]) {
    Color def = defaultColor ?? Colors.transparent;
    Map<String, dynamic>? theme;
    
    if (themeOrColor is Map<String, dynamic>) {
      theme = themeOrColor;
    } else if (themeOrColor is Color) {
      def = themeOrColor;
    }

    if (value == null) return def;
    
    if (value is int) {
      return Color(value);
    }
    
    if (value is String) {
      // Handle semantic theme tokens (primaryColor, accentColor, etc)
      if (theme != null && theme.containsKey(value)) {
        return parseColor(theme[value], null, def);
      }

      // Handle decimal integer strings
      final int? parsedInt = int.tryParse(value);
      if (parsedInt != null) {
        return Color(parsedInt);
      }
      
      // Handle hex strings (0x...)
      if (value.startsWith('0x')) {
        try {
          return Color(int.parse(value));
        } catch (_) {
          return def;
        }
      }
      
      // Handle hex strings (#...)
      if (value.startsWith('#')) {
        try {
          final hex = value.replaceAll('#', '');
          return Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
        } catch (_) {
          return def;
        }
      }
      
      // Handle predefined colors (e.g., "Colors.white")
      switch (value) {
        case 'Colors.white': return Colors.white;
        case 'Colors.black': return Colors.black;
        case 'Colors.blue': return Colors.blue;
        case 'Colors.red': return Colors.red;
        case 'Colors.green': return Colors.green;
        case 'Colors.yellow': return Colors.yellow;
        case 'Colors.purple': return Colors.purple;
        case 'Colors.orange': return Colors.orange;
        case 'Colors.grey': return Colors.grey;
        case 'Colors.transparent': return Colors.transparent;
        case 'Colors.deepPurple': return Colors.deepPurple;
        case 'Colors.deepPurpleAccent': return Colors.deepPurpleAccent;
        case 'Colors.black26': return Colors.black26;
        case 'Colors.lightBlueAccent': return Colors.lightBlueAccent;
        case 'Colors.redAccent': return Colors.redAccent;
        case 'primaryColor': return Colors.indigo; // Fallbacks if no theme provided
        case 'accentColor': return Colors.indigoAccent;
      }
    }
    
    return def;
  }
}
