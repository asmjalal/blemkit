import 'package:flutter/material.dart';

Widget buildSliderField(
  String label,
  double value,
  double min,
  double max,
  ValueChanged<double> onChanged,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0),
    child: Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: const Color(0xFF0fadd5),
              inactiveTrackColor: Colors.white.withOpacity(0.05),
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 45,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            controller: TextEditingController(text: value.toStringAsFixed(0))..selection = TextSelection.collapsed(offset: value.toStringAsFixed(0).length),
            style: const TextStyle(color: Colors.white, fontSize: 11),
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 6),
            ),
            keyboardType: TextInputType.number,
            onSubmitted: (val) {
              final d = double.tryParse(val);
              if (d != null) onChanged(d.clamp(min, max));
            },
          ),
        ),
      ],
    ),
  );
}