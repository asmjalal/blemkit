import 'package:flutter/material.dart';

import '../platform/web_bridge.dart';
import '../ui/editor_theme.dart';

/// First-run tour of the editor, shown once per browser.
class WelcomeTour {
  static const _key = 'synappkit_welcome_seen_v2';

  static Future<void> showIfFirstRun(BuildContext context) async {
    if (WebBridge.read(_key) == '1') return;
    WebBridge.write(_key, '1');
    await show(context);
  }

  static Future<void> show(BuildContext context) {
    return showDialog<void>(context: context, builder: (_) => const _WelcomeDialog());
  }
}

class _WelcomeDialog extends StatefulWidget {
  const _WelcomeDialog();

  @override
  State<_WelcomeDialog> createState() => _WelcomeDialogState();
}

class _WelcomeDialogState extends State<_WelcomeDialog> {
  int _step = 0;

  static const _steps = [
    (Icons.widgets_outlined, 'Build pages visually', 'Drag widgets from the left panel onto the device, or click one to add it inside the selected widget. The Tree tab shows the structure; right-click a widget for wrap, duplicate and delete.'),
    (Icons.bolt_rounded, 'Add logic without code', 'Select a widget and open Actions to navigate, update state, call APIs or Supabase, and branch with If/Else. The Logic tab binds properties to variables and adds visibility rules and animations.'),
    (Icons.play_arrow_rounded, 'Try it in Test mode', 'Press Test (or T) above the canvas. Buttons run their actions, inputs keep values, and the debug panel shows state as it changes.'),
    (Icons.account_tree_outlined, 'Project-wide data', 'Logic in the top bar holds app state, data types, API calls, authentication, languages and custom Dart code.'),
    (Icons.download_rounded, 'Export real Flutter code', 'Export downloads a complete Flutter project or pushes it to GitHub. ⌘K searches every command; ? lists shortcuts.'),
  ];

  @override
  Widget build(BuildContext context) {
    final (icon, title, body) = _steps[_step];
    final last = _step == _steps.length - 1;
    return Dialog(
      child: SizedBox(
        width: 460,
        child: Padding(
          padding: const EdgeInsets.all(26),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: EditorColors.accentSoft, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: EditorColors.accent),
              ),
              const SizedBox(height: 18),
              Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text(body, style: const TextStyle(fontSize: 13.5, color: EditorColors.textMuted, height: 1.55)),
              const SizedBox(height: 24),
              Row(children: [
                for (var i = 0; i < _steps.length; i++)
                  Container(
                    width: i == _step ? 18 : 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 5),
                    decoration: BoxDecoration(color: i == _step ? EditorColors.accent : EditorColors.borderStrong, borderRadius: BorderRadius.circular(3)),
                  ),
                const Spacer(),
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Skip')),
                const SizedBox(width: 6),
                FilledButton(
                  onPressed: () => last ? Navigator.pop(context) : setState(() => _step++),
                  child: Text(last ? 'Start building' : 'Next'),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
