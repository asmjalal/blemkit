import 'package:flutter/material.dart';

class EdgeInsetsEditor extends StatelessWidget {
  final String label;
  final double top;
  final double bottom;
  final double left;
  final double right;
  final ValueChanged<Map<String, double>> onChanged;

  const EdgeInsetsEditor({
    super.key,
    required this.label,
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final controllerTop = TextEditingController(text: top.toStringAsFixed(1));
    final controllerBottom = TextEditingController(text: bottom.toStringAsFixed(1));
    final controllerLeft = TextEditingController(text: left.toStringAsFixed(1));
    final controllerRight = TextEditingController(text: right.toStringAsFixed(1));

    void update() {
      onChanged({
        'top': double.tryParse(controllerTop.text) ?? 0.0,
        'bottom': double.tryParse(controllerBottom.text) ?? 0.0,
        'left': double.tryParse(controllerLeft.text) ?? 0.0,
        'right': double.tryParse(controllerRight.text) ?? 0.0,
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))),
        const SizedBox(height: 4),
        Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 48),
                  SizedBox(
                    width: 48,
                    child: TextField(
                      controller: controllerTop,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Top', isDense: true),
                      onChanged: (_) => update(),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 48,
                    child: TextField(
                      controller: controllerLeft,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Left', isDense: true),
                      onChanged: (_) => update(),
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(''),
                  ),
                  SizedBox(
                    width: 48,
                    child: TextField(
                      controller: controllerRight,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Right', isDense: true),
                      onChanged: (_) => update(),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 48),
                  SizedBox(
                    width: 48,
                    child: TextField(
                      controller: controllerBottom,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Bottom', isDense: true),
                      onChanged: (_) => update(),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class VisualEdgeInsetsEditor extends StatefulWidget {
  final double top, right, bottom, left;
  final bool linked;
  final bool isMargin;
  final ValueChanged<EdgeInsets> onChanged;
  final ValueChanged<bool> onLinkChanged;
  final String label;

  const VisualEdgeInsetsEditor({
    Key? key,
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
    required this.linked,
    required this.onChanged,
    required this.onLinkChanged,
    this.isMargin = false,
    this.label = 'Padding',
  }) : super(key: key);

  @override
  State<VisualEdgeInsetsEditor> createState() => _VisualEdgeInsetsEditorState();
}

class _VisualEdgeInsetsEditorState extends State<VisualEdgeInsetsEditor> {
  late double top, right, bottom, left;
  late bool linked;
  bool allMode = true;
  final accent = const Color(0xFF4a9eff);

  @override
  void initState() {
    super.initState();
    top = widget.top;
    right = widget.right;
    bottom = widget.bottom;
    left = widget.left;
    linked = widget.linked;
  }

  void _updateAll(double value) {
    setState(() {
      top = right = bottom = left = value;
      widget.onChanged(EdgeInsets.only(top: top, right: right, bottom: bottom, left: left));
    });
  }

  void _updateSide(String side, double value) {
    setState(() {
      switch (side) {
        case 'top': top = value; break;
        case 'right': right = value; break;
        case 'bottom': bottom = value; break;
        case 'left': left = value; break;
      }
      widget.onChanged(EdgeInsets.only(top: top, right: right, bottom: bottom, left: left));
    });
  }

  @override
  Widget build(BuildContext context) {
    final boxSize = 140.0;
    final inputSize = 32.0;
    final borderRadius = 16.0;
    final bgColor = const Color(0xFF23263a);
    final fgColor = Colors.white;
    final borderColor = Colors.grey.shade700;
    final activeColor = accent;
    final inactiveColor = Colors.grey.shade600;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(widget.label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18)),
              const SizedBox(width: 12),
              ToggleButtons(
                borderRadius: BorderRadius.circular(8),
                selectedColor: Colors.white,
                fillColor: accent.withOpacity(0.2),
                color: inactiveColor,
                isSelected: [allMode, !allMode],
                onPressed: (i) => setState(() => allMode = i == 0),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('All', style: TextStyle(color: allMode ? accent : inactiveColor)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Sides', style: TextStyle(color: !allMode ? accent : inactiveColor)),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: Icon(linked ? Icons.link : Icons.link_off, color: linked ? accent : inactiveColor),
                tooltip: linked ? 'Unlink sides' : 'Link all sides',
                onPressed: () {
                  setState(() {
                    linked = !linked;
                    widget.onLinkChanged(linked);
                    if (linked) {
                      final v = top;
                      top = right = bottom = left = v;
                      widget.onChanged(EdgeInsets.only(top: v, right: v, bottom: v, left: v));
                    }
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: SizedBox(
              width: boxSize,
              height: boxSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Outer dashed rectangle
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _DashedRectPainter(color: accent, borderRadius: borderRadius),
                    ),
                  ),
                  // Inner solid rectangle
                  Positioned(
                    left: 36,
                    top: 36,
                    right: 36,
                    bottom: 36,
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderColor, width: 2),
                      ),
                    ),
                  ),
                  // Measurement lines (top, right, bottom, left)
                  _measurementLine(boxSize, 'top', accent),
                  _measurementLine(boxSize, 'right', accent),
                  _measurementLine(boxSize, 'bottom', accent),
                  _measurementLine(boxSize, 'left', accent),
                  // Input fields
                  if (allMode)
                    Positioned(
                      left: boxSize / 2 - inputSize / 2,
                      bottom: -inputSize - 8,
                      width: inputSize,
                      child: _inputField('all', top, (v) => _updateAll(v)),
                    )
                  else ...[
                    Positioned(
                      left: boxSize / 2 - inputSize / 2,
                      top: -inputSize - 8,
                      width: inputSize,
                      child: _inputField('top', top, (v) => _updateSide('top', v)),
                    ),
                    Positioned(
                      right: -inputSize - 8,
                      top: boxSize / 2 - inputSize / 2,
                      width: inputSize,
                      child: _inputField('right', right, (v) => _updateSide('right', v)),
                    ),
                    Positioned(
                      left: boxSize / 2 - inputSize / 2,
                      bottom: -inputSize - 8,
                      width: inputSize,
                      child: _inputField('bottom', bottom, (v) => _updateSide('bottom', v)),
                    ),
                    Positioned(
                      left: -inputSize - 8,
                      top: boxSize / 2 - inputSize / 2,
                      width: inputSize,
                      child: _inputField('left', left, (v) => _updateSide('left', v)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              allMode
                  ? 'All sides: ${top.toStringAsFixed(0)}px'
                  : 'Top: ${top.toStringAsFixed(0)}  Right: ${right.toStringAsFixed(0)}  Bottom: ${bottom.toStringAsFixed(0)}  Left: ${left.toStringAsFixed(0)}',
              style: TextStyle(color: fgColor.withOpacity(0.8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String side, double value, ValueChanged<double> onChanged) {
    return Container(
      height: 32,
      width: 32,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4a9eff), width: 2),
      ),
      child: Center(
        child: TextField(
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.zero,
          ),
          keyboardType: TextInputType.number,
          onChanged: (val) {
            final parsed = double.tryParse(val) ?? 0.0;
            onChanged(parsed);
          },
        ),
      ),
    );
  }

  Widget _measurementLine(double boxSize, String side, Color color) {
    switch (side) {
      case 'top':
        return Positioned(
          left: 36,
          right: 36,
          top: 24,
          child: Container(height: 2, color: color.withOpacity(0.5)),
        );
      case 'right':
        return Positioned(
          right: 24,
          top: 36,
          bottom: 36,
          child: Container(width: 2, color: color.withOpacity(0.5)),
        );
      case 'bottom':
        return Positioned(
          left: 36,
          right: 36,
          bottom: 24,
          child: Container(height: 2, color: color.withOpacity(0.5)),
        );
      case 'left':
        return Positioned(
          left: 24,
          top: 36,
          bottom: 36,
          child: Container(width: 2, color: color.withOpacity(0.5)),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  _DashedRectPainter({required this.color, this.borderRadius = 16});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final len = (distance + dashWidth < metric.length) ? dashWidth : metric.length - distance;
        canvas.drawPath(metric.extractPath(distance, distance + len), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 