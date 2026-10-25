
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

    String hex(String key, String fallback) {
      final argb = parseArgb(themeProps[key] ?? fallback) ?? parseArgb(fallback)!;
      return '0x${argb.toRadixString(16).padLeft(8, '0').toUpperCase()}';
    }

    final darkPrimary = hex('dark_primaryColor', '$primaryHex');
    final darkBg = hex('dark_scaffoldBackgroundColor', '0xFF0B1120');
    final darkCard = hex('dark_backgroundColor', '0xFF111827');
    final darkText = hex('dark_primaryText', '0xFFF1F5F9');
    final darkSecondaryText = hex('dark_secondaryText', '0xFF94A3B8');
    final primaryText = hex('primaryText', '0xFF0F172A');
    final secondaryText = hex('secondaryText', '0xFF64748B');

    num token(String key, num fallback) => themeProps[key] is num ? themeProps[key] as num : fallback;

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
        ? '''textTheme: _textTheme(const TextTheme(
${textStyles.join('\n')}
      )),'''
        : 'textTheme: _textTheme(const TextTheme()),';

    return '''
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  
  static const Color primaryText = Color($primaryText);
  static const Color secondaryText = Color($secondaryText);

  // Dark mode tokens
  static const Color darkPrimary = Color($darkPrimary);
  static const Color darkBackground = Color($darkBg);
  static const Color darkCardBackground = Color($darkCard);
  static const Color darkPrimaryText = Color($darkText);
  static const Color darkSecondaryText = Color($darkSecondaryText);

  // Spacing & radius tokens
  static const double spacingXs = ${token('spacingXs', 4)};
  static const double spacingSm = ${token('spacingSm', 8)};
  static const double spacingMd = ${token('spacingMd', 16)};
  static const double spacingLg = ${token('spacingLg', 24)};
  static const double spacingXl = ${token('spacingXl', 32)};
  static const double radiusSm = ${token('radiusSm', 8)};
  static const double radiusMd = ${token('radiusMd', 12)};
  static const double radiusLg = ${token('radiusLg', 20)};

  // Design Tokens - Typography (loaded with google_fonts when available)
  static const String fontFamily = '$fontFamily';

  static String? get _fontFamily {
    try {
      return GoogleFonts.getFont(fontFamily).fontFamily;
    } catch (_) {
      return fontFamily;
    }
  }

  static TextTheme _textTheme(TextTheme base) {
    try {
      return GoogleFonts.getTextTheme(fontFamily, base);
    } catch (_) {
      return base;
    }
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: $isM3,
      brightness: Brightness.dark,
      primaryColor: darkPrimary,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: darkPrimary,
        brightness: Brightness.dark,
        primary: darkPrimary,
        secondary: secondary,
        tertiary: tertiary,
        surface: darkCardBackground,
        error: error,
      ),
      fontFamily: _fontFamily,
      textTheme: _textTheme(ThemeData(brightness: Brightness.dark).textTheme).apply(bodyColor: darkPrimaryText, displayColor: darkPrimaryText),
      cardTheme: CardThemeData(
        color: darkCardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusLg)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCardBackground,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radiusMd)),
      ),
    );
  }

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
      fontFamily: _fontFamily,
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
          states.contains(WidgetState.selected) ? primary.withValues(alpha: 0.5) : alternate.withValues(alpha: 0.3)),
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
  static const Map<String, String> _tokenGetters = {
    'primaryColor': 'AppTheme.primary',
    'secondaryColor': 'AppTheme.secondary',
    'tertiaryColor': 'AppTheme.tertiary',
    'alternateColor': 'AppTheme.alternate',
    'scaffoldBackgroundColor': 'AppTheme.background',
    'backgroundColor': 'AppTheme.cardBackground',
    'successColor': 'AppTheme.success',
    'errorColor': 'AppTheme.error',
    'warningColor': 'AppTheme.warning',
    'infoColor': 'AppTheme.info',
  };

  /// The generated `AppTheme` getter for a theme color key such as `primaryColor`.
  static String? tokenForKey(String key) => _tokenGetters[key];

  /// Parses ints, decimal strings, `0xAARRGGBB`, `#RRGGBB` and `#AARRGGBB`.
  static int? parseArgb(dynamic value) {
    if (value is int) return value & 0xFFFFFFFF;
    if (value is! String) return null;
    final s = value.trim();
    final decimal = int.tryParse(s);
    if (decimal != null) return decimal & 0xFFFFFFFF;
    var hex = s.startsWith('0x') || s.startsWith('0X') ? s.substring(2) : s.startsWith('#') ? s.substring(1) : s;
    if (!RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex)) return null;
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length != 8) return null;
    return int.parse(hex, radix: 16);
  }

  static String mapColorToToken(String? hex, Map<String, dynamic> themeProps) {
    if (hex == null) return 'null';
    final argb = parseArgb(hex);
    if (argb == null) return 'Colors.transparent';
    for (final entry in _tokenGetters.entries) {
      if (parseArgb(themeProps[entry.key]) == argb) return entry.value;
    }
    return 'Color(0x${argb.toRadixString(16).padLeft(8, '0').toUpperCase()})';
  }
}
