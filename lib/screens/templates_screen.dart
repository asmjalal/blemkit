import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:provider/provider.dart';
import '../providers/widget_tree_provider.dart';
import '../models/widget_node.dart';
import '../widgets/template_custom_dialog.dart';
import '../widgets/template_preview_dialog.dart';
import 'builder_screen.dart';

class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  final supabaseClient = supabase.Supabase.instance.client;
  List<Map<String, dynamic>> _allTemplates = [];
  List<Map<String, dynamic>> _filteredTemplates = [];
  Map<String, int> _categoryCounts = {};
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchTemplates();
  }

  Future<void> _fetchTemplates() async {
    try {
      final response = await supabaseClient.from('templates').select().order('created_at', ascending: false);
      
      final templates = List<Map<String, dynamic>>.from(response);
      
      Map<String, int> counts = {'All': templates.length};
      for (var t in templates) {
        String cat = t['category'] ?? 'General';
        counts[cat] = (counts[cat] ?? 0) + 1;
      }

      if (mounted) {
        setState(() {
          _allTemplates = templates;
          _categoryCounts = counts;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (e) {
      debugPrint('Error fetching templates: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredTemplates = _allTemplates.where((t) {
        final matchesSearch = t['name']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
        final matchesCategory = _selectedCategory == 'All' || t['category'] == _selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  Future<void> _useTemplate(Map<String, dynamic> template) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    
    try {
      // 1. Create a new project row in Supabase
      final newProject = await supabaseClient.from('projects').insert({
        'user_id': user.id,
        'project_name': 'Copy of ${template["name"]}',
      }).select().single();

      final projectId = newProject['id'];

      // 2. Fetch the template screens_json (since we fetched it in the grid, we already have it in memory, but let's be safe)
      final templateData = await supabaseClient.from('templates').select('screens_json').eq('id', template['id']).single();
      final screensJson = templateData['screens_json'];

      // 3. Depending on structure, either insert screens directly or load into provider and save.
      // Easiest is to load it into Provider, set project ID, and save.
      final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
      provider.clearState();
      provider.currentProjectId = projectId;
      
      // We parse the screensJson into the provider.
      // If it's a list, load it. If not, maybe it's just one screen.
      if (screensJson is List) {
        // Assume format matches our export/import
        // But for MVP, if the provider has a loadFromJson mechanism:
        // Actually, let's just insert it into the screens table for this project
        for (int i = 0; i < screensJson.length; i++) {
          final screen = screensJson[i];
          await supabaseClient.from('screens').insert({
            'project_id': projectId,
            'screen_name': (screen['properties'] != null ? screen['properties']['pageName'] : null) ?? screen['name'] ?? 'Screen ${i + 1}',
            'screen_json': screen,
            'order_index': i,
          });
        }
      } else {
        // Single screen
        await supabaseClient.from('screens').insert({
            'project_id': projectId,
            'screen_name': 'Home Screen',
            'screen_json': screensJson,
            'order_index': 0,
        });
      }

      // 4. Load the newly created project
      await provider.loadProjectFromSupabase(projectId);

      setState(() => _isLoading = false);

      if (mounted) {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const BuilderScreen()));
      }
    } catch (e) {
      debugPrint('Error using template: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Premium Small Header
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 32, 40, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Templates',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Start your next project from a curated template.',
                    style: TextStyle(fontSize: 13, color: Colors.white54),
                  ),
                ],
              ),
              // Search Bar
              Container(
                width: 240,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF1E3A6E)),
                ),
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  onChanged: (val) {
                    _searchQuery = val;
                    _applyFilters();
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search templates...',
                    hintStyle: TextStyle(color: Colors.white54, fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: Colors.white54, size: 16),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(bottom: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Category Chips
        if (_categoryCounts.isNotEmpty)
          SizedBox(
            height: 36,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              scrollDirection: Axis.horizontal,
              itemCount: _categoryCounts.keys.length,
              separatorBuilder: (c, i) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                String cat = _categoryCounts.keys.elementAt(index);
                int count = _categoryCounts[cat]!;
                bool isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategory = cat);
                    _applyFilters();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF38BDF8).withOpacity(0.15) : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF1E3A6E),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          cat,
                          style: TextStyle(
                            color: isSelected ? const Color(0xFF38BDF8) : Colors.white70,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white54,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        
        const SizedBox(height: 24),
        
        // Template Grid
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
              : _filteredTemplates.isEmpty
                  ? const Center(child: Text("No templates found.", style: TextStyle(color: Colors.white54)))
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 2;
                        if (constraints.maxWidth >= 1024) crossAxisCount = 5;
                        else if (constraints.maxWidth >= 768) crossAxisCount = 4;
                        else if (constraints.maxWidth >= 500) crossAxisCount = 3;

                        return GridView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.85,
                          ),
                          itemCount: _filteredTemplates.length,
                          itemBuilder: (context, index) {
                            return _TemplateCard(
                              template: _filteredTemplates[index],
                              onUse: () => _useTemplate(_filteredTemplates[index]),
                            );
                          },
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _TemplateCard extends StatefulWidget {
  final Map<String, dynamic> template;
  final VoidCallback onUse;

  const _TemplateCard({required this.template, required this.onUse});

  @override
  State<_TemplateCard> createState() => _TemplateCardState();
}

class _TemplateCardState extends State<_TemplateCard> {
  bool _isHovered = false;

  void _showPreview(BuildContext context) {
    TemplatePreviewDialog.show(context, widget.template, widget.onUse);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _isHovered ? const Color(0xFF38BDF8).withOpacity(0.5) : const Color(0xFF1E3A6E),
            width: 1,
          ),
          boxShadow: [
            if (_isHovered) BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 6))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                ),
                child: widget.template['thumbnail_url'] != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                        child: Image.network(widget.template['thumbnail_url'], fit: BoxFit.cover),
                      )
                    :  Center(
                        child: Image.asset("assets/images/favicon.png"),
                      ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.template['name'] ?? 'Template',
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.template['category'] ?? 'General',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: widget.onUse,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isHovered ? const Color(0xFF38BDF8) : const Color(0xFF0F172A),
                              foregroundColor: _isHovered ? Colors.black : const Color(0xFF38BDF8),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              side: BorderSide(color: _isHovered ? Colors.transparent : const Color(0xFF1E3A6E)),
                            ),
                            child: const Text('Use Template', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        height: 32,
                        width: 32,
                        child: OutlinedButton(
                          onPressed: () => _showPreview(context),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            foregroundColor: Colors.white70,
                            side: const BorderSide(color: Color(0xFF1E3A6E)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          child: const Icon(Icons.remove_red_eye_outlined, size: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
