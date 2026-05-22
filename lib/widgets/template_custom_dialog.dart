import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../templates/templates.dart';
import '../providers/widget_tree_provider.dart';
import '../models/widget_node.dart';
import 'canvas_preview/builders/widget_builder_factory.dart';

class TemplateModulePreview extends StatelessWidget {
  final WidgetNode rootNode;
  const TemplateModulePreview({super.key, required this.rootNode});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: FittedBox(
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 380, // Target layout width
          height: 780, // Target layout height
          child: WidgetBuilderFactory.buildWidget(context, rootNode, null),
        ),
      ),
    );
  }
}

class TemplateCustomDialog extends StatefulWidget {
  const TemplateCustomDialog({super.key});

  @override
  State<TemplateCustomDialog> createState() => _TemplateCustomDialogState();
}

class _TemplateCustomDialogState extends State<TemplateCustomDialog> {
  TemplateCategory? _selectedCategory;
  List<WidgetNode>? _loadedScreens;
  int _screenCount = 0;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (_selectedCategory == null) {
      return _buildCategoryGrid();
    } else {
      return _buildTemplateDetail();
    }
  }

  Future<void> _selectCategory(TemplateMetadata template) async {
    setState(() {
      _isLoading = true;
      _selectedCategory = template.category;
    });

    try {
      final data = await TemplateService.loadTemplate(template.jsonPath);
      if (mounted) {
        setState(() {
          if (data is List<WidgetNode>) {
            _loadedScreens = data;
          } else if (data is WidgetNode) {
            _loadedScreens = [data];
          }
          _screenCount = _loadedScreens?.length ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _selectedCategory = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading template: $e')));
      }
    }
  }

  Widget _buildCategoryGrid() {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 1000,
        height: 750,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Select Template Category',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Choose a blueprint to accelerate your application development process.',
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 48),
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                mainAxisSpacing: 24,
                crossAxisSpacing: 24,
                childAspectRatio: 0.98,
                children: [
                  ...templates.map((t) => _buildCategoryCard(t)),
                  _buildScratchCard(),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Continue to Workspace'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(TemplateMetadata template) {
    final imageUrl = _getCategoryImageUrl(template.category);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _selectCategory(template),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Header
              Expanded(
                flex: 5,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.3),
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF1E293B).withOpacity(0.8),
                          const Color(0xFF1E293B),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Content
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(template.icon, color: const Color(0xFF3B82F6), size: 18),
                          const SizedBox(width: 8),
                          Text(
                            template.name,
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        template.description,
                        style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScratchCard() {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Provider.of<WidgetTreeProvider>(context, listen: false)
              .setRootNode(WidgetNode(type: 'Scaffold', properties: {}, children: []));
          Navigator.of(context).pop();
        },
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: CustomPaint(
            painter: _DashRectPainter(color: Colors.white24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Start from Scratch',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Begin with a clean canvas for your unique vision.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateDetail() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)));
    }

    final categoryTemplates = templates.where((t) => t.category == _selectedCategory).toList();
    final templateMetadata = categoryTemplates.isNotEmpty ? categoryTemplates.first : null;
    final categoryName = templateMetadata?.name.split(' ').first ?? 'Template';

    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 1100,
        height: 800,
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => setState(() {
                    _selectedCategory = null;
                    _loadedScreens = null;
                  }),
                  icon: const Icon(Icons.arrow_back, color: Colors.white54, size: 16),
                  label: const Text('BACK', style: TextStyle(color: Colors.white54, fontSize: 12)),
                ),
                const SizedBox(width: 24),
                Text(
                  '$categoryName Templates',
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.5)),
                  ),
                  child: Text(
                    '$_screenCount HIGH FIDELITY VIEWS',
                    style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 10, fontWeight: FontWeight.bold),
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
              child: _loadedScreens == null || _loadedScreens!.isEmpty
                  ? const Center(child: Text('No screens found in this template', style: TextStyle(color: Colors.white54)))
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _loadedScreens!.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 24),
                      itemBuilder: (context, index) {
                        final screen = _loadedScreens![index];
                        final name = screen.properties['pageName'] ?? screen.id ?? 'Module';
                        return _buildModuleCard(name.toString(), index + 1, _selectedCategory!, screen);
                      },
                    ),
            ),
            const SizedBox(height: 48),
            // Footer
            Row(
              children: [
                // Avatar Group
                SizedBox(
                  width: 100,
                  height: 32,
                  child: Stack(
                    children: [
                      _buildAvatar(0, 'https://i.pravatar.cc/150?u=1'),
                      _buildAvatar(20, 'https://i.pravatar.cc/150?u=2'),
                      _buildAvatar(40, null, label: '+12'),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Text('Active users choosing this pack', style: TextStyle(color: Colors.white54, fontSize: 12)),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('Save as Draft', style: TextStyle(color: Colors.white70)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : () => _handleUseLoadedTemplate(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Use Full Template'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(String name, int number, TemplateCategory category, WidgetNode screen) {
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
          ),
          const SizedBox(height: 8),
          Text(
            _getModuleDescription(name),
            style: const TextStyle(color: Colors.white54, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  void _handleUseLoadedTemplate() {
    if (_loadedScreens == null || _loadedScreens!.isEmpty) return;
    
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    provider.setProject(_loadedScreens!);
    Navigator.of(context).pop();
  }

  Widget _buildAvatar(double left, String? url, {String? label}) {
    return Positioned(
      left: left,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFF0F172A), width: 2),
          image: url != null ? DecorationImage(image: NetworkImage(url), fit: BoxFit.cover) : null,
        ),
        alignment: Alignment.center,
        child: label != null ? Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)) : null,
      ),
    );
  }

  String _getCategoryImageUrl(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.ecommerce: return 'https://images.unsplash.com/photo-1441986300917-64674bd600d8?w=800&q=80';
      case TemplateCategory.productivity: return 'https://images.unsplash.com/photo-1517842645767-c639042777db?w=800&q=80';
      case TemplateCategory.finance: return 'https://images.unsplash.com/photo-1559526324-4b87b5e36e44?w=800&q=80';
      default: return 'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=800&q=80';
    }
  }

  String _getModuleImageUrl(TemplateCategory category, int moduleNumber) {
    // Return different images for modules based on category
    final baseUrl = 'https://picsum.photos/seed/${category.name}$moduleNumber/400/800';
    return baseUrl;
  }

  String _getModuleDescription(String name) {
    switch (name) {
      case 'Storefront': return 'Modern grid with discovery-first UX';
      case 'Product Details': return 'Immersive gallery & sticky actions';
      case 'Shopping Cart': return 'Swipe-to-delete and dynamic totals';
      case 'My Notes': return 'Pastel note grid with quick actions';
      case 'Note Editor': return 'Clean editor interface with rich content layout';
      case 'Wallet Dashboard': return 'Luxury credit card visualizer & transaction history';
      case 'Analytics': return 'Interactive budget overview and breakdown charts';
      case 'Add Expense': return 'Sleek transaction builder and details logger';
      default: return 'Optimized view for high-fidelity app experience';
    }
  }

  Future<void> _handleUseTemplate(TemplateMetadata template) async {
    setState(() => _isLoading = true);
    try {
      final templateData = await TemplateService.loadTemplate(template.jsonPath);
      final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
      
      if (templateData is List<WidgetNode>) {
        provider.setProject(templateData);
      } else if (templateData is WidgetNode) {
        provider.setRootNode(templateData.copy());
      }
      
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _DashRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  _DashRectPainter({this.color = Colors.white, this.strokeWidth = 1.0, this.gap = 5.0});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final double width = size.width;
    final double height = size.height;

    final Path path = Path()
      ..moveTo(12, 0)
      ..lineTo(width - 12, 0)
      ..quadraticBezierTo(width, 0, width, 12)
      ..lineTo(width, height - 12)
      ..quadraticBezierTo(width, height, width - 12, height)
      ..lineTo(12, height)
      ..quadraticBezierTo(0, height, 0, height - 12)
      ..lineTo(0, 12)
      ..quadraticBezierTo(0, 0, 12, 0);

    final List<double> dashes = [gap, gap];
    
    // Simple dash logic for a recursive implementation or use external package
    // for now we draw a simple border or use a loop
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
