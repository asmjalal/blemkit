import 'package:flutter/material.dart';


class PremiumSearchBar extends StatelessWidget {
  final bool isCollapsed;
  final ValueChanged<String>? onChanged;
  const PremiumSearchBar({required this.isCollapsed, this.onChanged});

  @override
  Widget build(BuildContext context) {
    if (isCollapsed) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF23263a),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(Icons.search, color: Color(0xFFe2e8f0), size: 20),
          ),
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search widgets...",
                hintStyle: TextStyle(color: Color(0xFFa0aec0)),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              onChanged: onChanged,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Color(0xFFa0aec0), size: 20),
            onPressed: null,
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}