import 'package:flutter/material.dart';

class PaddingPropertyEditor extends StatelessWidget {
  final double paddingTop;
  final double paddingRight;
  final double paddingBottom;
  final double paddingLeft;
  final ValueChanged<Map<String, double>> onChanged;

  const PaddingPropertyEditor({
    Key? key,
    required this.paddingTop,
    required this.paddingRight,
    required this.paddingBottom,
    required this.paddingLeft,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void update(String side, double value) {
      onChanged({
        'paddingTop': side == 'top' ? value : paddingTop,
        'paddingRight': side == 'right' ? value : paddingRight,
        'paddingBottom': side == 'bottom' ? value : paddingBottom,
        'paddingLeft': side == 'left' ? value : paddingLeft,
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Padding', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _sideField('Top', paddingTop, (v) => update('top', v)),
            _sideField('Right', paddingRight, (v) => update('right', v)),
            _sideField('Bottom', paddingBottom, (v) => update('bottom', v)),
            _sideField('Left', paddingLeft, (v) => update('left', v)),
          ],
        ),
      ],
    );
  }

  Widget _sideField(String label, double value, ValueChanged<double> onChanged) {
    return SizedBox(
      width: 60,
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: TextInputType.number,
        controller: TextEditingController(text: value.toStringAsFixed(0)),
        onChanged: (val) {
          final parsed = double.tryParse(val) ?? 0.0;
          onChanged(parsed);
        },
      ),
    );
  }
} 