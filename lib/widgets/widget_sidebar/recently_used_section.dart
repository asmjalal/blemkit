import 'package:flutter/material.dart';


class RecentlyUsedSection extends StatelessWidget {
  final List<Map<String, dynamic>> recentlyUsed;
  const RecentlyUsedSection({required this.recentlyUsed});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recently Used',
          style: TextStyle(
            color: Color(0xFFe2e8f0),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 56,
          child: Row(
            children: [
              Expanded(
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: recentlyUsed.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, idx) {
                    final widgetInfo = recentlyUsed[idx];
                    return Container(
                      width: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2d3748).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(widgetInfo['icon'] as IconData, color: Colors.white70, size: 20),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}