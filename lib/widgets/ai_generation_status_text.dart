import 'dart:async';
import 'package:flutter/material.dart';
import '../ui/editor_theme.dart';

/// Cycles through status lines while an AI generation request is in flight.
class AiGenerationStatusText extends StatefulWidget {
  const AiGenerationStatusText({
    super.key,
    this.textAlign = TextAlign.end,
    this.fontSize = 13,
    this.color,
  });

  final TextAlign textAlign;
  final double fontSize;

  /// Defaults to slate on dark sidebars; use near-white on colored buttons.
  final Color? color;

  @override
  State<AiGenerationStatusText> createState() => _AiGenerationStatusTextState();
}

class _AiGenerationStatusTextState extends State<AiGenerationStatusText> {
  static const List<String> _steps = [
    'Creating request…',
    'Sending to AI…',
    'Crafting widgets…',
    'Structuring layout…',
    'Polishing your UI…',
  ];

  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 1700), (_) {
      if (mounted) {
        setState(() => _index = (_index + 1) % _steps.length);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 380),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offset = Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
      child: Text(
        _steps[_index],
        key: ValueKey<int>(_index),
        textAlign: widget.textAlign,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: widget.color ?? EditorColors.textMuted,
          fontSize: widget.fontSize,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
