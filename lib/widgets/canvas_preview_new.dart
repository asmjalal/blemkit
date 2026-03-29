import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/widget_tree_provider.dart';
import '../models/widget_node.dart';
import 'package:dotted_border/dotted_border.dart';
import 'canvas_preview/builders/widget_builder_factory.dart';
import '../utils/color_utils.dart';
import 'package:designflutterkit/widgets/widget_context_menu/widget_context_menu.dart';

class CanvasPreview extends StatefulWidget {
  const CanvasPreview({super.key});

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
    return Container(
      color: const Color(0xFF181A20), // Full canvas/editor background
      child: Stack(
        fit: StackFit.expand, // Ensure the stack fills the canvas area
        children: [
          // Transform applies to everything (grid + phone)
          Transform(
            transform: Matrix4.identity()
              ..translate(_offset.dx, _offset.dy)
              ..scale(_zoomLevel),
            alignment: Alignment.center,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Grid as background of the whole canvas area
                CustomPaint(
                  painter: GridPainter(
                    color: Colors.white.withValues(alpha: 0.1),
                    gridSize: 20,
                  ),
                  child: Container(),
                ),
                Center(
                  child: Stack(
                    children: [
                      // Google Pixel bezel
                      Container(
                        width: 400,
                        height: 800,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22232E),
                          borderRadius: BorderRadius.circular(48),
                          border: Border.all(color: Colors.black, width: 6),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            // Notch/camera cutout
                            Positioned(
                              top: 0,
                              left: 120,
                              right: 120,
                              child: Container(
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: const BorderRadius.vertical(
                                    bottom: Radius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            // Device screen
                            Positioned.fill(
                              top: 24,
                              left: 12,
                              right: 12,
                              bottom: 12,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: Container(
                                  color: const Color(0xFF1a1b26),
                                  child: Consumer<WidgetTreeProvider>(
                                    builder: (context, provider, _) => _buildCanvasContent(context, provider, provider.hoveredNode),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 32,
            bottom: 32,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1e293b).withOpacity(0.9), // Darker slate
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildZoomBtn(Icons.remove, _zoomOut),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${(_zoomLevel * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  _buildZoomBtn(Icons.add, _zoomIn),
                  Container(
                    width: 1,
                    height: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                  _buildZoomBtn(Icons.refresh, _resetZoom),
                ],
              ),
            ),
          ),
        ],
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
              color: const Color(0xFF1a1b26),
            ),
          ),
        ),
        // Preview content
        DragTarget<String>(
          onWillAccept: (data) => true,
          onAccept: (type) {
            provider.addNode(type, parent: provider.selectedNode ?? provider.rootNode);
          },
          builder: (context, candidateData, rejectedData) {
            return Center(
              child: provider.rootNode == null 
                  ? const SizedBox.shrink() 
                  : Theme(
                      key: ValueKey('${provider.themeProperties.toString()}_${provider.rootNode?.id}'),
                      data: ThemeData(
                        useMaterial3: provider.themeProperties['useMaterial3'] ?? true,
                        colorScheme: ColorScheme.fromSeed(
                          seedColor: ColorUtils.parseColor(provider.themeProperties['primaryColor'], Colors.indigo),
                          primary: ColorUtils.parseColor(provider.themeProperties['primaryColor'], Colors.indigo),
                          secondary: ColorUtils.parseColor(provider.themeProperties['accentColor'], Colors.indigoAccent),
                          surface: ColorUtils.parseColor(provider.themeProperties['backgroundColor'], Colors.white),
                        ),
                        scaffoldBackgroundColor: ColorUtils.parseColor(provider.themeProperties['scaffoldBackgroundColor'], Colors.white),
                        fontFamily: provider.themeProperties['fontFamily'],
                      ),
                      child: WidgetBuilderFactory.buildWidget(context, provider.rootNode!, hoveredNode),
                    ),
            );
          },
        ),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  final Color color;
  final double gridSize;

  GridPainter({required this.color, required this.gridSize});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    // Draw vertical lines
    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }

    // Draw horizontal lines
    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
 