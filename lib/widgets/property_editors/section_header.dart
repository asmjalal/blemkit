import 'package:flutter/material.dart';
import '../../ui/editor_theme.dart';

Widget buildSectionHeader(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: EditorColors.textMuted, // Slate 400
        letterSpacing: 1.1,
      ),
    ),
  );
} 