import 'package:designflutterkit/widgets/widget_sidebar/widget_side_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/widget_node.dart';
import '../../providers/widget_tree_provider.dart';

class CollapsibleWidgetTree extends StatelessWidget {
  final void Function(WidgetNode parent)? onAdd;
  final Map<WidgetNode, bool>? expanded;
  final void Function(WidgetNode node)? onExpandToggle;
  const CollapsibleWidgetTree({this.onAdd, this.expanded, this.onExpandToggle});

  @override
  Widget build(BuildContext context) {
    return Consumer<WidgetTreeProvider>(
      builder: (context, provider, child) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.account_tree_outlined, color: Colors.indigo),
                  const SizedBox(width: 8),
                  const Text(
                    'Widget Tree',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.indigo),
                    onPressed: () => onAdd?.call(provider.rootNode ?? provider.selectedNode!),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  if (provider.rootNode != null)
                    SidebarWidgetTreeNode(
                      node: provider.rootNode!,
                      selectedNode: provider.selectedNode,
                      onSelect: provider.selectNode,
                      onAdd: onAdd ?? (_) {},
                      onDelete: provider.removeNode,
                      depth: 0,
                      index: 0,
                      expanded: expanded ?? const {},
                      onExpandToggle: onExpandToggle,
                      onHover: provider.setHoveredNode,
                    )
                  else
                    const Center(child: Text('No widgets yet')),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, String>?> _showNewScreenDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF181A20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'New Page',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Page Name (required)',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      filled: true,
                      fillColor: const Color(0xFF23263a),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFF0fadd5)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    style: const TextStyle(color: Colors.white),
                    minLines: 2,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Page Description (optional)',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      filled: true,
                      fillColor: const Color(0xFF23263a),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFF0fadd5)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF23263a),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(color: Colors.white24),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0fadd5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          if (nameController.text.trim().isEmpty) return;
                          Navigator.of(context).pop({
                            'name': nameController.text.trim(),
                            'description': descController.text.trim(),
                          });
                        },
                        child: const Text('Create Page'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}