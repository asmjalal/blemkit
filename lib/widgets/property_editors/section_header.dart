import 'package:flutter/material.dart';

Widget buildSectionHeader(String text) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF94A3B8), // Slate 400
        letterSpacing: 1.1,
      ),
    ),
  );
} 