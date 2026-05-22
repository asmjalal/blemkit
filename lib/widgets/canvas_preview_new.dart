import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/widget_tree_provider.dart';
import '../models/widget_node.dart';
import 'package:dotted_border/dotted_border.dart';
import 'canvas_preview/builders/widget_builder_factory.dart';
import '../utils/color_utils.dart';
import 'package:designflutterkit/widgets/widget_context_menu/widget_context_menu.dart';
import 'canvas_preview/canvas_preview_mode.dart';

class CanvasPreview extends StatefulWidget {
  final bool isLivePreview;

  const CanvasPreview({
    super.key,
    this.isLivePreview = false,
  });

  @override
  State<CanvasPreview> createState() => _CanvasPreviewState();
}

class _CanvasPreviewState extends State<CanvasPreview> with TickerProviderStateMixin {
  double _zoomLevel = 1.0;
  final double _minZoom = 0.5;
  final double _maxZoom = 2.0;
  final double _zoomStep = 0.1;
  Offset _offset = Offset.zero;
  bool _isDragging = false;

  void _zoomIn() {
    setState(() {
      _zoomLevel = (_zoomLevel + _zoomStep).clamp(_minZoom, _maxZoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoomLevel = (_zoomLevel - _zoomStep).clamp(_minZoom, _maxZoom);
    });
  }

  void _resetZoom() {
    setState(() {
      _zoomLevel = 1.0;
      _offset = Offset.zero;
    });
  }

  void _handleContextMenuAction(String action) {
    print('Context menu action: $action for widget ID: ${Provider.of<WidgetTreeProvider>(context, listen: false).selectedNode?.id}');
    // You would implement actual logic for each action here
    // For example:
    // if (action == 'delete') {
    //   Provider.of<WidgetTreeProvider>(context, listen: false).deleteNode(provider.selectedNode!.id);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return CanvasPreviewMode(
      isLivePreview: widget.isLivePreview,
      child: Container(
        color: const Color(0xFF020408), // Darker professional background
        child: Stack(
          fit: StackFit.expand,
          children: [
            Transform(
              transform: Matrix4.identity()
                ..translate(_offset.dx, _offset.dy)
                ..scale(_zoomLevel),
              alignment: Alignment.center,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Minimalist dotted grid
                  CustomPaint(
                    painter: DottedGridPainter(
                      color: Colors.white.withOpacity(0.05),
                      gridSize: 30,
                    ),
                    child: Container(),
                  ),
                  Center(
                    child: Container(
                      width: 380,
                      height: 780,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(54),
                        border: Border.all(color: const Color(0xFF1E293B), width: 8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 40,
                            spreadRadius: 5,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Dynamic Island
                          Positioned(
                            top: 12,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                width: 100,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                          // Screen content
                          Positioned.fill(
                            top: 10,
                            left: 10,
                            right: 10,
                            bottom: 10,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(44),
                              child: Container(
                                color: const Color(0xFF030712),
                                child: Consumer<WidgetTreeProvider>(
                                  builder: (context, provider, _) => _buildCanvasContent(context, provider, provider.hoveredNode),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 32,
              bottom: 32,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withOpacity(0.9), // Darker slate
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildZoomBtn(Icons.add, _zoomIn),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        '${(_zoomLevel * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    _buildZoomBtn(Icons.remove, _zoomOut),
                    Container(
                      width: 20,
                      height: 1,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Colors.white.withOpacity(0.1),
                    ),
                    _buildZoomBtn(Icons.refresh, _resetZoom),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildCanvasContent(BuildContext context, WidgetTreeProvider provider, WidgetNode? hoveredNode) {
    return Stack(
      children: [
        // Background with pan/zoom handling
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onPanStart: (details) {
              if (_zoomLevel > 1.0) {
                setState(() => _isDragging = true);
              }
            },
            onPanUpdate: (details) {
              if (_isDragging && _zoomLevel > 1.0) {
                setState(() {
                  _offset += details.delta;
                });
              }
            },
            onPanEnd: (details) {
              setState(() => _isDragging = false);
            },
            child: Container(
              color: const Color(0xFF030712),
            ),
          ),
        ),
        // Preview content
        DragTarget<String>(
          onWillAccept: (data) => true,
          onAccept: (data) {
            if (data.startsWith('ThemedWidget:')) {
              final themedId = data.substring('ThemedWidget:'.length);
              final newNode = WidgetNode(
                type: 'ThemedWidget',
                properties: {'themedWidgetId': themedId},
              );
              final parent = provider.selectedNode ?? provider.rootNode;
              if (parent != null) {
                provider.addChild(parent, newNode);
              } else {
                provider.setRootNode(newNode);
              }
            } else {
              provider.addNode(data, parent: provider.selectedNode ?? provider.rootNode);
            }
          },
          builder: (context, candidateData, rejectedData) {
            return Center(
              child: provider.rootNode == null 
                  ? const SizedBox.shrink() 
                  : Theme(
                      key: ValueKey('${provider.themeProperties.toString()}_${provider.rootNode?.id}'),
                      data: _buildThemeData(provider.themeProperties),
                      child: _buildScreenWrapper(context, provider, hoveredNode),
                    ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildScreenWrapper(BuildContext context, WidgetTreeProvider provider, WidgetNode? hoveredNode) {
    Widget content = WidgetBuilderFactory.buildWidget(context, provider.rootNode!, hoveredNode);
    
    // BottomNavigationBar requires at least 2 items.
    // Provider state can briefly become inconsistent while editing screens, so guard hard here.
    final screens = provider.screens;
    if (screens.length >= 2) {
      bool hasBuiltInNavBar = false;
      for (var s in screens) {
        if (s.type == 'Scaffold' && s.properties['bottomNavigationBar'] != null) {
          hasBuiltInNavBar = true;
          break;
        }
      }

      if (!hasBuiltInNavBar) {
        int currentIndex = screens.indexWhere((s) => s.id == provider.rootNode?.id);
        if (currentIndex < 0) currentIndex = 0;
        if (currentIndex >= screens.length) currentIndex = 0;
        
        final items = screens.map((s) {
        final name = s.properties['pageName'] ?? s.id ?? 'Screen';
        return BottomNavigationBarItem(
          icon: Icon(_getIconForScreenName(name.toString())),
          label: name.toString(),
        );
      }).toList();

      if (items.length >= 2) {
        content = Scaffold(
          backgroundColor: Colors.transparent,
          body: content,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              final screen = screens[index];
              provider.selectScreen(screen);
            },
            type: BottomNavigationBarType.fixed,
            items: items,
          ),
        );
      }
      }
    }
    
    return content;
  }

  IconData _getIconForScreenName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('home') || lower.contains('dash')) return Icons.home;
    if (lower.contains('profile') || lower.contains('user') || lower.contains('account')) return Icons.person;
    if (lower.contains('set')) return Icons.settings;
    if (lower.contains('search')) return Icons.search;
    if (lower.contains('cart')) return Icons.shopping_cart;
    if (lower.contains('fav')) return Icons.favorite;
    if (lower.contains('work') || lower.contains('fit') || lower.contains('train')) return Icons.fitness_center;
    if (lower.contains('activ')) return Icons.local_activity;
    if (lower.contains('list')) return Icons.list_alt;
    if (lower.contains('med')) return Icons.medical_services;
    return Icons.dashboard;
  }

  ThemeData _buildThemeData(Map<String, dynamic> props) {
    final primary = ColorUtils.parseColor(props['primaryColor'], Colors.indigo);
    final secondary = ColorUtils.parseColor(props['secondaryColor'], Colors.teal);
    final tertiary = ColorUtils.parseColor(props['tertiaryColor'], Colors.amber);
    final surface = ColorUtils.parseColor(props['backgroundColor'], Colors.white);
    final scaffoldBg = ColorUtils.parseColor(props['scaffoldBackgroundColor'], Colors.white);
    final error = ColorUtils.parseColor(props['errorColor'], Colors.red);
    final isM3 = props['useMaterial3'] ?? true;
    final fontFamily = props['fontFamily'] ?? 'Outfit';

    TextStyle buildTextStyle(Map<String, dynamic>? m) {
      if (m == null) return const TextStyle();
      return TextStyle(
        fontSize: (m['fontSize'] as num?)?.toDouble(),
        fontWeight: _parseFontWeight(m['fontWeight']),
        letterSpacing: (m['letterSpacing'] as num?)?.toDouble(),
      );
    }

    return ThemeData(
      useMaterial3: isM3,
      primaryColor: primary,
      scaffoldBackgroundColor: scaffoldBg,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        tertiary: tertiary,
        surface: surface,
        error: error,
      ),
      textTheme: TextTheme(
        displayLarge: buildTextStyle(props['displayLarge'] as Map<String, dynamic>?),
        displayMedium: buildTextStyle(props['displayMedium'] as Map<String, dynamic>?),
        displaySmall: buildTextStyle(props['displaySmall'] as Map<String, dynamic>?),
        headlineLarge: buildTextStyle(props['headlineLarge'] as Map<String, dynamic>?),
        headlineMedium: buildTextStyle(props['headlineMedium'] as Map<String, dynamic>?),
        headlineSmall: buildTextStyle(props['headlineSmall'] as Map<String, dynamic>?),
        titleLarge: buildTextStyle(props['titleLarge'] as Map<String, dynamic>?),
        titleMedium: buildTextStyle(props['titleMedium'] as Map<String, dynamic>?),
        titleSmall: buildTextStyle(props['titleSmall'] as Map<String, dynamic>?),
        labelLarge: buildTextStyle(props['labelLarge'] as Map<String, dynamic>?),
        bodyLarge: buildTextStyle(props['bodyLarge'] as Map<String, dynamic>?),
        bodyMedium: buildTextStyle(props['bodyMedium'] as Map<String, dynamic>?),
        bodySmall: buildTextStyle(props['bodySmall'] as Map<String, dynamic>?),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: Colors.black87,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
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
    if (value == null) return FontWeight.normal;
    if (value is String) {
      switch (value) {
        case 'Bold': return FontWeight.bold;
        case 'Medium': return FontWeight.w500;
        case 'Light': return FontWeight.w300;
        case 'Thin': return FontWeight.w100;
        case 'Normal':
        default: return FontWeight.normal;
      }
    }
    return FontWeight.normal;
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
 