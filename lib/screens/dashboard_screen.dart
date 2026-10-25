import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'dashboard_widgets.dart';
import '../ui/editor_widgets.dart';
import '../ui/editor_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'login_screen.dart';
import 'builder_screen.dart';
import '../providers/widget_tree_provider.dart';
import 'package:provider/provider.dart';
import 'templates_screen.dart';
import '../widgets/template_preview_dialog.dart';
import 'submissions_screen.dart';

class DashboardScreen extends StatefulWidget {
  /// Shows these projects without signing in (UI preview and screenshots).
  final List<Map<String, dynamic>>? previewProjects;

  const DashboardScreen({super.key, this.previewProjects});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final supabaseClient = supabase.Supabase.instance.client;
  List<Map<String, dynamic>> _projects = [];
  bool _isLoading = true;
  int _selectedIndex = 0; // 0 = Projects, 1 = Templates

  bool _isAdmin = false;

  /// Admins come from the `user_roles` table (supabase/migrations); until it
  /// exists the original e-mail rule applies.
  Future<void> _loadAdminRole() async {
    final email = _user?.email;
    if (email == null) return;
    var admin = email.endsWith('@synappkit.com') || email == 'admin@gmail.com';
    try {
      final row = await supabaseClient.from('user_roles').select('role').eq('email', email).maybeSingle();
      if (row != null) admin = row['role'] == 'admin' || row['role'] == 'reviewer';
    } catch (_) {}
    if (mounted) setState(() => _isAdmin = admin);
  }

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    if (widget.previewProjects != null) {
      setState(() {
        _projects = widget.previewProjects!;
        _isLoading = false;
      });
      return;
    }
    _loadAdminRole();
    final user = _user;
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
          backgroundColor: EditorColors.surface,
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
              fillColor: EditorColors.surfaceRaised,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: EditorColors.accent, width: 2),
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
                backgroundColor: EditorColors.accent,
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
        backgroundColor: EditorColors.surface,
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

  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EditorColors.background,
      body: Row(
        children: [
          _buildSidebar(),
          const VerticalDivider(width: 1),
          Expanded(
            child: _selectedIndex == 0
                ? _buildMainContent()
                : _selectedIndex == 1
                    ? const TemplatesScreen()
                    : const SubmissionsScreen(),
          ),
        ],
      ),
    );
  }

  User? get _user {
    try {
      return FirebaseAuth.instance.currentUser;
    } catch (_) {
      return null;
    }
  }

  Widget _buildSidebar() {
    final user = _user;
    final initial = (user?.displayName ?? user?.email ?? 'G');
    return Container(
      width: 248,
      color: EditorColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
            child: Row(children: [
              Image.asset('assets/images/logo_mark.png', width: 34, height: 34),
              const SizedBox(width: 10),
              const Text('SynappKit', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, letterSpacing: -0.3)),
            ]),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildNavItem(icon: Icons.folder_copy_outlined, label: 'Projects', index: 0),
                _buildNavItem(icon: Icons.storefront_outlined, label: 'Templates', index: 1),
                if (_isAdmin) _buildNavItem(icon: Icons.rate_review_outlined, label: 'Submissions', index: 3),
                const SizedBox(height: 8),
                EditorListTile(
                  icon: Icons.person_outline_rounded,
                  title: 'Account',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: EditorColors.surfaceRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: EditorColors.border),
            ),
            child: Row(children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: EditorColors.accentSoft,
                backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                child: user?.photoURL == null
                    ? Text(initial.isEmpty ? 'G' : initial[0].toUpperCase(), style: const TextStyle(color: EditorColors.accent, fontWeight: FontWeight.w700))
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(user?.displayName ?? 'Guest', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(user?.email ?? 'Not signed in', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11.5, color: EditorColors.textFaint)),
                ]),
              ),
              EditorIconButton(icon: Icons.logout_rounded, tooltip: 'Sign out', size: 17, onPressed: _logout),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    return EditorListTile(icon: icon, title: label, selected: _selectedIndex == index, onTap: () => setState(() => _selectedIndex = index));
  }

  Widget _buildMainContent() {
    final query = _search.trim().toLowerCase();
    final visible = _projects.where((p) => query.isEmpty || '${p['project_name'] ?? ''}'.toLowerCase().contains(query)).toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(36, 32, 36, 40),
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Projects', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
              const SizedBox(height: 4),
              Text(
                _isLoading ? 'Loading…' : '${_projects.length} project${_projects.length == 1 ? '' : 's'} · design, test and export Flutter apps',
                style: const TextStyle(fontSize: 13.5, color: EditorColors.textMuted),
              ),
            ]),
          ),
          SizedBox(
            width: 260,
            child: TextField(
              style: const TextStyle(fontSize: 13),
              decoration: const InputDecoration(hintText: 'Search projects', prefixIcon: Icon(Icons.search_rounded, size: 18)),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(onPressed: _createNewProject, icon: const Icon(Icons.add_rounded, size: 18), label: const Text('New project')),
        ]),
        const SizedBox(height: 26),
        Row(children: [
          Expanded(
            child: DashboardQuickStart(
              icon: Icons.add_box_outlined,
              color: EditorColors.accent,
              title: 'Blank app',
              subtitle: 'Start from an empty page',
              onTap: _createNewProject,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: DashboardQuickStart(
              icon: Icons.dashboard_customize_outlined,
              color: EditorColors.success,
              title: 'From a template',
              subtitle: 'Shops, food delivery, finance…',
              onTap: () => setState(() => _selectedIndex = 1),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: DashboardQuickStart(
              icon: Icons.auto_awesome_rounded,
              color: EditorColors.violet,
              title: 'Generate with AI',
              subtitle: 'Describe it or drop a screenshot',
              onTap: _createNewProject,
            ),
          ),
        ]),
        const SizedBox(height: 32),
        const EditorLabel('Recent projects'),
        const SizedBox(height: 6),
        if (_isLoading)
          const Padding(padding: EdgeInsets.all(48), child: Center(child: CircularProgressIndicator()))
        else if (_projects.isEmpty)
          _buildEmptyState()
        else if (visible.isEmpty)
          const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('No projects match your search.', style: TextStyle(color: EditorColors.textFaint))))
        else
          _buildProjectGrid(visible),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: EditorColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: EditorColors.border),
      ),
      child: EditorEmptyState(
        icon: Icons.rocket_launch_outlined,
        title: 'No projects yet',
        message: 'Create your first app: design pages, add logic and export real Flutter code.',
        action: FilledButton.icon(onPressed: _createNewProject, icon: const Icon(Icons.add_rounded, size: 18), label: const Text('Create first project')),
      ),
    );
  }

  Widget _buildProjectGrid(List<Map<String, dynamic>> projects) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = (constraints.maxWidth / 260).floor().clamp(1, 6);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.15,
          ),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return DashboardProjectCard(
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
      backgroundColor: EditorColors.surface,
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
                fillColor: EditorColors.surfaceRaised,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: EditorColors.accent, width: 2),
                ),
              ),
              onChanged: (value) => setState(() {}), // rebuild to check if can submit
            ),
            const SizedBox(height: 32),
            const Text('Choose a Starting Point', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: EditorColors.accent))
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
                              color: EditorColors.surfaceRaised,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? EditorColors.accent : EditorColors.border,
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
                                      color: EditorColors.surfaceHover,
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(11)),
                                    ),
                                    child: isBlank
                                        ? const Center(child: Icon(Icons.add, size: 40, color: Colors.white54))
                                        : _templates[index - 1]['thumbnail_url'] != null
                                            ? ClipRRect(
                                                borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
                                                child: Image.network(_templates[index - 1]['thumbnail_url'], fit: BoxFit.cover),
                                              )
                                            : const Center(child: Icon(Icons.design_services_rounded, size: 40, color: EditorColors.border)),
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
                                                color: isSelected ? EditorColors.accent : Colors.white,
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
                    backgroundColor: EditorColors.accent,
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: EditorColors.surfaceRaised,
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
