import 'package:flutter/material.dart';

Widget buildNumericPropertyField({
  required String label,
  required String value,
  required ValueChanged<String> onChanged,
  String? unit,
  ValueChanged<String>? onUnitChanged,
  bool isReadOnly = false,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          if (unit != null)
            GestureDetector(
              onTap: () {
                if (onUnitChanged != null) {
                  final newUnit = unit == 'PX' ? '%' : 'PX';
                  onUnitChanged(newUnit);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  unit,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      const SizedBox(height: 6),
      Container(
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: TextField(
          controller: TextEditingController(text: value)..selection = TextSelection.collapsed(offset: value.length),
          readOnly: isReadOnly,
          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
          decoration: const InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            suffixIcon: Icon(Icons.all_inclusive, size: 14, color: Colors.white24),
            suffixIconConstraints: BoxConstraints(minWidth: 30),
          ),
          onChanged: onChanged,
        ),
      ),
    ],
  );
}

Widget buildPropertyRow(List<Widget> children) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      children: [
        for (int i = 0; i < children.length; i++) ...[
          Expanded(child: children[i]),
          if (i < children.length - 1) const SizedBox(width: 12),
        ],
      ],
    ),
  );
}
