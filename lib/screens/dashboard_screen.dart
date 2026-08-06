import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'login_screen.dart';
import 'builder_screen.dart';
import '../providers/widget_tree_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'templates_screen.dart';
import '../widgets/template_preview_dialog.dart';
import 'submissions_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final supabaseClient = supabase.Supabase.instance.client;
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = true;
  int _selectedIndex = 0; // 0 = Projects, 1 = Templates

  bool get _isAdmin {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email != null && 
        (user!.email!.endsWith('@synappkit.com') || user.email == 'admin@gmail.com');
  }

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
      return;
    }

    try {
      final response = await supabaseClient
          .from('projects')
          .select()
          .eq('user_id', user.uid)
          .order('updated_at', ascending: false);

      setState(() {
        _projects = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching projects: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _createNewProject() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final CreateProjectResult? result = await showDialog<CreateProjectResult>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CreateProjectDialog(),
    );

    if (result != null && result.name.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        final response = await supabaseClient.from('projects').insert({
          'user_id': user.uid,
          'project_name': result.name,
        }).select().single();

        final projectId = response['id'];
        final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
        provider.clearState();
        provider.currentProjectId = projectId;

        if (result.template != null) {
          // If a template was selected, we need to insert its screens
          final screensJson = result.template!['screens_json'];
          if (screensJson is List) {
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
            await supabaseClient.from('screens').insert({
              'project_id': projectId,
              'screen_name': 'Home Screen',
              'screen_json': screensJson,
              'order_index': 0,
            });
          }
          await provider.loadProjectFromSupabase(projectId);
        }
        
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const BuilderScreen()),
          ).then((_) => _fetchProjects());
        }
      } catch (e) {
        debugPrint('Error creating project: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  void _openProject(String projectId) async {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    setState(() => _isLoading = true);
    
    await provider.loadProjectFromSupabase(projectId);
    
    setState(() => _isLoading = false);
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const BuilderScreen()),
      ).then((_) => _fetchProjects());
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _renameProject(String projectId, String currentName) async {
    final String? newName = await showDialog<String>(
      context: context,
      builder: (context) {
        String name = currentName;
        final controller = TextEditingController(text: currentName);
        return AlertDialog(
          backgroundColor: const Color(0xFF0F172A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Rename Project', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          content: TextField(
            autofocus: true,
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter project name',
              hintStyle: const TextStyle(color: Colors.white54),
              filled: true,
              fillColor: const Color(0xFF1E293B),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 2),
              ),
            ),
            onChanged: (value) => name = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, name),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF38BDF8),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty && newName != currentName) {
      setState(() => _isLoading = true);
      try {
        await supabaseClient
            .from('projects')
            .update({'project_name': newName, 'updated_at': DateTime.now().toIso8601String()})
            .eq('id', projectId);
        _fetchProjects();
      } catch (e) {
        debugPrint('Error renaming project: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  void _deleteProject(String projectId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Project', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        content: const Text(
          'Are you sure you want to delete this project? This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await supabaseClient.from('projects').delete().eq('id', projectId);
        _fetchProjects();
      } catch (e) {
        debugPrint('Error deleting project: $e');
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatTimeAgo(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 0) return '${diff.inDays} days ago';
      if (diff.inHours > 0) return '${diff.inHours} hours ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes} mins ago';
      return 'Just now';
    } catch (e) {
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040D1A), // Dark app background
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: _selectedIndex == 0
                ? _buildMainContent()
                : _selectedIndex == 1
                    ? const TemplatesScreen()
                    : _selectedIndex == 3
                        ? const SubmissionsScreen()
                        : const Center(child: Text('Settings (Coming Soon)', style: TextStyle(color: Colors.white54))),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(right: BorderSide(color: Color(0xFF1E3A6E))),
      ),
      child: Column(
        children: [
          Image.asset('assets/images/logo.png', height: 188, errorBuilder: (c, o, s) => const Icon(Icons.dashboard, size: 48, color: Color(0xFF38BDF8))),

          // Navigation Menu
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildNavItem(icon: Icons.folder_copy_outlined, label: 'Projects', index: 0),
                _buildNavItem(icon: Icons.inventory_2_outlined, label: 'Templates', index: 1),
                if (_isAdmin)
                  _buildNavItem(icon: Icons.rate_review_outlined, label: 'Submissions', index: 3),
                _buildNavItem(icon: Icons.settings_applications_sharp, label: 'Settings', index: 2),
              ],
            ),
          ),

          // Bottom Profile Section
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: const Color(0xFF1E3A6E)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF0B1D3A),
                      backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                      child: user?.photoURL == null ? const Icon(Icons.person, color: Colors.white54) : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'User',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(color: Colors.white54, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Logout'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white54,
                      alignment: Alignment.center,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    bool isActive = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: isActive ? Colors.white : Colors.white54),
        title: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white54,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        tileColor: isActive ? const Color(0xFF38BDF8).withOpacity(0.2) : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: () {
          if (index == 2) return; // Settings not implemented
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }

  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(30, 30, 40, 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'My Projects',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage and continue your app projects',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _createNewProject,
                icon: const Icon(Icons.add, size: 20),
                label:  Text('Create Project', style: TextStyle(
                  color: Colors.black
                ),),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // Pill shape
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        
        // Content Area
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
              : _projects.isEmpty
                  ? _buildEmptyState()
                  : _buildProjectGrid(),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A6E), // Dark blue background
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.dashboard_customize_rounded, size: 80, color: Color(0xFF38BDF8)),
          ),
          const SizedBox(height: 32),
          const Text(
            'No projects yet',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first app and start building.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _createNewProject,
            icon: const Icon(Icons.add),
            label: const Text('Create First Project',style: TextStyle(
                color: Colors.black54
            ),),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF38BDF8),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectGrid() {
    // Determine grid count based on screen width
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = 1;
        if (constraints.maxWidth >= 1024) crossAxisCount = 5;
        else if (constraints.maxWidth >= 768) crossAxisCount = 4;
        else if (constraints.maxWidth >= 500) crossAxisCount = 3;

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 24,
            mainAxisSpacing: 24,
            childAspectRatio: 1.3,
          ),
          itemCount: _projects.length,
          itemBuilder: (context, index) {
            final project = _projects[index];
            return _ProjectCard(
              project: project,
              onOpen: () => _openProject(project['id']),
              onRename: () => _renameProject(project['id'], project['project_name'] ?? 'Untitled Project'),
              onDelete: () => _deleteProject(project['id']),
              formatTimeAgo: _formatTimeAgo,
            );
          },
        );
      },
    );
  }
}

class _ProjectCard extends StatefulWidget {
  final Map<String, dynamic> project;
  final VoidCallback onOpen;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final String Function(String) formatTimeAgo;

  const _ProjectCard({
    required this.project,
    required this.onOpen,
    required this.onRename,
    required this.onDelete,
    required this.formatTimeAgo,
  });

  @override
  State<_ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<_ProjectCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onOpen,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..translate(0.0, _isHovered ? -6.0 : 0.0),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              if (_isHovered)
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 12))
              else
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
            ],
            border: Border.all(
              color: _isHovered ? const Color(0xFF38BDF8).withOpacity(0.5) : const Color(0xFF1E3A6E),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail Area
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0B1D3A), // Dark header/thumbnail bg
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                  child: widget.project['thumbnail'] != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                          child: Image.network(widget.project['thumbnail'], fit: BoxFit.cover),
                        )
                      : Center(
                          child: Image.asset("assets/images/favicon.png"),
                        ),
                ),
              ),
              // Card Details
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            widget.project['project_name'] ?? 'Untitled Project',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white54),
                          color: const Color(0xFF1E293B),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          onSelected: (value) {
                            if (value == 'open') widget.onOpen();
                            if (value == 'rename') widget.onRename();
                            if (value == 'delete') widget.onDelete();
                          },
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem<String>(
                              value: 'open',
                              child: Text('Open', style: TextStyle(color: Colors.white)),
                            ),
                            const PopupMenuItem<String>(
                              value: 'rename',
                              child: Text('Rename', style: TextStyle(color: Colors.white)),
                            ),
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Text('Delete Project', style: TextStyle(color: Colors.redAccent)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Updated ${widget.formatTimeAgo(widget.project['updated_at'] ?? DateTime.now().toIso8601String())}",
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateProjectResult {
  final String name;
  final Map<String, dynamic>? template;
  CreateProjectResult(this.name, this.template);
}

class CreateProjectDialog extends StatefulWidget {
  const CreateProjectDialog({super.key});

  @override
  State<CreateProjectDialog> createState() => _CreateProjectDialogState();
}

class _CreateProjectDialogState extends State<CreateProjectDialog> {
  final _nameController = TextEditingController();
  List<Map<String, dynamic>> _templates = [];
  bool _isLoading = true;
  int _selectedTemplateIndex = -1; // -1 means Blank Project

  @override
  void initState() {
    super.initState();
    _fetchTemplates();
  }

  Future<void> _fetchTemplates() async {
    try {
      final response = await supabase.Supabase.instance.client.from('templates').select().order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _templates = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching templates: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Create New Project', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.white)),
            const SizedBox(height: 24),
            TextField(
              autofocus: true,
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Project Name',
                labelStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 2),
                ),
              ),
              onChanged: (value) => setState(() {}), // rebuild to check if can submit
            ),
            const SizedBox(height: 32),
            const Text('Choose a Starting Point', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF38BDF8)))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: _templates.length + 1,
                      itemBuilder: (context, index) {
                        final isBlank = index == 0;
                        final isSelected = _selectedTemplateIndex == index - 1;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedTemplateIndex = index - 1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF1E3A6E),
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF0B1D3A),
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                                    ),
                                    child: isBlank
                                        ? const Center(child: Icon(Icons.add, size: 40, color: Colors.white54))
                                        : _templates[index - 1]['thumbnail_url'] != null
                                            ? ClipRRect(
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                                                child: Image.network(_templates[index - 1]['thumbnail_url'], fit: BoxFit.cover),
                                              )
                                            : const Center(child: Icon(Icons.design_services_rounded, size: 40, color: Color(0xFF1E3A6E))),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              isBlank ? 'Blank Project' : (_templates[index - 1]['name'] ?? 'Template'),
                                              style: TextStyle(
                                                color: isSelected ? const Color(0xFF38BDF8) : Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (!isBlank)
                                            GestureDetector(
                                              onTap: () {
                                                TemplatePreviewDialog.show(
                                                  context,
                                                  _templates[index - 1],
                                                  () => setState(() => _selectedTemplateIndex = index - 1),
                                                );
                                              },
                                              child: const Padding(
                                                padding: EdgeInsets.only(left: 8.0),
                                                child: Icon(Icons.remove_red_eye_outlined, color: Colors.white54, size: 16),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        isBlank ? 'Start from scratch' : (_templates[index - 1]['category'] ?? 'General'),
                                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
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
                  onPressed: _nameController.text.trim().isEmpty
                      ? null
                      : () {
                          Navigator.pop(
                            context,
                            CreateProjectResult(
                              _nameController.text.trim(),
                              _selectedTemplateIndex == -1 ? null : _templates[_selectedTemplateIndex],
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF38BDF8),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: const Color(0xFF1E293B),
                    disabledForegroundColor: Colors.white54,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Create Project', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
