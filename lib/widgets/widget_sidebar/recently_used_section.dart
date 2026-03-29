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
            fontWeight: FontWeight.bold,
            fontSize: 15,
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
                        color: const Color(0xFF23263a),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.10),
                            blurRadius: 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(widgetInfo['icon'] as IconData, color: Colors.white, size: 28),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF23263a),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, color: Color(0xFF6366f1), size: 20),
                  onPressed: () {},
                  splashRadius: 20,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}