import 'package:flutter/material.dart';

Widget buildTextField(
  String label,
  String value,
  ValueChanged<String> onChanged,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: TextField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    ),
  );
} 