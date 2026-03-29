import 'package:flutter/material.dart';

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSave;
  final VoidCallback onExport;
  final VoidCallback onNew;
  final VoidCallback onLoad;
  final VoidCallback onTemplate;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;

  const TopNavBar({
    super.key,
    required this.onSave,
    required this.onExport,
    required this.onNew,
    required this.onLoad,
    required this.onTemplate,
    this.onUndo,
    this.onRedo,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Logo and Title
          const Icon(Icons.auto_awesome_mosaic, color: Color(0xFF6366f1), size: 28),
          const SizedBox(width: 12),
          const Text(
            'Flutter Design Kit',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          
          // Action Icons
          _buildActionIcon(Icons.add_circle_outline, onNew, 'New Design'),
          _buildActionIcon(Icons.file_open_outlined, onLoad, 'Load Design'),
          _buildActionIcon(Icons.dashboard_customize_outlined, onTemplate, 'Choose Template'),
          _buildActionIcon(Icons.save_outlined, onSave, 'Save Design'),
          _buildActionIcon(Icons.undo, onUndo ?? () {}, 'Undo'),
          _buildActionIcon(Icons.redo, onRedo ?? () {}, 'Redo'),
          
          const SizedBox(width: 16),
          
          // Export Button
          ElevatedButton.icon(
            onPressed: onExport,
            icon: const Icon(Icons.code, size: 18),
            label: const Text(
              'Export Code',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366f1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap, [String? tooltip]) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: IconButton(
        icon: Icon(icon, color: Colors.black87, size: 22),
        onPressed: onTap,
        tooltip: tooltip,
        splashRadius: 24,
      ),
    );
  }
}
