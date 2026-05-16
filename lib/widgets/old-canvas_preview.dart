// import 'package:designflutterkit/widgets/widget_context_menu/widget_context_menu.dart';
// import 'package:designflutterkit/widgets/widget_tree/widget_tree_editor.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../providers/widget_tree_provider.dart';
// import '../models/widget_node.dart';
// import 'package:dotted_border/dotted_border.dart';
// import 'package:designflutterkit/widgets/widget_context_menu/widget_context_menu_actions.dart';
// import 'package:designflutterkit/widgets/widget_context_menu/widget_command_manager.dart';
//
// class OldCanvasPreview extends StatefulWidget {
//   const OldCanvasPreview({super.key});
//
//   @override
//   State<OldCanvasPreview> createState() => _OldCanvasPreviewState();
// }
//
// class _OldCanvasPreviewState extends State<OldCanvasPreview> {
//   double _zoomLevel = 1.0;
//   final double _minZoom = 0.5;
//   final double _maxZoom = 2.0;
//   final double _zoomStep = 0.1;
//   Offset _offset = Offset.zero;
//   bool _isDragging = false;
//
//   void _zoomIn() {
//     setState(() {
//       _zoomLevel = (_zoomLevel + _zoomStep).clamp(_minZoom, _maxZoom);
//     });
//   }
//
//   void _zoomOut() {
//     setState(() {
//       _zoomLevel = (_zoomLevel - _zoomStep).clamp(_minZoom, _maxZoom);
//     });
//   }
//
//   void _resetZoom() {
//     setState(() {
//       _zoomLevel = 1.0;
//       _offset = Offset.zero;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: const Color(0xFF181A20), // Full canvas/editor background
//       child: Stack(
//         fit: StackFit.expand, // Ensure the stack fills the canvas area
//         children: [
//           // Transform applies to everything (grid + phone)
//           Transform(
//             transform: Matrix4.identity()
//               ..translate(_offset.dx, _offset.dy)
//               ..scale(_zoomLevel),
//             alignment: Alignment.center,
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 // Grid as background of the whole canvas area
//                 CustomPaint(
//                   painter: GridPainter(
//                     color: Colors.white.withOpacity(0.1),
//                     gridSize: 20,
//                   ),
//                   child: Container(),
//                 ),
//                 Center(
//                   child: Stack(
//                     children: [
//                       // Google Pixel bezel
//                       Container(
//                         width: 400,
//                         height: 800,
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF22232E),
//                           borderRadius: BorderRadius.circular(48),
//                           border: Border.all(color: Colors.black, width: 6),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.25),
//                               blurRadius: 24,
//                               offset: const Offset(0, 8),
//                             ),
//                           ],
//                         ),
//                         child: Stack(
//                           children: [
//                             // Notch/camera cutout
//                             Positioned(
//                               top: 0,
//                               left: 120,
//                               right: 120,
//                               child: Container(
//                                 height: 32,
//                                 decoration: BoxDecoration(
//                                   color: Colors.black,
//                                   borderRadius: const BorderRadius.vertical(
//                                     bottom: Radius.circular(16),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             // Device screen
//                             Positioned.fill(
//                               top: 24,
//                               left: 12,
//                               right: 12,
//                               bottom: 12,
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(32),
//                                 child: Container(
//                                   color: const Color(0xFF1a1b26),
//                                   child: _buildCanvasContent(context, Provider.of<WidgetTreeProvider>(context), Provider.of<WidgetTreeProvider>(context).hoveredNode),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Zoom controls outside the device, bottom-right of the canvas area
//           Positioned(
//             right: 32,
//             bottom: 32,
//             child: Card(
//               color: const Color(0xFF23263a),
//               elevation: 4,
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         onTap: _zoomOut,
//                         child: const Padding(
//                           padding: EdgeInsets.all(8.0),
//                           child: Icon(Icons.remove, color: Colors.white),
//                         ),
//                       ),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                       child: Text(
//                         '${(_zoomLevel * 100).toInt()}%',
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                     ),
//                     Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         onTap: _zoomIn,
//                         child: const Padding(
//                           padding: EdgeInsets.all(8.0),
//                           child: Icon(Icons.add, color: Colors.white),
//                         ),
//                       ),
//                     ),
//                     Material(
//                       color: Colors.transparent,
//                       child: InkWell(
//                         onTap: _resetZoom,
//                         child: const Padding(
//                           padding: EdgeInsets.all(8.0),
//                           child: Icon(Icons.refresh, color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCanvasContent(BuildContext context, WidgetTreeProvider provider, WidgetNode? hoveredNode) {
//     return Stack(
//       children: [
//         // Just use a plain background, no transform here
//         Container(
//           color: const Color(0xFF1a1b26),
//         ),
//         // Preview with zoom and pan
//         Center(
//           child: MouseRegion(
//             cursor: _zoomLevel > 1.0 ? SystemMouseCursors.move : SystemMouseCursors.basic,
//             child: GestureDetector(
//               behavior: HitTestBehavior.translucent,
//               onPanStart: (details) {
//                 if (_zoomLevel > 1.0) {
//                   setState(() => _isDragging = true);
//                 }
//               },
//               onPanUpdate: (details) {
//                 if (_isDragging) {
//                   setState(() {
//                     _offset += details.delta;
//                   });
//                 }
//               },
//               onPanEnd: (details) {
//                 setState(() => _isDragging = false);
//               },
//               child: _buildWidgetFromNode(provider.rootNode!, hoveredNode),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildWidgetFromNode(WidgetNode node, WidgetNode? hoveredNode) {
//     final isHovered = node.id == hoveredNode?.id;
//     final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
//     Widget wrapWithHoverAndContextMenu(Widget child) {
//       final isSelected = provider.selectedNode == node;
//       final showBorder = isSelected || isHovered;
//       final borderColor = isSelected ? Colors.deepPurple : Colors.deepPurpleAccent;
//       final dashPattern = isSelected ? [6.0, 3.0] : [3.0, 3.0]; // dashed for selected, dotted for hover
//
//       Widget bordered = showBorder
//           ? DottedBorder(
//         color: borderColor,
//         dashPattern: dashPattern,
//         borderType: BorderType.RRect,
//         radius: Radius.circular(8),
//         strokeWidth: 2,
//         child: child,
//       )
//           : child;
//
//       return MouseRegion(
//         onEnter: (_) => provider.setHoveredNode(node),
//         onExit: (_) => provider.setHoveredNode(null),
//         child: GestureDetector(
//           onTap: () {
//             provider.selectNode(node);
//           },
//           onSecondaryTapDown: (details) {
//             WidgetContextMenu.show(
//               context,
//               details.globalPosition,
//               widgetId: node.id,
//               onAction: (action) async {
//                 final root = provider.rootNode!;
//                 final _commandManager = WidgetCommandManager();
//                 switch (action) {
//                   case 'duplicate':
//                     _commandManager.executeAction(
//                       DuplicateWidgetAction(node: node, provider: provider, root: root),
//                     );
//                     break;
//                   case 'delete':
//                     final confirmed = await showDialog<bool>(
//                       context: context,
//                       builder: (context) {
//                         return Dialog(
//                           backgroundColor: const Color(0xFF181A20),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                           child: Padding(
//                             padding: const EdgeInsets.all(32.0),
//                             child: SizedBox(
//                               width: 400,
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     'Delete Widget',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 24,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 16),
//                                   const Text(
//                                     'Are you sure you want to delete this widget? This action cannot be undone.',
//                                     style: TextStyle(color: Colors.white70, fontSize: 16),
//                                   ),
//                                   const SizedBox(height: 32),
//                                   Row(
//                                     mainAxisAlignment: MainAxisAlignment.end,
//                                     children: [
//                                       TextButton(
//                                         onPressed: () => Navigator.of(context).pop(false),
//                                         child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
//                                       ),
//                                       const SizedBox(width: 16),
//                                       ElevatedButton(
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: const Color(0xFF0fadd5),
//                                           foregroundColor: Colors.white,
//                                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                                         ),
//                                         onPressed: () => Navigator.of(context).pop(true),
//                                         child: const Text('Delete'),
//                                       ),
//                                     ],
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                     if (confirmed == true) {
//                       _commandManager.executeAction(
//                         DeleteWidgetAction(node: node, provider: provider, root: root),
//                       );
//                     }
//                     break;
//                   case 'wrap':
//                     final wrapperTypes = ['Container', 'Padding', 'Center', 'Align', 'Expanded', 'Flexible', 'SizedBox'];
//                     final wrapperType = await showDialog<String>(
//                       context: context,
//                       builder: (context) {
//                         return Dialog(
//                           backgroundColor: const Color(0xFF181A20),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                           child: Padding(
//                             padding: const EdgeInsets.all(32.0),
//                             child: SizedBox(
//                               width: 400,
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     'Wrap Widget',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 24,
//                                     ),
//                                   ),
//                                   const SizedBox(height: 16),
//                                   const Text(
//                                     'Choose a wrapper widget:',
//                                     style: TextStyle(color: Colors.white70, fontSize: 16),
//                                   ),
//                                   const SizedBox(height: 24),
//                                   ...wrapperTypes.map((type) => ListTile(
//                                     title: Text(type, style: const TextStyle(color: Colors.white)),
//                                     onTap: () => Navigator.of(context).pop(type),
//                                   )),
//                                   const SizedBox(height: 8),
//                                   TextButton(
//                                     onPressed: () => Navigator.of(context).pop(),
//                                     child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     );
//                     if (wrapperType != null) {
//                       _commandManager.executeAction(
//                         WrapWidgetAction(
//                           node: node,
//                           provider: provider,
//                           root: root,
//                           wrapperType: wrapperType,
//                         ),
//                       );
//                     }
//                     break;
//                   case 'undo':
//                     _commandManager.undo();
//                     break;
//                   case 'redo':
//                     _commandManager.redo();
//                     break;
//                 // Add more cases as needed
//                 }
//               },
//             );
//           },
//           child: bordered,
//         ),
//       );
//     }
//     switch (node.type) {
//       case 'Container':
//         Widget container = Container(
//           width: node.properties['width']?.toDouble(),
//           height: node.properties['height']?.toDouble(),
//           alignment: _getAlignment(node.properties['alignment'] as String?),
//           padding: EdgeInsets.only(
//             top: node.properties['paddingTop']?.toDouble() ?? 0.0,
//             bottom: node.properties['paddingBottom']?.toDouble() ?? 0.0,
//             left: node.properties['paddingLeft']?.toDouble() ?? 0.0,
//             right: node.properties['paddingRight']?.toDouble() ?? 0.0,
//           ),
//           margin: EdgeInsets.only(
//             top: node.properties['marginTop']?.toDouble() ?? 0.0,
//             bottom: node.properties['marginBottom']?.toDouble() ?? 0.0,
//             left: node.properties['marginLeft']?.toDouble() ?? 0.0,
//             right: node.properties['marginRight']?.toDouble() ?? 0.0,
//           ),
//           decoration: BoxDecoration(
//             color: node.properties['color'] != null
//                 ? Color(int.parse(node.properties['color'].toString()))
//                 : null,
//             borderRadius: BorderRadius.circular(
//               (node.properties['borderRadius'] is num && node.properties['borderRadius'] != null)
//                   ? node.properties['borderRadius'].toDouble()
//                   : 0.0,
//             ),
//             border: (node.properties['borderWidth'] != null && node.properties['borderWidth'] > 0)
//                 ? Border.all(
//               color: node.properties['borderColor'] != null && int.tryParse(node.properties['borderColor']) != null
//                   ? Color(int.parse(node.properties['borderColor']))
//                   : Colors.black,
//               width: node.properties['borderWidth']?.toDouble() ?? 1.0,
//             )
//                 : null,
//             boxShadow: (node.properties['shadowBlur'] != null && node.properties['shadowBlur'] > 0)
//                 ? [
//               BoxShadow(
//                 color: node.properties['shadowColor'] != null && int.tryParse(node.properties['shadowColor']) != null
//                     ? Color(int.parse(node.properties['shadowColor']))
//                     : Colors.black26,
//                 blurRadius: node.properties['shadowBlur']?.toDouble() ?? 0.0,
//                 offset: Offset(
//                   node.properties['shadowX']?.toDouble() ?? 0.0,
//                   node.properties['shadowY']?.toDouble() ?? 0.0,
//                 ),
//               ),
//             ]
//                 : null,
//           ),
//           child: node.children.isEmpty
//               ? null
//               : _buildWidgetFromNode(node.children.first, hoveredNode),
//         );
//         return wrapWithHoverAndContextMenu(container);
//       case 'Padding':
//         double top = (node.properties['paddingTop'] is num) ? node.properties['paddingTop'].toDouble() : 0.0;
//         double right = (node.properties['paddingRight'] is num) ? node.properties['paddingRight'].toDouble() : 0.0;
//         double bottom = (node.properties['paddingBottom'] is num) ? node.properties['paddingBottom'].toDouble() : 0.0;
//         double left = (node.properties['paddingLeft'] is num) ? node.properties['paddingLeft'].toDouble() : 0.0;
//         Widget child = node.children.isNotEmpty
//             ? _buildWidgetFromNode(node.children.first, hoveredNode)
//             : const SizedBox.shrink();
//         Widget padding = Padding(
//           padding: EdgeInsets.only(top: top, right: right, bottom: bottom, left: left),
//           child: child,
//         );
//         return wrapWithHoverAndContextMenu(padding);
//       case 'Row': {
//         Widget row = Row(
//           mainAxisAlignment: _getMainAxisAlignment(node.properties['mainAxisAlignment'] as String?),
//           crossAxisAlignment: _getCrossAxisAlignment(node.properties['crossAxisAlignment'] as String?),
//           mainAxisSize: node.properties['mainAxisSize'] == 'min' ? MainAxisSize.min : MainAxisSize.max,
//           verticalDirection: node.properties['verticalDirection'] == 'up' ? VerticalDirection.up : VerticalDirection.down,
//           textDirection: node.properties['textDirection'] == 'rtl' ? TextDirection.rtl : TextDirection.ltr,
//           children: node.children
//               .map((child) => _buildWidgetFromNode(child, hoveredNode))
//               .toList(),
//         );
//         final padding = EdgeInsets.only(
//           top: node.properties['paddingTop']?.toDouble() ?? 0.0,
//           bottom: node.properties['paddingBottom']?.toDouble() ?? 0.0,
//           left: node.properties['paddingLeft']?.toDouble() ?? 0.0,
//           right: node.properties['paddingRight']?.toDouble() ?? 0.0,
//         );
//         final margin = EdgeInsets.only(
//           top: node.properties['marginTop']?.toDouble() ?? 0.0,
//           bottom: node.properties['marginBottom']?.toDouble() ?? 0.0,
//           left: node.properties['marginLeft']?.toDouble() ?? 0.0,
//           right: node.properties['marginRight']?.toDouble() ?? 0.0,
//         );
//         if (padding != EdgeInsets.zero) {
//           row = Padding(
//             padding: padding,
//             child: row,
//           );
//         }
//         if (margin != EdgeInsets.zero) {
//           row = Container(
//             margin: margin,
//             child: row,
//           );
//         }
//         if (node.properties['scrollable'] == true) {
//           row = SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: row,
//           );
//         }
//         return wrapWithHoverAndContextMenu(row);
//       }
//       case 'Column': {
//         Widget column = Column(
//           mainAxisAlignment: _getMainAxisAlignment(node.properties['mainAxisAlignment'] as String?),
//           crossAxisAlignment: _getCrossAxisAlignment(node.properties['crossAxisAlignment'] as String?),
//           mainAxisSize: node.properties['mainAxisSize'] == 'min' ? MainAxisSize.min : MainAxisSize.max,
//           verticalDirection: node.properties['verticalDirection'] == 'up' ? VerticalDirection.up : VerticalDirection.down,
//           textDirection: node.properties['textDirection'] == 'rtl' ? TextDirection.rtl : TextDirection.ltr,
//           children: node.children
//               .map((child) => _buildWidgetFromNode(child, hoveredNode))
//               .toList(),
//         );
//         final padding = EdgeInsets.only(
//           top: node.properties['paddingTop']?.toDouble() ?? 0.0,
//           bottom: node.properties['paddingBottom']?.toDouble() ?? 0.0,
//           left: node.properties['paddingLeft']?.toDouble() ?? 0.0,
//           right: node.properties['paddingRight']?.toDouble() ?? 0.0,
//         );
//         final margin = EdgeInsets.only(
//           top: node.properties['marginTop']?.toDouble() ?? 0.0,
//           bottom: node.properties['marginBottom']?.toDouble() ?? 0.0,
//           left: node.properties['marginLeft']?.toDouble() ?? 0.0,
//           right: node.properties['marginRight']?.toDouble() ?? 0.0,
//         );
//         if (padding != EdgeInsets.zero) {
//           column = Padding(
//             padding: padding,
//             child: column,
//           );
//         }
//         if (margin != EdgeInsets.zero) {
//           column = Container(
//             margin: margin,
//             child: column,
//           );
//         }
//         return wrapWithHoverAndContextMenu(column);
//       }
//       case 'Text':
//         Widget text = Text(
//           node.properties['text'] as String? ?? 'Text',
//           style: TextStyle(
//             fontSize: (node.properties['fontSize'] is num && node.properties['fontSize'] != null) ? node.properties['fontSize'].toDouble() : 14.0,
//             color: node.properties['color'] != null && int.tryParse(node.properties['color']) != null
//                 ? Color(int.parse(node.properties['color']))
//                 : Colors.black,
//             fontWeight: _getFontWeight(node.properties['fontWeight'] as String?),
//             fontStyle: node.properties['fontStyle'] == 'italic' ? FontStyle.italic : FontStyle.normal,
//             fontFamily: node.properties['fontFamily'] as String? ?? 'Roboto',
//             letterSpacing: (node.properties['letterSpacing'] is num && node.properties['letterSpacing'] != null) ? node.properties['letterSpacing'].toDouble() : 0.0,
//             wordSpacing: (node.properties['wordSpacing'] is num && node.properties['wordSpacing'] != null) ? node.properties['wordSpacing'].toDouble() : 0.0,
//             height: (node.properties['lineHeight'] is num && node.properties['lineHeight'] != null) ? node.properties['lineHeight'].toDouble() : 1.0,
//             decoration: _getTextDecoration(node.properties['textDecoration'] as String?),
//             shadows: (node.properties['shadowBlur'] != null && node.properties['shadowBlur'] > 0)
//                 ? [
//               Shadow(
//                 color: node.properties['shadowColor'] != null && int.tryParse(node.properties['shadowColor']) != null
//                     ? Color(int.parse(node.properties['shadowColor']))
//                     : Colors.black26,
//                 blurRadius: node.properties['shadowBlur']?.toDouble() ?? 0.0,
//                 offset: Offset(
//                   node.properties['shadowX']?.toDouble() ?? 0.0,
//                   node.properties['shadowY']?.toDouble() ?? 0.0,
//                 ),
//               ),
//             ]
//                 : null,
//           ),
//           textAlign: _getTextAlign(node.properties['textAlign'] as String?),
//           maxLines: (node.properties['maxLines'] is num && node.properties['maxLines'] != null) ? (node.properties['maxLines'] as num).toInt() : 1,
//           overflow: _getTextOverflow(node.properties['overflow'] as String?),
//           textDirection: node.properties['textDirection'] == 'rtl' ? TextDirection.rtl : TextDirection.ltr,
//           softWrap: node.properties['softWrap'] == true,
//         );
//         return wrapWithHoverAndContextMenu(text);
//       case 'ElevatedButton':
//         Widget button = ElevatedButton(
//           onPressed: () {},
//           child: node.children.isEmpty
//               ? Text(node.properties['text'] as String? ?? 'Button')
//               : _buildWidgetFromNode(node.children.first, hoveredNode),
//         );
//         return wrapWithHoverAndContextMenu(button);
//       case 'TextField':
//         Widget textField = TextField(
//           controller: node.properties['initialValue'] != null ? TextEditingController(text: node.properties['initialValue']) : null,
//           style: TextStyle(
//             fontSize: (node.properties['fontSize'] is num && node.properties['fontSize'] != null) ? node.properties['fontSize'].toDouble() : 14.0,
//             color: node.properties['textColor'] != null && int.tryParse(node.properties['textColor'].toString()) != null
//                 ? Color(int.parse(node.properties['textColor'].toString()))
//                 : Colors.black,
//             fontWeight: _getFontWeight(node.properties['fontWeight'] as String?),
//           ),
//           textAlign: _getTextAlign(node.properties['textAlign'] as String?),
//           decoration: InputDecoration(
//             hintText: node.properties['hintText'] as String?,
//             labelText: node.properties['labelText'] as String?,
//             filled: node.properties['filled'] == true,
//             fillColor: node.properties['inputFillColor'] != null && int.tryParse(node.properties['inputFillColor'].toString()) != null
//                 ? Color(int.parse(node.properties['inputFillColor'].toString()))
//                 : null,
//             border: _getInputBorder(node),
//             enabledBorder: _getInputBorder(node),
//             focusedBorder: _getInputBorder(node, focus: true),
//             errorBorder: _getInputBorder(node, error: true),
//             hoverColor: node.properties['hoverColor'] != null && int.tryParse(node.properties['hoverColor'].toString()) != null
//                 ? Color(int.parse(node.properties['hoverColor'].toString()))
//                 : null,
//             contentPadding: EdgeInsets.only(
//               top: (node.properties['contentPaddingTop'] ?? 0.0).toDouble(),
//               bottom: (node.properties['contentPaddingBottom'] ?? 0.0).toDouble(),
//               left: (node.properties['contentPaddingLeft'] ?? 0.0).toDouble(),
//               right: (node.properties['contentPaddingRight'] ?? 0.0).toDouble(),
//             ),
//           ),
//         );
//         return wrapWithHoverAndContextMenu(textField);
//       case 'AppBar':
//         Widget appBar = Material(
//           elevation: (node.properties['elevation'] is num && node.properties['elevation'] != null)
//               ? node.properties['elevation'].toDouble()
//               : 4.0,
//           color: node.properties['backgroundColor'] != null && int.tryParse(node.properties['backgroundColor']) != null
//               ? Color(int.parse(node.properties['backgroundColor']))
//               : Colors.blue,
//           child: Container(
//             height: 56,
//             alignment: (node.properties['centerTitle'] == true)
//                 ? Alignment.center
//                 : Alignment.centerLeft,
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Text(
//               node.properties['title'] as String? ?? 'App Bar',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: (node.properties['centerTitle'] == true)
//                   ? TextAlign.center
//                   : TextAlign.left,
//             ),
//           ),
//         );
//         return wrapWithHoverAndContextMenu(appBar);
//       case 'Image':
//         Widget image = Image.network(
//           node.properties['src'] ?? '',
//           width: node.properties['width']?.toDouble(),
//           height: node.properties['height']?.toDouble(),
//           fit: BoxFit.cover,
//           errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
//         );
//         return wrapWithHoverAndContextMenu(image);
//       case 'Icon':
//         Widget icon = Icon(
//           Icons.settings, // You can map string to IconData for more dynamic icons
//           size: node.properties['size']?.toDouble() ?? 24.0,
//           color: node.properties['color'] != null && int.tryParse(node.properties['color']) != null
//               ? Color(int.parse(node.properties['color']))
//               : Colors.black,
//         );
//         return wrapWithHoverAndContextMenu(icon);
//       case 'Button':
//         Widget button = ElevatedButton(
//           onPressed: () {},
//           child: Text(node.properties['text'] ?? 'Button'),
//         );
//         return wrapWithHoverAndContextMenu(button);
//       case 'IconButton':
//         Widget iconButton = IconButton(
//           icon: const Icon(Icons.add),
//           onPressed: () {},
//         );
//         return wrapWithHoverAndContextMenu(iconButton);
//       case 'Card':
//         Widget card = Card(
//           child: node.children.isNotEmpty
//               ? _buildWidgetFromNode(node.children.first, hoveredNode)
//               : const SizedBox.shrink(),
//         );
//         return wrapWithHoverAndContextMenu(card);
//       case 'ListView':
//         Widget listView = ListView(
//           shrinkWrap: node.properties['shrinkWrap'] ?? false,
//           scrollDirection: node.properties['scrollDirection'] == 'horizontal' ? Axis.horizontal : Axis.vertical,
//           children: node.children.map((child) => _buildWidgetFromNode(child, hoveredNode)).toList(),
//         );
//         return wrapWithHoverAndContextMenu(listView);
//       case 'GridView':
//         Widget gridView = GridView.count(
//           crossAxisCount: node.properties['crossAxisCount'] ?? 2,
//           mainAxisSpacing: node.properties['mainAxisSpacing']?.toDouble() ?? 0.0,
//           crossAxisSpacing: node.properties['crossAxisSpacing']?.toDouble() ?? 0.0,
//           childAspectRatio: node.properties['childAspectRatio']?.toDouble() ?? 1.0,
//           shrinkWrap: true,
//           children: node.children.map((child) => _buildWidgetFromNode(child, hoveredNode)).toList(),
//         );
//         return wrapWithHoverAndContextMenu(gridView);
//       case 'ExpansionTile':
//         Widget expansionTile = ExpansionTile(
//           title: Text(node.properties['title'] ?? 'Expansion Tile'),
//           initiallyExpanded: node.properties['initiallyExpanded'] ?? false,
//           children: node.children.map((child) => _buildWidgetFromNode(child, hoveredNode)).toList(),
//         );
//         return wrapWithHoverAndContextMenu(expansionTile);
//       case 'FAB':
//         Widget fab = FloatingActionButton(
//           onPressed: () {},
//           backgroundColor: node.properties['backgroundColor'] != null && int.tryParse(node.properties['backgroundColor']) != null
//               ? Color(int.parse(node.properties['backgroundColor']))
//               : Colors.blue,
//           child: const Icon(Icons.add),
//         );
//         return wrapWithHoverAndContextMenu(fab);
//       case 'Drawer':
//         Widget drawer = Drawer(
//           child: ListView(
//             children: node.children.map((child) => _buildWidgetFromNode(child, hoveredNode)).toList(),
//           ),
//         );
//         return wrapWithHoverAndContextMenu(drawer);
//       case 'EndDrawer':
//         Widget endDrawer = Drawer(
//           child: ListView(
//             children: node.children.map((child) => _buildWidgetFromNode(child, hoveredNode)).toList(),
//           ),
//         );
//         return wrapWithHoverAndContextMenu(endDrawer);
//       case 'RichText':
//         Widget richText = Text(node.properties['text'] ?? 'Rich Text');
//         return wrapWithHoverAndContextMenu(richText);
//       case 'CircleImage':
//         Widget circleImage = CircleAvatar(
//           radius: node.properties['radius'] is num ? node.properties['radius'].toDouble() : 20.0,
//           backgroundColor: node.properties['backgroundColor'] is int ? Color(node.properties['backgroundColor']) : Colors.grey,
//           child: node.children.isNotEmpty ? _buildWidgetFromNode(node.children.first, hoveredNode) : null,
//         );
//         return wrapWithHoverAndContextMenu(circleImage);
//       case 'ListTile':
//         return ListTile(
//           leading: node.properties['leading'] != null ? _buildWidgetFromNode(node.properties['leading'], hoveredNode) : null,
//           title: node.properties['title'] != null ? Text(node.properties['title']) : null,
//           subtitle: node.properties['subtitle'] != null ? Text(node.properties['subtitle']) : null,
//           trailing: node.properties['trailing'] != null ? _buildWidgetFromNode(node.properties['trailing'], hoveredNode) : null,
//           onTap: () {},
//         );
//       case 'SlidableListTile':
//         return ListTile(
//           title: Text(node.properties['title'] ?? 'Slidable List Tile'),
//           subtitle: Text(node.properties['subtitle'] ?? ''),
//         );
//       case 'DropDown':
//         return DropdownButton<String>(
//           hint: Text(node.properties['hint'] ?? 'Select an option'),
//           items: [],
//           onChanged: (_) {},
//         );
//       case 'Checkbox':
//         return Checkbox(
//           value: node.properties['value'] ?? false,
//           onChanged: (_) {},
//         );
//       case 'CheckboxListTile':
//         return CheckboxListTile(
//           title: Text(node.properties['title'] ?? 'Checkbox List Tile'),
//           value: node.properties['value'] ?? false,
//           onChanged: (_) {},
//         );
//       case 'Switch':
//         return Switch(
//           value: node.properties['value'] ?? false,
//           onChanged: (_) {},
//         );
//       case 'SwitchListTile':
//         return SwitchListTile(
//           title: Text(node.properties['title'] ?? 'Switch List Tile'),
//           value: node.properties['value'] ?? false,
//           onChanged: (_) {},
//         );
//       case 'RadioButton':
//         return Radio<bool>(
//           value: true,
//           groupValue: node.properties['value'] ?? false,
//           onChanged: (_) {},
//         );
//       case 'PinCode':
//         return Text('PinCode Widget');
//       case 'Slider':
//         return Slider(
//           value: (node.properties['value'] is num) ? node.properties['value'].toDouble() : 0.0,
//           min: (node.properties['min'] is num) ? node.properties['min'].toDouble() : 0.0,
//           max: (node.properties['max'] is num) ? node.properties['max'].toDouble() : 100.0,
//           onChanged: (_) {},
//         );
//       case 'RatingBar':
//         return Text('RatingBar Widget');
//       case 'CreditCardForm':
//         return Text('CreditCardForm Widget');
//       case 'CounterButton':
//         return Text('CounterButton Widget');
//       case 'ChoiceChips':
//         return Text('ChoiceChips Widget');
//       case 'PlacePicker':
//         return Text('PlacePicker Widget');
//       case 'FormValidation':
//         return Text('FormValidation Widget');
//       case 'CheckboxGroup':
//         return Text('CheckboxGroup Widget');
//       case 'Signature':
//         return Text('Signature Widget');
//       case 'Scaffold':
//       // Find AppBar, body, floatingActionButton, drawer, endDrawer children
//         Widget? appBarWidget;
//         Widget? bodyWidget;
//         Widget? fabWidget;
//         Widget? drawerWidget;
//         Widget? endDrawerWidget;
//         for (final child in node.children) {
//           if (child.type == 'AppBar') {
//             appBarWidget = _buildWidgetFromNode(child, hoveredNode);
//           } else if (child.type == 'FAB' || child.type == 'FloatingActionButton') {
//             fabWidget ??= _buildWidgetFromNode(child, hoveredNode);
//           } else if (child.type == 'Drawer') {
//             drawerWidget ??= _buildWidgetFromNode(child, hoveredNode);
//           } else if (child.type == 'EndDrawer') {
//             endDrawerWidget ??= _buildWidgetFromNode(child, hoveredNode);
//           } else {
//             // All other widgets go into the body
//             if (bodyWidget == null) {
//               bodyWidget = _buildWidgetFromNode(child, hoveredNode);
//             } else {
//               // If we already have a body widget, wrap it in a Column
//               bodyWidget = Column(
//                 children: [
//                   bodyWidget,
//                   _buildWidgetFromNode(child, hoveredNode),
//                 ],
//               );
//             }
//           }
//         }
//         return wrapWithHoverAndContextMenu(Scaffold(
//           backgroundColor: node.properties['backgroundColor'] != null && int.tryParse(node.properties['backgroundColor']) != null
//               ? Color(int.parse(node.properties['backgroundColor']))
//               : Colors.white,
//           appBar: appBarWidget != null
//               ? PreferredSize(
//             preferredSize: const Size.fromHeight(56),
//             child: appBarWidget,
//           )
//               : null,
//           body: bodyWidget,
//           floatingActionButton: fabWidget,
//           drawer: drawerWidget,
//           endDrawer: endDrawerWidget,
//         ));
//       case 'BottomNavigationBar':
//         return BottomNavigationBar(
//           items: node.children.map((child) => _buildBottomNavigationBarItemFromNode(child)).toList(),
//           currentIndex: 0,
//           onTap: (_) {},
//         );
//       default:
//         Widget unknown = Container(
//           color: Colors.red.shade100,
//           child: Center(child: Text('Unknown: \\${node.type}')),
//         );
//         return wrapWithHoverAndContextMenu(unknown);
//     }
//   }
//
//   MainAxisAlignment _getMainAxisAlignment(String? alignment) {
//     switch (alignment) {
//       case 'start':
//         return MainAxisAlignment.start;
//       case 'end':
//         return MainAxisAlignment.end;
//       case 'center':
//         return MainAxisAlignment.center;
//       case 'spaceBetween':
//         return MainAxisAlignment.spaceBetween;
//       case 'spaceAround':
//         return MainAxisAlignment.spaceAround;
//       case 'spaceEvenly':
//         return MainAxisAlignment.spaceEvenly;
//       default:
//         return MainAxisAlignment.start;
//     }
//   }
//
//   Alignment _getAlignment(String? alignment) {
//     switch (alignment) {
//       case 'topLeft':
//         return Alignment.topLeft;
//       case 'topCenter':
//         return Alignment.topCenter;
//       case 'topRight':
//         return Alignment.topRight;
//       case 'centerLeft':
//         return Alignment.centerLeft;
//       case 'center':
//         return Alignment.center;
//       case 'centerRight':
//         return Alignment.centerRight;
//       case 'bottomLeft':
//         return Alignment.bottomLeft;
//       case 'bottomCenter':
//         return Alignment.bottomCenter;
//       case 'bottomRight':
//         return Alignment.bottomRight;
//       default:
//         return Alignment.center;
//     }
//   }
//
//   FontWeight _getFontWeight(String? weight) {
//     switch (weight) {
//       case 'bold':
//         return FontWeight.bold;
//       case 'w100':
//         return FontWeight.w100;
//       case 'w200':
//         return FontWeight.w200;
//       case 'w300':
//         return FontWeight.w300;
//       case 'w400':
//         return FontWeight.w400;
//       case 'w500':
//         return FontWeight.w500;
//       case 'w600':
//         return FontWeight.w600;
//       case 'w700':
//         return FontWeight.w700;
//       case 'w800':
//         return FontWeight.w800;
//       case 'w900':
//         return FontWeight.w900;
//       default:
//         return FontWeight.normal;
//     }
//   }
//
//   TextAlign _getTextAlign(String? align) {
//     switch (align) {
//       case 'left':
//         return TextAlign.left;
//       case 'center':
//         return TextAlign.center;
//       case 'right':
//         return TextAlign.right;
//       case 'justify':
//         return TextAlign.justify;
//       case 'end':
//         return TextAlign.end;
//       case 'start':
//       default:
//         return TextAlign.start;
//     }
//   }
//
//   TextDecoration _getTextDecoration(String? decoration) {
//     switch (decoration) {
//       case 'underline':
//         return TextDecoration.underline;
//       case 'lineThrough':
//         return TextDecoration.lineThrough;
//       case 'overline':
//         return TextDecoration.overline;
//       default:
//         return TextDecoration.none;
//     }
//   }
//
//   TextOverflow _getTextOverflow(String? overflow) {
//     switch (overflow) {
//       case 'ellipsis':
//         return TextOverflow.ellipsis;
//       case 'fade':
//         return TextOverflow.fade;
//       case 'visible':
//         return TextOverflow.visible;
//       case 'clip':
//       default:
//         return TextOverflow.clip;
//     }
//   }
//
//   CrossAxisAlignment _getCrossAxisAlignment(String? align) {
//     switch (align) {
//       case 'start':
//         return CrossAxisAlignment.start;
//       case 'center':
//         return CrossAxisAlignment.center;
//       case 'end':
//         return CrossAxisAlignment.end;
//       case 'stretch':
//         return CrossAxisAlignment.stretch;
//       case 'baseline':
//         return CrossAxisAlignment.baseline;
//       default:
//         return CrossAxisAlignment.center;
//     }
//   }
//
//   IconData _iconDataFromString(String? iconName) {
//     switch (iconName) {
//       case 'home':
//         return Icons.home;
//       case 'shopping_cart':
//         return Icons.shopping_cart;
//       case 'person':
//         return Icons.person;
//       default:
//         return Icons.help_outline;
//     }
//   }
//
//   BottomNavigationBarItem _buildBottomNavigationBarItemFromNode(WidgetNode node) {
//     return BottomNavigationBarItem(
//       icon: Icon(_iconDataFromString(node.properties['icon'] as String?)),
//       label: node.properties['label'] as String? ?? '',
//     );
//   }
//
//   // Helper methods for TextField rendering
//   InputBorder _getInputBorder(WidgetNode node, {bool focus = false, bool error = false}) {
//     final borderType = node.properties['inputBorderType'] as String? ?? 'Outline';
//     final borderColor = error
//         ? (node.properties['errorBorderColor'] != null && int.tryParse(node.properties['errorBorderColor'].toString()) != null
//         ? Color(int.parse(node.properties['errorBorderColor'].toString()))
//         : Colors.red)
//         : focus
//         ? (node.properties['focusBorderColor'] != null && int.tryParse(node.properties['focusBorderColor'].toString()) != null
//         ? Color(int.parse(node.properties['focusBorderColor'].toString()))
//         : Colors.blue)
//         : (node.properties['inputBorderColor'] != null && int.tryParse(node.properties['inputBorderColor'].toString()) != null
//         ? Color(int.parse(node.properties['inputBorderColor'].toString()))
//         : Colors.black);
//     final borderWidth = (node.properties['inputBorderWidth'] is num && node.properties['inputBorderWidth'] != null)
//         ? node.properties['inputBorderWidth'].toDouble()
//         : 1.0;
//     final borderRadius = (node.properties['inputBorderRadius'] is num && node.properties['inputBorderRadius'] != null)
//         ? node.properties['inputBorderRadius'].toDouble()
//         : 8.0;
//     switch (borderType) {
//       case 'Underline':
//         return UnderlineInputBorder(
//           borderSide: BorderSide(color: borderColor, width: borderWidth),
//         );
//       case 'None':
//         return InputBorder.none;
//       case 'Outline':
//       default:
//         return OutlineInputBorder(
//           borderRadius: BorderRadius.circular(borderRadius),
//           borderSide: BorderSide(color: borderColor, width: borderWidth),
//         );
//     }
//   }
// }
//
// class GridPainter extends CustomPainter {
//   final Color color;
//   final double gridSize;
//
//   GridPainter({required this.color, required this.gridSize});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..strokeWidth = 0.5;
//
//     // Draw vertical lines
//     for (double i = 0; i < size.width; i += gridSize) {
//       canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
//     }
//
//     // Draw horizontal lines
//     for (double i = 0; i < size.height; i += gridSize) {
//       canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }