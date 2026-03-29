import 'package:designflutterkit/widgets/widget_sidebar/widget_card.dart';
import 'package:flutter/material.dart';


class WidgetCategoriesSection extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final int selectedCategory;
  final ValueChanged<int> onCategorySelected;
  final String search;
  final void Function(String type)? onWidgetAdd;
  const WidgetCategoriesSection({required this.categories, required this.selectedCategory, required this.onCategorySelected, required this.search, this.onWidgetAdd});

  @override
  Widget build(BuildContext context) {
    final widgets = (categories[selectedCategory]['widgets'] as List<Map<String, dynamic>>)
        .where((w) => search.isEmpty || w['type'].toLowerCase().contains(search.toLowerCase()))
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < categories.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onCategorySelected(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                      decoration: BoxDecoration(
                        color: selectedCategory == i ? const Color(0xFF6366f1) : const Color(0xFF23263a),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        categories[i]['name'],
                        style: TextStyle(
                          color: selectedCategory == i ? Colors.white : const Color(0xFFe2e8f0),
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Widget Grid
        Expanded(
          child: GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 400 ? 3 : 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.1,
            children: [
              for (final widget in widgets)
                WidgetCard(
                  icon: widget['icon'] as IconData,
                  label: widget['type'] as String,
                  onTap: onWidgetAdd == null ? null : () => onWidgetAdd!(widget['type'] as String),
                ),
            ],
          ),
        ),
      ],
    );
  }
}