import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/widget_node.dart';
import '../../../providers/widget_tree_provider.dart';
import 'widget_builder_factory.dart';

import '../canvas_preview_mode.dart';

class SupabaseRowDataContext extends InheritedWidget {
  final Map<String, dynamic> rowData;

  const SupabaseRowDataContext({
    super.key,
    required this.rowData,
    required super.child,
  });

  static Map<String, dynamic>? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<SupabaseRowDataContext>()?.rowData;
  }

  @override
  bool updateShouldNotify(SupabaseRowDataContext oldWidget) => rowData != oldWidget.rowData;
}

class SupabaseQueryWrapper extends StatelessWidget {
  final WidgetNode node;
  final WidgetNode? hoveredNode;
  final Widget Function(BuildContext context, List<Map<String, dynamic>> data) builder;

  const SupabaseQueryWrapper({
    super.key,
    required this.node,
    required this.hoveredNode,
    required this.builder,
  });

  List<Map<String, dynamic>> _getMockDataForTable(String tableName) {
    final lowerName = tableName.toLowerCase();
    if (lowerName.contains('product')) {
      return [
        {
          "id": "11111111-1111-1111-1111-111111111111",
          "name": "Speed Runner Red",
          "price": "\$129.99",
          "image_url": "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400",
          "description": "Aerodynamic performance running shoes designed for ultimate speed and comfortable cushioning.",
          "category": "Sneakers"
        },
        {
          "id": "22222222-2222-2222-2222-222222222222",
          "name": "Minimalist Leather Watch",
          "price": "\$199.50",
          "image_url": "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=400",
          "description": "Elegant luxury analog watch with genuine black leather strap and clean stainless steel bezel.",
          "category": "Watches"
        }
      ];
    }
    if (lowerName.contains('cart')) {
      return [
        {
          "id": "cart_1",
          "product_id": "11111111-1111-1111-1111-111111111111",
          "name": "Speed Runner Red",
          "price": "\$129.99",
          "image_url": "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400",
          "quantity": 1
        }
      ];
    }
    return [
      {"id": "mock_1", "name": "Placeholder Item 1", "title": "Placeholder Title 1", "price": "\$9.99"},
      {"id": "mock_2", "name": "Placeholder Item 2", "title": "Placeholder Title 2", "price": "\$19.99"}
    ];
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final attachedQuery = node.backendQuery;
    final bool isPreview = CanvasPreviewMode.of(context);
    final String tableName = attachedQuery?['tableName'] as String? ?? 'products';
    
    if (attachedQuery == null || provider.activeConnection == null) {
      final mockData = _getMockDataForTable(tableName);
      return builder(context, mockData);
    }

    final queryId = attachedQuery['queryId'] as String;
    final queryObj = provider.queries.where((q) => q.id == queryId).firstOrNull;

    if (queryObj == null) {
      final mockData = _getMockDataForTable(tableName);
      return builder(context, mockData);
    }

    // If result is not cached, run it and show loading shimmer
    if (!provider.queryResults.containsKey(queryId)) {
      provider.runQuery(queryId);
      return _buildShimmerLoading();
    }

    final results = provider.queryResults[queryId]!;

    if (results.isEmpty) {
      if (!isPreview) {
        // Show mock data in the builder editor so the designer can edit cards visually
        final mockData = _getMockDataForTable(queryObj.tableName);
        return builder(context, mockData);
      }
      return _buildEmptyState(queryObj.tableName);
    }

    return builder(context, results);
  }

  Widget _buildShimmerLoading() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(3, (index) => Card(
          color: const Color(0xFF1E293B).withOpacity(0.5),
          margin: const EdgeInsets.only(bottom: 12),
          child: Container(
            height: 72,
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(8)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(height: 12, width: 120, color: Colors.white12),
                      const SizedBox(height: 6),
                      Container(height: 8, width: 200, color: Colors.white10),
                    ],
                  ),
                )
              ],
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildEmptyState(String tableName) {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, size: 48, color: Colors.white24),
          const SizedBox(height: 12),
          Text(
            'No rows found in table "$tableName"',
            style: const TextStyle(color: Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Verify your filters or insert some rows into your database.',
            style: TextStyle(color: Colors.white30, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
