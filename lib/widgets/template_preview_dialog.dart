import 'package:flutter/material.dart';
import '../models/widget_node.dart';
import 'template_custom_dialog.dart';

class TemplatePreviewDialog extends StatelessWidget {
  final Map<String, dynamic> template;
  final VoidCallback onUse;

  const TemplatePreviewDialog({
    super.key,
    required this.template,
    required this.onUse,
  });

  static void show(BuildContext context, Map<String, dynamic> template, VoidCallback onUse) {
    if (template['screens_json'] == null) return;
    
    dynamic screensData = template['screens_json'];
    List<WidgetNode> loadedScreens = [];
    if (screensData is List) {
      loadedScreens = screensData.map((e) => WidgetNode.fromJson(e as Map<String, dynamic>)).toList();
    } else if (screensData is Map<String, dynamic>) {
      loadedScreens = [WidgetNode.fromJson(screensData as Map<String, dynamic>)];
    }

    if (loadedScreens.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => TemplatePreviewDialog(
        template: template,
        onUse: onUse,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    dynamic screensData = template['screens_json'];
    List<WidgetNode> loadedScreens = [];
    if (screensData is List) {
      loadedScreens = screensData.map((e) => WidgetNode.fromJson(e as Map<String, dynamic>)).toList();
    } else if (screensData is Map<String, dynamic>) {
      loadedScreens = [WidgetNode.fromJson(screensData as Map<String, dynamic>)];
    }

    final categoryName = template['category'] ?? 'Template';
    final templateName = template['name'] ?? 'Untitled';

    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 1100,
        height: 800,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  '$templateName ($categoryName)',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.5)),
                  ),
                  child: Text(
                    '${loadedScreens.length} HIGH FIDELITY VIEWS',
                    style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 48),
            // Modules List
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: loadedScreens.length,
                separatorBuilder: (context, index) => const SizedBox(width: 24),
                itemBuilder: (context, index) {
                  final screen = loadedScreens[index];
                  final name = screen.properties['pageName'] ?? screen.id ?? 'Module ${index + 1}';
                  return _buildModuleCard(name.toString(), index + 1, screen);
                },
              ),
            ),
            const SizedBox(height: 48),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onUse();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Use Full Template', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(String name, int number, WidgetNode screen) {
    return SizedBox(
      width: 240,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Device/Preview Frame
          Container(
            height: 400,
            width: 240,
            decoration: BoxDecoration(
              color: const Color(0xFF030712),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: TemplateModulePreview(rootNode: screen),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 2,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'MODULE ${number.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            name,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          const Text(
            'Optimized view for high-fidelity app experience',
            style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}
