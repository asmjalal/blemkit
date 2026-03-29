import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerField extends StatefulWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const ColorPickerField({
    super.key,
    required this.label,
    required this.color,
    required this.onColorChanged,
  });

  @override
  State<ColorPickerField> createState() => _ColorPickerFieldState();
}

class _ColorPickerFieldState extends State<ColorPickerField> {
  late TextEditingController _hexController;

  @override
  void initState() {
    super.initState();
    _hexController = TextEditingController(
      text: '#${widget.color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}',
    );
  }

  @override
  void didUpdateWidget(ColorPickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _hexController.text = '#${widget.color.value.toRadixString(16).padLeft(8, '0').toUpperCase()}';
      });
    }
  }

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _onHexChanged(String value) {
    String hex = value.trim().replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex'; // Add alpha if missing
    if (hex.length == 8) {
      final intColor = int.tryParse(hex, radix: 16);
      if (intColor != null) {
        widget.onColorChanged(Color(intColor));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            GestureDetector(
              onTap: () async {
                Color startColor = widget.color.alpha == 0 ? Colors.white : widget.color;
                Color picked = startColor;
                final Color originalColor = widget.color;
                widget.onColorChanged(picked);
                
                await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Pick a color'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ColorPicker(
                            pickerColor: startColor,
                            onColorChanged: (c) {
                              picked = c;
                              _hexController.text = '#${c.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
                              widget.onColorChanged(c);
                            },
                            enableAlpha: true,
                            showLabel: false,
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _hexController,
                            decoration: const InputDecoration(
                              labelText: 'HEX',
                              prefixText: '#',
                              border: OutlineInputBorder(),
                            ),
                            maxLength: 8,
                            onChanged: (value) {
                              final hex = value.replaceAll('#', '').replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
                              if (hex.length == 6 || hex.length == 8) {
                                try {
                                  picked = Color(int.parse(hex.length == 6 ? 'FF$hex' : hex, radix: 16));
                                  widget.onColorChanged(picked);
                                } catch (_) {}
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(onPressed: () { widget.onColorChanged(originalColor); Navigator.pop(context); }, child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Select')),
                    ],
                  ),
                );
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: widget.color,
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                ),
                child: TextField(
                  controller: _hexController,
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  ),
                  onSubmitted: _onHexChanged,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
} 