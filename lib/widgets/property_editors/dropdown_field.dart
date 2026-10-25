import 'package:flutter/material.dart';
import '../../ui/editor_theme.dart';

Widget buildDropdownField(
  String label,
  String value,
  List<String> items,
  ValueChanged<String> onChanged,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: EditorColors.textMuted, fontSize: 11, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: EditorColors.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              dropdownColor: EditorColors.surfaceRaised,
              style: const TextStyle(color: Colors.white, fontSize: 11),
              icon: const Icon(Icons.expand_more, size: 16, color: Colors.white38),
              value: value,
              items: (() {
                final effectiveItems = List<String>.from(items);
                if (value != null && !effectiveItems.contains(value)) {
                  effectiveItems.add(value);
                }
                return effectiveItems.map((item) {
                  return DropdownMenuItem(
                    value: item,
                    child: Text(item, overflow: TextOverflow.ellipsis),
                  );
                }).toList();
              })(),
              onChanged: (val) {
                if (val != null) onChanged(val);
              },
            ),
          ),
        ),
      ],
    ),
  );
}
 