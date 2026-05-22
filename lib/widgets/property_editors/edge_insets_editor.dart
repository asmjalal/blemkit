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

  late TextEditingController _controllerAll;
  late TextEditingController _controllerTop;
  late TextEditingController _controllerRight;
  late TextEditingController _controllerBottom;
  late TextEditingController _controllerLeft;

  @override
  void initState() {
    super.initState();
    top = widget.top;
    right = widget.right;
    bottom = widget.bottom;
    left = widget.left;
    linked = widget.linked;

    _controllerAll = TextEditingController(text: top.toStringAsFixed(0));
    _controllerTop = TextEditingController(text: top.toStringAsFixed(0));
    _controllerRight = TextEditingController(text: right.toStringAsFixed(0));
    _controllerBottom = TextEditingController(text: bottom.toStringAsFixed(0));
    _controllerLeft = TextEditingController(text: left.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _controllerAll.dispose();
    _controllerTop.dispose();
    _controllerRight.dispose();
    _controllerBottom.dispose();
    _controllerLeft.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VisualEdgeInsetsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.top != widget.top ||
        oldWidget.right != widget.right ||
        oldWidget.bottom != widget.bottom ||
        oldWidget.left != widget.left ||
        oldWidget.linked != widget.linked) {
      setState(() {
        top = widget.top;
        right = widget.right;
        bottom = widget.bottom;
        left = widget.left;
        linked = widget.linked;
        _syncControllers();
      });
    }
  }

  void _syncControllers() {
    _controllerAll.text = top.toStringAsFixed(0);
    _controllerTop.text = top.toStringAsFixed(0);
    _controllerRight.text = right.toStringAsFixed(0);
    _controllerBottom.text = bottom.toStringAsFixed(0);
    _controllerLeft.text = left.toStringAsFixed(0);
  }

  void _updateAll(double value, {TextEditingController? source}) {
    setState(() {
      top = right = bottom = left = value;
      if (source != _controllerAll) _controllerAll.text = value.toStringAsFixed(0);
      if (source != _controllerTop) _controllerTop.text = value.toStringAsFixed(0);
      if (source != _controllerRight) _controllerRight.text = value.toStringAsFixed(0);
      if (source != _controllerBottom) _controllerBottom.text = value.toStringAsFixed(0);
      if (source != _controllerLeft) _controllerLeft.text = value.toStringAsFixed(0);
      widget.onChanged(EdgeInsets.only(top: top, right: right, bottom: bottom, left: left));
    });
  }

  void _updateSide(String side, double value, {required TextEditingController source}) {
    setState(() {
      switch (side) {
        case 'top': top = value; break;
        case 'right': right = value; break;
        case 'bottom': bottom = value; break;
        case 'left': left = value; break;
      }
      if (linked) {
        top = right = bottom = left = value;
        if (source != _controllerAll) _controllerAll.text = value.toStringAsFixed(0);
        if (source != _controllerTop) _controllerTop.text = value.toStringAsFixed(0);
        if (source != _controllerRight) _controllerRight.text = value.toStringAsFixed(0);
        if (source != _controllerBottom) _controllerBottom.text = value.toStringAsFixed(0);
        if (source != _controllerLeft) _controllerLeft.text = value.toStringAsFixed(0);
      }
      widget.onChanged(EdgeInsets.only(top: top, right: right, bottom: bottom, left: left));
    });
  }

  @override
  Widget build(BuildContext context) {
    final boxSize = 100.0;
    final inputSize = 28.0;
    final borderRadius = 12.0;
    final bgColor = const Color(0xFF1E293B); // Muted Tailwind slate color
    final fgColor = Colors.white;
    final borderColor = Colors.grey.shade700;
    final inactiveColor = Colors.grey.shade500;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white70, fontSize: 14),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: ToggleButtons(
                      borderRadius: BorderRadius.circular(6),
                      selectedColor: Colors.white,
                      fillColor: accent.withOpacity(0.25),
                      color: inactiveColor,
                      isSelected: [allMode, !allMode],
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 22),
                      onPressed: (i) => setState(() => allMode = i == 0),
                      children: [
                        Text('All', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: allMode ? accent : inactiveColor)),
                        Text('Sides', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: !allMode ? accent : inactiveColor)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 16,
                      icon: Icon(linked ? Icons.link : Icons.link_off, color: linked ? accent : inactiveColor),
                      tooltip: linked ? 'Unlink sides' : 'Link all sides',
                      onPressed: () {
                        setState(() {
                          linked = !linked;
                          widget.onLinkChanged(linked);
                          if (linked) {
                            final v = top;
                            top = right = bottom = left = v;
                            _syncControllers();
                            widget.onChanged(EdgeInsets.only(top: v, right: v, bottom: v, left: v));
                          }
                        });
                      },
                    ),
                  ),
                ],
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
                    left: 28,
                    top: 28,
                    right: 28,
                    bottom: 28,
                    child: Container(
                      decoration: BoxDecoration(
                        color: bgColor.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: borderColor, width: 1.5),
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
                      bottom: -inputSize - 4,
                      width: inputSize,
                      child: _inputField(_controllerAll, (v) => _updateAll(v, source: _controllerAll)),
                    )
                  else ...[
                    Positioned(
                      left: boxSize / 2 - inputSize / 2,
                      top: -inputSize - 4,
                      width: inputSize,
                      child: _inputField(_controllerTop, (v) => _updateSide('top', v, source: _controllerTop)),
                    ),
                    Positioned(
                      right: -inputSize - 4,
                      top: boxSize / 2 - inputSize / 2,
                      width: inputSize,
                      child: _inputField(_controllerRight, (v) => _updateSide('right', v, source: _controllerRight)),
                    ),
                    Positioned(
                      left: boxSize / 2 - inputSize / 2,
                      bottom: -inputSize - 4,
                      width: inputSize,
                      child: _inputField(_controllerBottom, (v) => _updateSide('bottom', v, source: _controllerBottom)),
                    ),
                    Positioned(
                      left: -inputSize - 4,
                      top: boxSize / 2 - inputSize / 2,
                      width: inputSize,
                      child: _inputField(_controllerLeft, (v) => _updateSide('left', v, source: _controllerLeft)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              allMode
                  ? 'All sides: ${top.toStringAsFixed(0)}px'
                  : 'Top: ${top.toStringAsFixed(0)}  Right: ${right.toStringAsFixed(0)}  Bottom: ${bottom.toStringAsFixed(0)}  Left: ${left.toStringAsFixed(0)}',
              style: TextStyle(color: fgColor.withOpacity(0.7), fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(TextEditingController controller, ValueChanged<double> onChanged) {
    return Container(
      height: 24,
      width: 28,
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF4a9eff), width: 1.5),
      ),
      child: Center(
        child: TextField(
          controller: controller,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 2),
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
          left: 28,
          right: 28,
          top: 18,
          child: Container(height: 1.5, color: color.withOpacity(0.4)),
        );
      case 'right':
        return Positioned(
          right: 18,
          top: 28,
          bottom: 28,
          child: Container(width: 1.5, color: color.withOpacity(0.4)),
        );
      case 'bottom':
        return Positioned(
          left: 28,
          right: 28,
          bottom: 18,
          child: Container(height: 1.5, color: color.withOpacity(0.4)),
        );
      case 'left':
        return Positioned(
          left: 18,
          top: 28,
          bottom: 28,
          child: Container(width: 1.5, color: color.withOpacity(0.4)),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double borderRadius;
  _DashedRectPainter({required this.color, this.borderRadius = 12});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Radius.circular(borderRadius),
      ));
    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
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