import 'package:flutter/material.dart';

import 'editor_theme.dart';

/// Small building blocks shared by editor panels and screens.

class EditorSection extends StatefulWidget {
  final String title;
  final IconData? icon;
  final List<Widget> children;
  final Widget? trailing;
  final bool initiallyExpanded;
  final String? subtitle;

  const EditorSection({
    super.key,
    required this.title,
    required this.children,
    this.icon,
    this.trailing,
    this.initiallyExpanded = true,
    this.subtitle,
  });

  @override
  State<EditorSection> createState() => _EditorSectionState();
}

class _EditorSectionState extends State<EditorSection> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: EditorColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: EditorColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 15, color: EditorColors.accent),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: EditorColors.text)),
                        if (widget.subtitle != null)
                          Text(widget.subtitle!, style: const TextStyle(fontSize: 11.5, color: EditorColors.textFaint)),
                      ],
                    ),
                  ),
                  if (widget.trailing != null) widget.trailing!,
                  Icon(_expanded ? Icons.expand_less_rounded : Icons.expand_more_rounded, size: 18, color: EditorColors.textFaint),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: widget.children),
            ),
        ],
      ),
    );
  }
}

/// A label above an input.
class EditorField extends StatelessWidget {
  final String label;
  final Widget child;
  final String? help;

  const EditorField({super.key, required this.label, required this.child, this.help});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: EditorColors.textMuted, letterSpacing: 0.2)),
          const SizedBox(height: 5),
          child,
          if (help != null) ...[
            const SizedBox(height: 4),
            Text(help!, style: const TextStyle(fontSize: 11, color: EditorColors.textFaint, height: 1.35)),
          ],
        ],
      ),
    );
  }
}

/// A text input that keeps its own controller in sync with [value].
class EditorTextInput extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final String? hint;
  final int maxLines;
  final bool monospace;
  final TextInputType? keyboardType;
  final Widget? prefix;
  final bool obscure;

  const EditorTextInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.hint,
    this.maxLines = 1,
    this.monospace = false,
    this.keyboardType,
    this.prefix,
    this.obscure = false,
  });

  @override
  State<EditorTextInput> createState() => _EditorTextInputState();
}

class _EditorTextInputState extends State<EditorTextInput> {
  late final TextEditingController _controller = TextEditingController(text: widget.value);

  @override
  void didUpdateWidget(EditorTextInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text && !_focus.hasFocus) _controller.text = widget.value;
  }

  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focus,
      maxLines: widget.maxLines,
      minLines: 1,
      obscureText: widget.obscure,
      keyboardType: widget.keyboardType,
      style: TextStyle(
        fontSize: 13,
        color: EditorColors.text,
        fontFamily: widget.monospace ? 'monospace' : null,
        height: widget.monospace ? 1.45 : null,
      ),
      decoration: InputDecoration(hintText: widget.hint, prefixIcon: widget.prefix),
      onChanged: widget.onChanged,
    );
  }
}

class EditorDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T> items;
  final String Function(T) label;
  final ValueChanged<T?> onChanged;
  final String? hint;
  final Widget Function(T)? leading;

  const EditorDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.label,
    required this.onChanged,
    this.hint,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final safeValue = items.contains(value) ? value : null;
    return DropdownButtonFormField<T>(
      initialValue: safeValue,
      key: ValueKey('$safeValue-${items.length}'),
      isExpanded: true,
      isDense: true,
      dropdownColor: EditorColors.surfaceRaised,
      borderRadius: BorderRadius.circular(10),
      style: const TextStyle(fontSize: 13, color: EditorColors.text, fontFamily: 'Inter'),
      icon: const Icon(Icons.unfold_more_rounded, size: 16, color: EditorColors.textMuted),
      hint: hint == null ? null : Text(hint!, style: const TextStyle(fontSize: 13, color: EditorColors.textFaint)),
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Row(children: [
                  if (leading != null) ...[leading!(item), const SizedBox(width: 8)],
                  Flexible(child: Text(label(item), overflow: TextOverflow.ellipsis)),
                ]),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}

/// A compact pill used for toggles, chips and segmented choices.
class EditorPill extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  const EditorPill({super.key, required this.label, this.selected = false, this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? EditorColors.accentSoft : EditorColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: selected ? EditorColors.accent : EditorColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: selected ? EditorColors.accent : EditorColors.textMuted),
                const SizedBox(width: 6),
              ],
              Text(label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                    color: selected ? EditorColors.text : EditorColors.textMuted,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class EditorEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const EditorEmptyState({super.key, required this.icon, required this.title, required this.message, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: EditorColors.accentSoft, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: EditorColors.accent, size: 22),
          ),
          const SizedBox(height: 12),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: EditorColors.text)),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, color: EditorColors.textMuted, height: 1.45)),
          if (action != null) ...[const SizedBox(height: 14), action!],
        ],
      ),
    );
  }
}

/// A row in a list of definitions (variables, API calls, ...).
class EditorListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? trailing;
  final Color? iconColor;

  const EditorListTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.selected = false,
    this.onTap,
    this.trailing,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? EditorColors.surfaceHover : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            child: Row(
              children: [
                Icon(icon, size: 16, color: iconColor ?? (selected ? EditorColors.accent : EditorColors.textMuted)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? EditorColors.text : EditorColors.text.withValues(alpha: 0.9))),
                      if (subtitle != null)
                        Text(subtitle!, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: EditorColors.textFaint)),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Uppercase label used above groups of controls.
class EditorLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;

  const EditorLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(text.toUpperCase(),
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: EditorColors.textFaint, letterSpacing: 1.1)),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class EditorIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool active;
  final Color? color;
  final double size;

  const EditorIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.active = false,
    this.color,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: active ? EditorColors.accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.all(7),
            child: Icon(icon, size: size, color: onPressed == null ? EditorColors.textFaint : (active ? EditorColors.accent : (color ?? EditorColors.textMuted))),
          ),
        ),
      ),
    );
  }
}
