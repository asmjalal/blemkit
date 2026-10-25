import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/widget_node.dart';
import '../models/project_logic.dart';
import '../providers/widget_tree_provider.dart';
import '../runtime/preview_runtime.dart';
import '../ui/editor_theme.dart';
import '../ui/editor_widgets.dart';
import '../utils/color_utils.dart';
import 'canvas_preview/builders/api_query_wrapper.dart';
import 'canvas_preview/builders/widget_builder_factory.dart';
import 'canvas_preview/canvas_preview_mode.dart';
import 'canvas_preview/device_presets.dart';

/// The device canvas: renders the selected page inside a device frame, with
/// a toolbar for device, theme, zoom and Test mode.
class CanvasPreview extends StatefulWidget {
  /// Always run actions (used by the standalone preview screen).
  final bool isLivePreview;

  const CanvasPreview({super.key, this.isLivePreview = false});

  @override
  State<CanvasPreview> createState() => _CanvasPreviewState();
}

class _CanvasPreviewState extends State<CanvasPreview> {
  /// Zoom relative to "fit to screen".
  double _zoom = 1.0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final device = DevicePresets.byId(provider.previewDevice);
    final live = widget.isLivePreview || provider.testMode;

    return CanvasPreviewMode(
      isLivePreview: live,
      child: Container(
        color: EditorColors.canvas,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(painter: DottedGridPainter(color: Colors.white.withValues(alpha: 0.045), gridSize: 24)),
            LayoutBuilder(builder: (context, constraints) {
              final frame = _frameSize(device);
              final fit = ((constraints.maxHeight - 120) / frame.height).clamp(0.2, 1.0).toDouble();
              final fitW = ((constraints.maxWidth - 80) / frame.width).clamp(0.2, 1.0).toDouble();
              final scale = (fit < fitW ? fit : fitW) * _zoom;
              return InteractiveViewer(
                minScale: 1,
                maxScale: 1,
                panEnabled: _zoom > 1,
                scaleEnabled: false,
                boundaryMargin: const EdgeInsets.all(400),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: SizedBox(
                      width: frame.width * scale,
                      height: frame.height * scale,
                      child: FittedBox(child: _DeviceFrame(device: device, child: _screen(context, provider, device))),
                    ),
                  ),
                ),
              );
            }),
            Positioned(top: 12, left: 0, right: 0, child: Center(child: _toolbar(context, provider, device))),
            if (provider.testMode) const Positioned(left: 16, bottom: 16, top: 70, child: _DebugPanel()),
          ],
        ),
      ),
    );
  }

  Size _frameSize(DevicePreset device) {
    if (device.isDesktop) return Size(device.size.width + 2, device.size.height + 38);
    return Size(device.size.width + 24, device.size.height + 24);
  }

  Widget _screen(BuildContext context, WidgetTreeProvider provider, DevicePreset device) {
    final root = provider.rootNode;
    final theme = _projectTheme(provider.effectiveThemeProperties, dark: provider.previewDarkMode);
    Widget content = root == null
        ? const SizedBox.shrink()
        : DragTarget<String>(
            onWillAcceptWithDetails: (_) => !provider.testMode,
            onAcceptWithDetails: (details) {
              final data = details.data;
              final parent = provider.selectedNode ?? provider.rootNode;
              provider.addNode(data, parent: parent);
            },
            builder: (context, candidates, _) => Stack(
              fit: StackFit.expand,
              children: [
                WidgetBuilderFactory.buildWidget(context, root, provider.hoveredNode),
                if (candidates.isNotEmpty)
                  IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(border: Border.all(color: EditorColors.accent, width: 2), color: EditorColors.accentSoft),
                    ),
                  ),
              ],
            ),
          );

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        size: device.size,
        padding: device.hasNotch ? const EdgeInsets.only(top: 54, bottom: 30) : (device.isDesktop ? EdgeInsets.zero : const EdgeInsets.only(top: 24)),
        textScaler: TextScaler.noScaling,
      ),
      child: Theme(
        key: ValueKey('${provider.previewDarkMode}-${provider.themeProperties.hashCode}'),
        data: theme,
        child: Directionality(
          textDirection: provider.logic.rtl ? TextDirection.rtl : TextDirection.ltr,
          child: ScaffoldMessenger(
            child: Material(
              color: theme.scaffoldBackgroundColor,
              child: SizedBox.fromSize(size: device.size, child: content),
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolbar(BuildContext context, WidgetTreeProvider provider, DevicePreset device) {
    Widget divider() => Container(width: 1, height: 22, margin: const EdgeInsets.symmetric(horizontal: 6), color: EditorColors.border);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: EditorColors.surface.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EditorColors.border),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 6))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final d in DevicePresets.all)
            EditorIconButton(icon: d.icon, tooltip: '${d.label} · ${d.size.width.toInt()}×${d.size.height.toInt()}', active: d.id == device.id, onPressed: () => provider.setPreviewDevice(d.id)),
          divider(),
          EditorIconButton(
            icon: provider.previewDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_outlined,
            tooltip: provider.previewDarkMode ? 'Previewing dark mode' : 'Previewing light mode',
            active: provider.previewDarkMode,
            onPressed: () => provider.setPreviewDarkMode(!provider.previewDarkMode),
          ),
          divider(),
          EditorIconButton(icon: Icons.remove_rounded, tooltip: 'Zoom out', onPressed: () => setState(() => _zoom = (_zoom - 0.1).clamp(0.4, 2.0))),
          InkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () => setState(() => _zoom = 1),
            child: Tooltip(
              message: 'Fit to screen',
              child: SizedBox(
                width: 44,
                child: Text('${(_zoom * 100).round()}%', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: EditorColors.textMuted)),
              ),
            ),
          ),
          EditorIconButton(icon: Icons.add_rounded, tooltip: 'Zoom in', onPressed: () => setState(() => _zoom = (_zoom + 0.1).clamp(0.4, 2.0))),
          if (!widget.isLivePreview) ...[
            divider(),
            _TestModeButton(
              active: provider.testMode,
              onPressed: () {
                final entering = !provider.testMode;
                provider.setTestMode(entering);
                ApiQueryWrapper.clearCache();
                if (entering && provider.selectedScreen != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) PreviewRuntime.run(context, PageLogic.onPageLoad(provider.selectedScreen!.properties));
                  });
                }
              },
            ),
          ],
        ],
      ),
    );
  }

  ThemeData _projectTheme(Map<String, dynamic> props, {required bool dark}) {
    final primary = ColorUtils.parseColor(props['primaryColor'], Colors.indigo);
    final secondary = ColorUtils.parseColor(props['secondaryColor'], Colors.teal);
    final tertiary = ColorUtils.parseColor(props['tertiaryColor'], Colors.amber);
    final surface = ColorUtils.parseColor(props['backgroundColor'], dark ? const Color(0xFF111827) : Colors.white);
    final scaffoldBg = ColorUtils.parseColor(props['scaffoldBackgroundColor'], dark ? const Color(0xFF0B1120) : Colors.white);
    final error = ColorUtils.parseColor(props['errorColor'], Colors.red);
    final text = ColorUtils.parseColor(props['primaryText'], dark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A));
    final isM3 = props['useMaterial3'] ?? true;
    final fontFamily = props['fontFamily'] as String? ?? 'Inter';

    TextStyle style(Map<String, dynamic>? m) => m == null
        ? const TextStyle()
        : TextStyle(fontSize: (m['fontSize'] as num?)?.toDouble(), fontWeight: _parseFontWeight(m['fontWeight']), letterSpacing: (m['letterSpacing'] as num?)?.toDouble());

    final base = ThemeData(
      useMaterial3: isM3,
      brightness: dark ? Brightness.dark : Brightness.light,
      primaryColor: primary,
      scaffoldBackgroundColor: scaffoldBg,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        brightness: dark ? Brightness.dark : Brightness.light,
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: surface,
        error: error,
      ),
    );
    Map<String, dynamic>? m(String key) => props[key] is Map ? Map<String, dynamic>.from(props[key] as Map) : null;
    return base.copyWith(
      textTheme: base.textTheme
          .merge(TextTheme(
            displayLarge: style(m('displayLarge')),
            displayMedium: style(m('displayMedium')),
            displaySmall: style(m('displaySmall')),
            headlineLarge: style(m('headlineLarge')),
            headlineMedium: style(m('headlineMedium')),
            headlineSmall: style(m('headlineSmall')),
            titleLarge: style(m('titleLarge')),
            titleMedium: style(m('titleMedium')),
            titleSmall: style(m('titleSmall')),
            labelLarge: style(m('labelLarge')),
            bodyLarge: style(m('bodyLarge')),
            bodyMedium: style(m('bodyMedium')),
            bodySmall: style(m('bodySmall')),
          ))
          .apply(bodyColor: text, displayColor: text),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: text,
        titleTextStyle: TextStyle(fontFamily: fontFamily, color: text, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      cardTheme: CardThemeData(color: surface, elevation: 2, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
      ),
    );
  }

  FontWeight _parseFontWeight(dynamic value) {
    switch (value) {
      case 'Bold':
        return FontWeight.bold;
      case 'Medium':
        return FontWeight.w500;
      case 'Light':
        return FontWeight.w300;
      case 'Thin':
        return FontWeight.w100;
    }
    return FontWeight.normal;
  }
}

class _TestModeButton extends StatelessWidget {
  final bool active;
  final VoidCallback onPressed;

  const _TestModeButton({required this.active, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: active ? 'Stop Test mode (Esc)' : 'Test mode: tap buttons to run actions (T)',
      child: Material(
        color: active ? EditorColors.success.withValues(alpha: 0.18) : EditorColors.accentSoft,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(children: [
              Icon(active ? Icons.stop_rounded : Icons.play_arrow_rounded, size: 16, color: active ? EditorColors.success : EditorColors.accent),
              const SizedBox(width: 4),
              Text(active ? 'Testing' : 'Test', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: active ? EditorColors.success : EditorColors.accent)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _DeviceFrame extends StatelessWidget {
  final DevicePreset device;
  final Widget child;

  const _DeviceFrame({required this.device, required this.child});

  @override
  Widget build(BuildContext context) {
    if (device.isDesktop) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1B2236),
          borderRadius: BorderRadius.circular(device.radius),
          border: Border.all(color: EditorColors.borderStrong),
          boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 40, offset: Offset(0, 20))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 36,
              width: device.size.width,
              child: Row(children: [
                const SizedBox(width: 14),
                for (final c in const [Color(0xFFFF5F57), Color(0xFFFEBC2E), Color(0xFF28C840)])
                  Container(width: 11, height: 11, margin: const EdgeInsets.only(right: 7), decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
                const SizedBox(width: 20),
                Expanded(
                  child: Container(
                    height: 22,
                    margin: const EdgeInsets.only(right: 120),
                    decoration: BoxDecoration(color: const Color(0xFF0E1426), borderRadius: BorderRadius.circular(6)),
                  ),
                ),
              ]),
            ),
            SizedBox.fromSize(size: device.size, child: child),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1C),
        borderRadius: BorderRadius.circular(device.radius + 12),
        border: Border.all(color: const Color(0xFF2A3550), width: 1.5),
        boxShadow: const [BoxShadow(color: Color(0x99000000), blurRadius: 50, offset: Offset(0, 24))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(device.radius),
        child: Stack(
          children: [
            SizedBox.fromSize(size: device.size, child: child),
            if (device.hasNotch)
              Positioned(
                top: 11,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Container(width: 120, height: 34, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20))),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Test mode inspector: state values, action outputs and the action log.
class _DebugPanel extends StatelessWidget {
  const _DebugPanel();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final screen = provider.selectedScreen;
    final appState = {
      for (final f in provider.logic.appState) f.name: provider.previewAppState.containsKey(f.name) ? provider.previewAppState[f.name] : PreviewRuntime.defaultFor(f),
    };
    final pageState = {
      for (final f in PageLogic.pageState(screen?.properties ?? const {}))
        f.name: provider.previewPageState[screen?.id]?[f.name] ?? PreviewRuntime.defaultFor(f),
    };
    final params = provider.previewPageParams[screen?.id] ?? const {};
    final user = provider.previewAppState['__authUser'];

    return Container(
      width: 270,
      decoration: BoxDecoration(
        color: EditorColors.surface.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: EditorColors.border),
        boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 6, 6),
            child: Row(children: [
              const Icon(Icons.bug_report_outlined, size: 16, color: EditorColors.success),
              const SizedBox(width: 8),
              const Expanded(child: Text('Debug', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
              EditorIconButton(icon: Icons.restart_alt_rounded, tooltip: 'Reset state', size: 16, onPressed: () {
                provider.resetPreviewState();
                provider.widgetStates.clear();
              }),
            ]),
          ),
          const Divider(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _group('App state', appState),
                _group('Page state', pageState),
                _group('Page parameters', params),
                if (user != null) _group('Signed-in user (simulated)', Map<String, dynamic>.from(user as Map)),
                if (provider.previewOutputs.isNotEmpty) _group('Action outputs', provider.previewOutputs),
                const EditorLabel('Action log'),
                if (provider.previewLog.isEmpty)
                  const Text('Tap a button to run its actions.', style: TextStyle(fontSize: 12, color: EditorColors.textFaint))
                else
                  for (final line in provider.previewLog.take(40))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(line, style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace', color: EditorColors.textMuted)),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _group(String title, Map values) {
    if (values.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EditorLabel(title),
          for (final e in values.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Text('${e.key}', style: const TextStyle(fontSize: 12, color: EditorColors.textMuted))),
                Flexible(
                  child: Text(
                    _format(e.value),
                    textAlign: TextAlign.right,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: EditorColors.text),
                  ),
                ),
              ]),
            ),
        ],
      ),
    );
  }

  String _format(dynamic v) {
    if (v is String) return '"$v"';
    try {
      return v is Map || v is List ? jsonEncode(v) : '$v';
    } catch (_) {
      return '$v';
    }
  }
}

class DottedGridPainter extends CustomPainter {
  final Color color;
  final double gridSize;

  DottedGridPainter({required this.color, required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (double x = 0; x < size.width; x += gridSize) {
      for (double y = 0; y < size.height; y += gridSize) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DottedGridPainter oldDelegate) => oldDelegate.color != color || oldDelegate.gridSize != gridSize;
}
