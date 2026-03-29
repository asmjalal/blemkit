import 'package:flutter/material.dart';

class WidgetCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const WidgetCard({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Draggable<String>(
      data: label,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.7,
          child: _buildCard(),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: _buildCard(),
      ),
      child: _buildCard(),
    );
  }

  Widget _buildCard() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 80, // Added fixed width for palette consistency
          height: 80, // Added fixed height
          decoration: BoxDecoration(
            color: const Color(0xFF23263a),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Center(child: Icon(icon, color: Colors.white, size: 26)),

              Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
