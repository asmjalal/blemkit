import 'package:flutter/material.dart';

/// Colors of the SynappKit editor chrome (not of the app being designed).
class EditorColors {
  static const Color background = Color(0xFF0B1020);
  static const Color canvas = Color(0xFF0E1426);
  static const Color surface = Color(0xFF121A2E);
  static const Color surfaceRaised = Color(0xFF18223A);
  static const Color surfaceHover = Color(0xFF1F2A44);
  static const Color border = Color(0xFF232E48);
  static const Color borderStrong = Color(0xFF33405E);

  static const Color text = Color(0xFFE6EBF5);
  static const Color textMuted = Color(0xFF94A0B8);
  static const Color textFaint = Color(0xFF5F6B85);

  static const Color accent = Color(0xFF22B8E6);
  static const Color accentSoft = Color(0x2622B8E6);
  static const Color violet = Color(0xFF8B7CF6);
  static const Color success = Color(0xFF34D399);
  static const Color warning = Color(0xFFFBBF24);
  static const Color danger = Color(0xFFF87171);

  /// Selection outline on the canvas.
  static const Color selection = Color(0xFF22B8E6);
  static const Color hover = Color(0x8022B8E6);
}

class EditorTheme {
  static const double radius = 8;

  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.dark(
        primary: EditorColors.accent,
        onPrimary: Color(0xFF04121A),
        secondary: EditorColors.violet,
        surface: EditorColors.surface,
        onSurface: EditorColors.text,
        error: EditorColors.danger,
        outline: EditorColors.border,
        outlineVariant: EditorColors.border,
        surfaceContainerHighest: EditorColors.surfaceRaised,
        surfaceContainerHigh: EditorColors.surfaceRaised,
        surfaceContainer: EditorColors.surface,
      ),
      scaffoldBackgroundColor: EditorColors.background,
      canvasColor: EditorColors.surface,
      dividerColor: EditorColors.border,
      visualDensity: VisualDensity.compact,
    );

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: const BorderSide(color: EditorColors.border),
    );

    return base.copyWith(
      textTheme: base.textTheme
          .apply(bodyColor: EditorColors.text, displayColor: EditorColors.text)
          .copyWith(
            bodyLarge: const TextStyle(fontSize: 13.5, color: EditorColors.text),
            bodyMedium: const TextStyle(fontSize: 13, color: EditorColors.text),
            bodySmall: const TextStyle(fontSize: 12, color: EditorColors.textMuted),
            titleMedium: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: EditorColors.text),
            labelLarge: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
      dividerTheme: const DividerThemeData(color: EditorColors.border, space: 1, thickness: 1),
      inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: EditorColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        labelStyle: const TextStyle(fontSize: 12.5, color: EditorColors.textMuted),
        floatingLabelStyle: const TextStyle(fontSize: 12.5, color: EditorColors.accent),
        hintStyle: const TextStyle(fontSize: 13, color: EditorColors.textFaint),
        helperStyle: const TextStyle(fontSize: 11.5, color: EditorColors.textFaint),
        prefixIconColor: EditorColors.textMuted,
        suffixIconColor: EditorColors.textMuted,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(borderSide: const BorderSide(color: EditorColors.accent, width: 1.4)),
        errorBorder: border.copyWith(borderSide: const BorderSide(color: EditorColors.danger)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: EditorColors.accent,
          foregroundColor: const Color(0xFF04121A),
          elevation: 0,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: EditorColors.accent,
          foregroundColor: const Color(0xFF04121A),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: EditorColors.text,
          side: const BorderSide(color: EditorColors.borderStrong),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, fontFamily: 'Inter'),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: EditorColors.accent,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: EditorColors.textMuted,
          hoverColor: EditorColors.surfaceHover,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: EditorColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: EditorColors.border),
        ),
        titleTextStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: EditorColors.text, fontFamily: 'Inter'),
        contentTextStyle: const TextStyle(fontSize: 13.5, color: EditorColors.textMuted, fontFamily: 'Inter', height: 1.45),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: EditorColors.surfaceRaised,
        surfaceTintColor: Colors.transparent,
        textStyle: const TextStyle(fontSize: 13, color: EditorColors.text, fontFamily: 'Inter'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: EditorColors.border),
        ),
      ),
      menuTheme: const MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(EditorColors.surfaceRaised),
          surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      dropdownMenuTheme: const DropdownMenuThemeData(
        textStyle: TextStyle(fontSize: 13, color: EditorColors.text, fontFamily: 'Inter'),
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 400),
        textStyle: const TextStyle(fontSize: 12, color: EditorColors.text, fontFamily: 'Inter'),
        decoration: BoxDecoration(
          color: EditorColors.surfaceRaised,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: EditorColors.borderStrong),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: EditorColors.surfaceRaised,
        contentTextStyle: const TextStyle(fontSize: 13, color: EditorColors.text, fontFamily: 'Inter'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: EditorColors.border),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? Colors.white : EditorColors.textMuted),
        trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? EditorColors.accent : EditorColors.surfaceHover),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? EditorColors.accent : Colors.transparent),
        side: const BorderSide(color: EditorColors.borderStrong, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: EditorColors.text,
        unselectedLabelColor: EditorColors.textMuted,
        indicatorColor: EditorColors.accent,
        dividerColor: Colors.transparent,
        labelStyle: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, fontFamily: 'Inter'),
        unselectedLabelStyle: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, fontFamily: 'Inter'),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(EditorColors.borderStrong.withValues(alpha: 0.8)),
        thickness: const WidgetStatePropertyAll(6),
        radius: const Radius.circular(6),
      ),
      listTileTheme: const ListTileThemeData(
        dense: true,
        iconColor: EditorColors.textMuted,
        textColor: EditorColors.text,
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        iconColor: EditorColors.textMuted,
        collapsedIconColor: EditorColors.textMuted,
        shape: Border(),
        collapsedShape: Border(),
      ),
    );
  }
}
