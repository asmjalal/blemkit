import 'package:flutter/material.dart';

Widget buildNumberField(
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
      keyboardType: TextInputType.number,
      controller: TextEditingController(text: value),
      onChanged: onChanged,
    ),
  );
} 