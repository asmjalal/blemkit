// Widgets used by SynappKit-generated code. The editor canvas renders these
// same classes, and this file is copied verbatim into every exported project
// as lib/synapp/synapp_widgets.dart, so it may only depend on the Flutter SDK.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Plays an entrance animation once when first built.
class SynappEntrance extends StatefulWidget {
  /// fade | slideUp | slideDown | slideLeft | slideRight | scale | fadeScale
  final String type;
  final int durationMs;
  final int delayMs;
  final Widget child;

  const SynappEntrance({super.key, this.type = 'fade', this.durationMs = 400, this.delayMs = 0, required this.child});

  @override
  State<SynappEntrance> createState() => _SynappEntranceState();
}

class _SynappEntranceState extends State<SynappEntrance> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: Duration(milliseconds: widget.durationMs));
  late final Animation<double> _curve = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (context, child) {
        final t = _curve.value;
        Offset offset = Offset.zero;
        double scale = 1;
        switch (widget.type) {
          case 'slideUp':
            offset = Offset(0, 24 * (1 - t));
            break;
          case 'slideDown':
            offset = Offset(0, -24 * (1 - t));
            break;
          case 'slideLeft':
            offset = Offset(24 * (1 - t), 0);
            break;
          case 'slideRight':
            offset = Offset(-24 * (1 - t), 0);
            break;
          case 'scale':
          case 'fadeScale':
            scale = 0.85 + 0.15 * t;
            break;
        }
        final opacity = widget.type == 'scale' ? 1.0 : t.clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: Transform.translate(offset: offset, child: Transform.scale(scale: scale, child: child)),
        );
      },
    );
  }
}

class SynappRatingBar extends StatefulWidget {
  final double rating;
  final int itemCount;
  final double itemSize;
  final Color color;
  final Color unratedColor;
  final bool allowHalf;
  final ValueChanged<double>? onChanged;

  const SynappRatingBar({
    super.key,
    this.rating = 3,
    this.itemCount = 5,
    this.itemSize = 28,
    this.color = const Color(0xFFFFB300),
    this.unratedColor = const Color(0xFFE0E0E0),
    this.allowHalf = false,
    this.onChanged,
  });

  @override
  State<SynappRatingBar> createState() => _SynappRatingBarState();
}

class _SynappRatingBarState extends State<SynappRatingBar> {
  late double _rating = widget.rating;

  @override
  void didUpdateWidget(SynappRatingBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rating != widget.rating) _rating = widget.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.itemCount, (i) {
        final icon = _rating >= i + 1
            ? Icons.star_rounded
            : (widget.allowHalf && _rating >= i + 0.5 ? Icons.star_half_rounded : Icons.star_outline_rounded);
        return GestureDetector(
          onTap: widget.onChanged == null
              ? null
              : () {
                  setState(() => _rating = i + 1.0);
                  widget.onChanged!(_rating);
                },
          child: Icon(icon, size: widget.itemSize, color: _rating >= i + 0.5 ? widget.color : widget.unratedColor),
        );
      }),
    );
  }
}

class SynappPinCode extends StatefulWidget {
  final int length;
  final bool obscureText;
  final double boxSize;
  final Color activeColor;
  final Color inactiveColor;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;

  const SynappPinCode({
    super.key,
    this.length = 4,
    this.obscureText = false,
    this.boxSize = 52,
    this.activeColor = const Color(0xFF4F46E5),
    this.inactiveColor = const Color(0xFFCBD5E1),
    this.onCompleted,
    this.onChanged,
  });

  @override
  State<SynappPinCode> createState() => _SynappPinCodeState();
}

class _SynappPinCodeState extends State<SynappPinCode> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final code = _controller.text;
    return GestureDetector(
      onTap: () => _focus.requestFocus(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0,
            child: SizedBox(
              width: 1,
              height: 1,
              child: TextField(
                controller: _controller,
                focusNode: _focus,
                keyboardType: TextInputType.number,
                maxLength: widget.length,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (value) {
                  setState(() {});
                  widget.onChanged?.call(value);
                  if (value.length == widget.length) widget.onCompleted?.call(value);
                },
              ),
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(widget.length, (i) {
              final filled = i < code.length;
              final active = i == code.length && _focus.hasFocus;
              return Container(
                width: widget.boxSize,
                height: widget.boxSize,
                margin: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: active || filled ? widget.activeColor : widget.inactiveColor, width: active ? 2 : 1.4),
                ),
                child: Text(
                  filled ? (widget.obscureText ? '•' : code[i]) : '',
                  style: TextStyle(fontSize: widget.boxSize * 0.4, fontWeight: FontWeight.w600),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class SynappCounter extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final Color color;
  final ValueChanged<int>? onChanged;

  const SynappCounter({super.key, this.value = 1, this.min = 0, this.max = 99, this.color = const Color(0xFF4F46E5), this.onChanged});

  @override
  State<SynappCounter> createState() => _SynappCounterState();
}

class _SynappCounterState extends State<SynappCounter> {
  late int _value = widget.value;

  void _set(int v) {
    if (v < widget.min || v > widget.max) return;
    setState(() => _value = v);
    widget.onChanged?.call(v);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(40), border: Border.all(color: widget.color.withValues(alpha: 0.35))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.remove_rounded), color: widget.color, onPressed: () => _set(_value - 1)),
          Text('$_value', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          IconButton(icon: const Icon(Icons.add_rounded), color: widget.color, onPressed: () => _set(_value + 1)),
        ],
      ),
    );
  }
}

class SynappChoiceChips extends StatefulWidget {
  final List<String> options;
  final List<String> initiallySelected;
  final bool multiSelect;
  final Color selectedColor;
  final ValueChanged<List<String>>? onChanged;

  const SynappChoiceChips({
    super.key,
    required this.options,
    this.initiallySelected = const [],
    this.multiSelect = false,
    this.selectedColor = const Color(0xFF4F46E5),
    this.onChanged,
  });

  @override
  State<SynappChoiceChips> createState() => _SynappChoiceChipsState();
}

class _SynappChoiceChipsState extends State<SynappChoiceChips> {
  late final Set<String> _selected = {...widget.initiallySelected};

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.options.map((option) {
        final selected = _selected.contains(option);
        return ChoiceChip(
          label: Text(option),
          selected: selected,
          selectedColor: widget.selectedColor.withValues(alpha: 0.15),
          side: BorderSide(color: selected ? widget.selectedColor : const Color(0xFFE2E8F0)),
          labelStyle: TextStyle(color: selected ? widget.selectedColor : null, fontWeight: selected ? FontWeight.w600 : null),
          onSelected: (value) {
            setState(() {
              if (!widget.multiSelect) _selected.clear();
              value ? _selected.add(option) : _selected.remove(option);
            });
            widget.onChanged?.call(_selected.toList());
          },
        );
      }).toList(),
    );
  }
}

class SynappCheckboxGroup extends StatefulWidget {
  final List<String> options;
  final List<String> initiallySelected;
  final Color activeColor;
  final ValueChanged<List<String>>? onChanged;

  const SynappCheckboxGroup({
    super.key,
    required this.options,
    this.initiallySelected = const [],
    this.activeColor = const Color(0xFF4F46E5),
    this.onChanged,
  });

  @override
  State<SynappCheckboxGroup> createState() => _SynappCheckboxGroupState();
}

class _SynappCheckboxGroupState extends State<SynappCheckboxGroup> {
  late final Set<String> _selected = {...widget.initiallySelected};

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: widget.options
          .map((option) => CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: widget.activeColor,
                title: Text(option),
                value: _selected.contains(option),
                onChanged: (value) {
                  setState(() => value == true ? _selected.add(option) : _selected.remove(option));
                  widget.onChanged?.call(_selected.toList());
                },
              ))
          .toList(),
    );
  }
}

class SynappRadioGroup extends StatefulWidget {
  final List<String> options;
  final String? initialValue;
  final Color activeColor;
  final bool horizontal;
  final ValueChanged<String?>? onChanged;

  const SynappRadioGroup({
    super.key,
    required this.options,
    this.initialValue,
    this.activeColor = const Color(0xFF4F46E5),
    this.horizontal = false,
    this.onChanged,
  });

  @override
  State<SynappRadioGroup> createState() => _SynappRadioGroupState();
}

class _SynappRadioGroupState extends State<SynappRadioGroup> {
  late String? _value = widget.initialValue;

  @override
  Widget build(BuildContext context) {
    final items = widget.options.map((option) {
      final selected = option == _value;
      return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          setState(() => _value = option);
          widget.onChanged?.call(option);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  size: 20, color: selected ? widget.activeColor : const Color(0xFF94A3B8)),
              const SizedBox(width: 8),
              Text(option),
            ],
          ),
        ),
      );
    }).toList();
    return widget.horizontal
        ? Wrap(spacing: 12, children: items)
        : Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: items);
  }
}

/// Captures a hand-drawn signature as strokes.
class SynappSignature extends StatefulWidget {
  final double height;
  final Color penColor;
  final Color backgroundColor;
  final double strokeWidth;
  final ValueChanged<List<List<Offset>>>? onChanged;

  const SynappSignature({
    super.key,
    this.height = 160,
    this.penColor = const Color(0xFF0F172A),
    this.backgroundColor = const Color(0xFFF8FAFC),
    this.strokeWidth = 2.5,
    this.onChanged,
  });

  @override
  State<SynappSignature> createState() => _SynappSignatureState();
}

class _SynappSignatureState extends State<SynappSignature> {
  final List<List<Offset>> _strokes = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onPanStart: (d) => setState(() => _strokes.add([d.localPosition])),
              onPanUpdate: (d) => setState(() => _strokes.last.add(d.localPosition)),
              onPanEnd: (_) => widget.onChanged?.call(_strokes),
              child: CustomPaint(painter: _SignaturePainter(_strokes, widget.penColor, widget.strokeWidth)),
            ),
          ),
          if (_strokes.isEmpty)
            const Center(child: Text('Sign here', style: TextStyle(color: Color(0xFF94A3B8)))),
          Positioned(
            right: 4,
            top: 4,
            child: IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.refresh_rounded, size: 18),
              onPressed: () {
                setState(_strokes.clear);
                widget.onChanged?.call(_strokes);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final Color color;
  final double width;

  _SignaturePainter(this.strokes, this.color, this.width);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    for (final stroke in strokes) {
      final path = Path();
      for (var i = 0; i < stroke.length; i++) {
        i == 0 ? path.moveTo(stroke[i].dx, stroke[i].dy) : path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SignaturePainter oldDelegate) => true;
}

class SynappDataTable extends StatelessWidget {
  final List<String> columns;
  final List<List<String>> rows;
  final Color headerColor;

  const SynappDataTable({super.key, required this.columns, required this.rows, this.headerColor = const Color(0xFFF1F5F9)});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(headerColor),
        columns: columns.map((c) => DataColumn(label: Text(c, style: const TextStyle(fontWeight: FontWeight.w600)))).toList(),
        rows: rows
            .map((row) => DataRow(
                  cells: List.generate(columns.length, (i) => DataCell(Text(i < row.length ? row[i] : ''))),
                ))
            .toList(),
      ),
    );
  }
}

class SynappCreditCardForm extends StatefulWidget {
  final Color cardColor;
  final ValueChanged<Map<String, String>>? onChanged;

  const SynappCreditCardForm({super.key, this.cardColor = const Color(0xFF312E81), this.onChanged});

  @override
  State<SynappCreditCardForm> createState() => _SynappCreditCardFormState();
}

class _SynappCreditCardFormState extends State<SynappCreditCardForm> {
  final Map<String, String> _values = {'number': '', 'name': '', 'expiry': '', 'cvv': ''};

  void _update(String key, String value) {
    setState(() => _values[key] = value);
    widget.onChanged?.call(Map.of(_values));
  }

  @override
  Widget build(BuildContext context) {
    final number = _values['number']!.padRight(16, '•');
    final grouped = [for (var i = 0; i < 16; i += 4) number.substring(i, i + 4)].join(' ');
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 180,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(colors: [widget.cardColor, widget.cardColor.withValues(alpha: 0.75)]),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.credit_card_rounded, color: Colors.white70),
              const Spacer(),
              Text(grouped, style: const TextStyle(color: Colors.white, fontSize: 20, letterSpacing: 2)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: Text(_values['name']!.isEmpty ? 'CARD HOLDER' : _values['name']!.toUpperCase(), style: const TextStyle(color: Colors.white70))),
                Text(_values['expiry']!.isEmpty ? 'MM/YY' : _values['expiry']!, style: const TextStyle(color: Colors.white70)),
              ]),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(labelText: 'Card number', border: OutlineInputBorder()),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(16)],
          onChanged: (v) => _update('number', v),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(labelText: 'Card holder', border: OutlineInputBorder()),
          onChanged: (v) => _update('name', v),
        ),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(labelText: 'Expiry (MM/YY)', border: OutlineInputBorder()),
              onChanged: (v) => _update('expiry', v),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(labelText: 'CVV', border: OutlineInputBorder()),
              obscureText: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
              onChanged: (v) => _update('cvv', v),
            ),
          ),
        ]),
      ],
    );
  }
}

/// A list tile that reveals an action when swiped left.
class SynappSlidableTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionLabel;
  final Color actionColor;
  final VoidCallback? onAction;

  const SynappSlidableTile({
    super.key,
    required this.title,
    this.subtitle = '',
    this.actionLabel = 'Delete',
    this.actionColor = const Color(0xFFEF4444),
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey('$title$subtitle'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        onAction?.call();
        return false;
      },
      background: Container(
        color: actionColor,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Text(actionLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      child: ListTile(title: Text(title), subtitle: subtitle.isEmpty ? null : Text(subtitle)),
    );
  }
}

class SynappLoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Color barrierColor;
  final Widget child;

  const SynappLoadingOverlay({super.key, this.isLoading = true, this.barrierColor = const Color(0x66000000), required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: ColoredBox(color: barrierColor, child: const Center(child: CircularProgressIndicator())),
          ),
      ],
    );
  }
}

/// Address entry with a simple suggestion list. Swap in a Places API for
/// production geocoding.
class SynappPlacePicker extends StatefulWidget {
  final String hintText;
  final List<String> suggestions;
  final ValueChanged<String>? onSelected;

  const SynappPlacePicker({super.key, this.hintText = 'Search address', this.suggestions = const [], this.onSelected});

  @override
  State<SynappPlacePicker> createState() => _SynappPlacePickerState();
}

class _SynappPlacePickerState extends State<SynappPlacePicker> {
  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (value) => value.text.isEmpty
          ? const Iterable<String>.empty()
          : widget.suggestions.where((s) => s.toLowerCase().contains(value.text.toLowerCase())),
      onSelected: widget.onSelected,
      fieldViewBuilder: (context, controller, focusNode, onSubmit) => TextField(
        controller: controller,
        focusNode: focusNode,
        onSubmitted: (v) => widget.onSelected?.call(v),
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.location_on_outlined),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
