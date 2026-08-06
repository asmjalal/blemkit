import 'package:flutter/material.dart';
import '../utils/color_utils.dart';

class ThemeGenerator {
  static String generateThemeCode(Map<String, dynamic> themeProps) {
    final primaryHex = themeProps['primaryColor'] ?? '0xFF0fadd5';
    final secondaryHex = themeProps['secondaryColor'] ?? '0xFF10B981';
    final tertiaryHex = themeProps['tertiaryColor'] ?? '0xFFF59E0B';
    final alternateHex = themeProps['alternateColor'] ?? '0xFF64748B';
    
    final bgHex = themeProps['scaffoldBackgroundColor'] ?? '0xFFF8FAFC';
    final cardHex = themeProps['backgroundColor'] ?? '0xFFFFFFFF';
    final successHex = themeProps['successColor'] ?? '0xFF22C55E';
    final errorHex = themeProps['errorColor'] ?? '0xFFEF4444';
    final warningHex = themeProps['warningColor'] ?? '0xFFF59E0B';
    final infoHex = themeProps['infoColor'] ?? '0xFF3B82F6';
    
    final isM3 = themeProps['useMaterial3'] ?? true;
    final fontFamily = themeProps['fontFamily'] ?? 'Outfit';

    // Generate text style entries
    String _textStyleCode(String name, Map? style) {
      if (style == null) return '';
      final fontSize = style['fontSize'] ?? 14.0;
      final fontWeight = _fontWeightToCode(style['fontWeight']);
      final letterSpacing = style['letterSpacing'] ?? 0.0;
      return '''
        $name: TextStyle(
          fontFamily: fontFamily,
          fontSize: $fontSize,
          fontWeight: $fontWeight,
          letterSpacing: $letterSpacing,
        ),''';
    }

    final textStyles = <String>[];
    for (final role in [
      'displayLarge', 'displayMedium', 'displaySmall',
      'headlineLarge', 'headlineMedium', 'headlineSmall',
      'titleLarge', 'titleMedium', 'titleSmall',
      'labelLarge',
      'bodyLarge', 'bodyMedium', 'bodySmall',
    ]) {
      final style = themeProps[role] as Map?;
      if (style != null) {
        textStyles.add(_textStyleCode(role, style));
      }
    }

    final textThemeBlock = textStyles.isNotEmpty
        ? '''textTheme: const TextTheme(
${textStyles.join('\n')}
      ),'''
        : '';

    return '''
import 'package:flutter/material.dart';

class AppTheme {
  // Design Tokens - Brand Colors
  static const Color primary = Color($primaryHex);
  static const Color secondary = Color($secondaryHex);
  static const Color tertiary = Color($tertiaryHex);
  static const Color alternate = Color($alternateHex);
  
  // Design Tokens - Semantic & Utility
  static const Color background = Color($bgHex);
  static const Color cardBackground = Color($cardHex);
  static const Color success = Color($successHex);
  static const Color error = Color($errorHex);
  static const Color warning = Color($warningHex);
  static const Color info = Color($infoHex);
  
  // Design Tokens - Typography
  static const String fontFamily = '$fontFamily';

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: $isM3,
      primaryColor: primary,
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: cardBackground,
        error: error,
      ),
      fontFamily: fontFamily,
      $textThemeBlock
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? primary : alternate),
        trackColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? primary.withOpacity(0.5) : alternate.withOpacity(0.3)),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
          states.contains(WidgetState.selected) ? primary : Colors.transparent),
        checkColor: WidgetStateProperty.all(Colors.white),
      ),
    );
  }
}
''';
  }

  static String _fontWeightToCode(dynamic weight) {
    if (weight == null) return 'FontWeight.normal';
    if (weight is String) {
      switch (weight) {
        case 'Bold': return 'FontWeight.bold';
        case 'Medium': return 'FontWeight.w500';
        case 'Light': return 'FontWeight.w300';
        case 'Thin': return 'FontWeight.w100';
        default: return 'FontWeight.normal';
      }
    }
    return 'FontWeight.normal';
  }

  /// Helper to convert a hex color string to an AppTheme constant if it matches
  static String mapColorToToken(String? hex, Map<String, dynamic> themeProps) {
    if (hex == null) return 'null';
    
    if (hex == themeProps['primaryColor']) return 'AppTheme.primary';
    if (hex == themeProps['secondaryColor']) return 'AppTheme.secondary';
    if (hex == themeProps['tertiaryColor']) return 'AppTheme.tertiary';
    if (hex == themeProps['alternateColor']) return 'AppTheme.alternate';
    if (hex == themeProps['scaffoldBackgroundColor']) return 'AppTheme.background';
    if (hex == themeProps['backgroundColor']) return 'AppTheme.cardBackground';
    if (hex == themeProps['successColor']) return 'AppTheme.success';
    if (hex == themeProps['errorColor']) return 'AppTheme.error';
    if (hex == themeProps['warningColor']) return 'AppTheme.warning';
    if (hex == themeProps['infoColor']) return 'AppTheme.info';
    
    return 'Color($hex)';
  }
}

