import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../providers/widget_tree_provider.dart';
import '../models/supabase_connection_model.dart';
import '../services/supabase_data_service.dart';

class AppSettingsScreen extends StatefulWidget {
  final String? initialTab;

  const AppSettingsScreen({super.key, this.initialTab});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  late String _activeSection; // 'general', 'firebase', 'supabase'
  int _oauthState = 0; // 0: unconnected, 2: project_select, 3: connected
  
  // Supabase Management API State (kept for fallback)
  final _patController = TextEditingController();
  String? _patError;
  bool _isLoadingProjects = false;

  // OAuth state
  bool _isOAuthSignedIn = false;
  Session? _supabaseSession;
  final _projectUrlController = TextEditingController();
  final _anonKeyController = TextEditingController();
  String? _oauthError;
  
  List<Map<String, dynamic>> _organizations = [];
  List<Map<String, dynamic>> _projects = [];
  String _selectedOrgId = '';
  String _selectedOrgName = '';
  
  bool _isConnectingReal = false;
  bool _isFetchingSchema = false;

  // Controllers for Self-Hosted Connection
  final _selfHostNameController = TextEditingController(text: 'My Database');
  final _selfHostUrlController = TextEditingController();
  final _selfHostKeyController = TextEditingController();
  String? _selfHostError;

  // Controllers for General Settings
  late TextEditingController _projectNameController;
  late TextEditingController _bundleIdController;
  late TextEditingController _versionController;
  late TextEditingController _buildNumberController;
  late List<String> _selectedPlatforms;

  @override
  void initState() {
    super.initState();
    _activeSection = widget.initialTab ?? 'general';

    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    
    // Sync connection state with provider
    if (provider.activeConnection != null) {
      _oauthState = 3; // connected state
    }

    final pSettings = provider.projectSettings;
    _projectNameController = TextEditingController(text: pSettings['projectName'] ?? 'Synappkit Project');
    _bundleIdController = TextEditingController(text: pSettings['bundleId'] ?? 'com.example.synappkit');
    _versionController = TextEditingController(text: pSettings['version'] ?? '1.0.0');
    _buildNumberController = TextEditingController(text: pSettings['buildNumber'] ?? '1');
    _selectedPlatforms = List<String>.from(pSettings['platforms'] ?? ['android', 'ios', 'web']);

    // Load saved PAT from local storage if available
    if (kIsWeb) {
      final savedPat = html.window.localStorage['supabase_pat'];
      if (savedPat != null && savedPat.isNotEmpty) {
        _patController.text = savedPat;
      }
      final savedToken = html.window.localStorage['supabase_oauth_token'];
      if (savedToken != null && savedToken.isNotEmpty) {
        _isOAuthSignedIn = true;
        // Session reconstruction is not needed for UI; we just know token exists.
      }
    }
  }

  @override
  void dispose() {
    _patController.dispose();
    _selfHostNameController.dispose();
    _selfHostUrlController.dispose();
    _selfHostKeyController.dispose();
    _projectNameController.dispose();
    _bundleIdController.dispose();
    _versionController.dispose();
    _buildNumberController.dispose();
    super.dispose();
  }

  void _saveGeneralSettings() {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    provider.updateProjectSettings({
      'projectName': _projectNameController.text.trim(),
      'bundleId': _bundleIdController.text.trim(),
      'version': _versionController.text.trim(),
      'buildNumber': _buildNumberController.text.trim(),
      'platforms': _selectedPlatforms,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('General settings saved successfully.'),
        backgroundColor: Colors.indigoAccent,
      ),
    );
  }

  // Calls Supabase Management API to fetch Organizations and Projects
  Future<void> _fetchOrgsAndProjects() async {
    final pat = _patController.text.trim();
    if (pat.isEmpty) {
      setState(() {
        _patError = 'Personal Access Token is required.';
      });
      return;
    }

    setState(() {
      _isLoadingProjects = true;
      _patError = null;
    });

    try {
      // 1. Fetch Organizations
      final orgsResponse = await http.get(
        Uri.parse('https://api.supabase.com/v1/organizations'),
        headers: {
          'Authorization': 'Bearer $pat',
          'Content-Type': 'application/json',
        },
      );

      if (orgsResponse.statusCode != 200) {
        throw Exception('Failed to load organizations (HTTP ${orgsResponse.statusCode})');
      }

      final List<dynamic> orgsJson = jsonDecode(orgsResponse.body);
      final fetchedOrgs = orgsJson.map((e) => e as Map<String, dynamic>).toList();

      if (fetchedOrgs.isEmpty) {
        throw Exception('No organizations found for this token.');
      }

      // 2. Fetch Projects
      final projsResponse = await http.get(
        Uri.parse('https://api.supabase.com/v1/projects'),
        headers: {
          'Authorization': 'Bearer $pat',
          'Content-Type': 'application/json',
        },
      );

      if (projsResponse.statusCode != 200) {
        throw Exception('Failed to load projects (HTTP ${projsResponse.statusCode})');
      }

      final List<dynamic> projsJson = jsonDecode(projsResponse.body);
      final fetchedProjs = projsJson.map((e) => e as Map<String, dynamic>).toList();

      // Save token locally
      if (kIsWeb) {
        html.window.localStorage['supabase_pat'] = pat;
      }

      setState(() {
        _organizations = fetchedOrgs;
        _projects = fetchedProjs;
        _selectedOrgId = fetchedOrgs.first['id'] ?? '';
        _selectedOrgName = fetchedOrgs.first['name'] ?? '';
        _oauthState = 2; // Show Project Selector
        _isLoadingProjects = false;
      });

    } catch (e) {
      setState(() {
        _patError = e.toString().replaceFirst('Exception: ', '');
        _isLoadingProjects = false;
      });
    }
  }

  // Connects to a selected project by fetching its API keys dynamically
  Future<void> _connectDynamicProject(WidgetTreeProvider provider, String projectUrl, String anonKey) async {
    setState(() {
      _isConnectingReal = true;
    });
    try {
      // Directly use the supplied project URL and anon key to connect
      final success = await provider.connectDataSource(
        'OAuth Project',
        projectUrl,
        anonKey,
        serviceRoleKey: null,
      );
      if (success) {
        setState(() {
          _oauthState = 3; // connected dashboard
        });
      } else {
        throw Exception('Failed to connect to Supabase client.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connection failed: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        _isConnectingReal = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final conn = provider.activeConnection;

    // Keep state machine synced in case connection was disconnected externally
    if (conn == null && _oauthState == 3) {
      _oauthState = 0;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'App Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        centerTitle: false,
        actions: [
          if (_activeSection == 'general')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: _saveGeneralSettings,
                icon: const Icon(Icons.save_outlined, size: 16),
                label: const Text('Save Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF38BDF8),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          // Left Sidebar Navigation
          Container(
            width: 260,
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: Colors.white10)),
            ),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _buildSidebarSectionHeader('GENERAL'),
                _buildSidebarItem(
                  id: 'general',
                  label: 'General Settings',
                  icon: Icons.settings_outlined,
                ),
                const SizedBox(height: 16),
                _buildSidebarSectionHeader('INTEGRATION'),
                _buildSidebarItem(
                  id: 'firebase',
                  label: 'Firebase',
                  icon: Icons.cloud_done_outlined,
                ),
                _buildSidebarItem(
                  id: 'supabase',
                  label: 'Supabase',
                  iconPath: 'images/supabase.png',
                ),
              ],
            ),
          ),
          
          // Right Content Area
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: MediaQuery.sizeOf(context).height * .85,
                width: MediaQuery.sizeOf(context).width * .5,
                color: const Color(0xFF0B0F19),
                padding: const EdgeInsets.all(40),
                child: _buildActivePanel(provider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white30,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required String id,
    required String label,
    IconData? icon,
    String? iconPath,
  }) {
    final isSelected = _activeSection == id;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () {
          setState(() {
            _activeSection = id;
          });
        },
        leading: iconPath != null
            ? Image.asset(
                iconPath,
                width: 18,
                height: 18,
                errorBuilder: (ctx, err, stack) => const Icon(
                  Icons.storage_outlined,
                  color: Colors.white54,
                  size: 18,
                ),
              )
            : Icon(
                icon,
                color: isSelected ? const Color(0xFF38BDF8) : Colors.white54,
                size: 18,
              ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildActivePanel(WidgetTreeProvider provider) {
    switch (_activeSection) {
      case 'general':
        return _buildGeneralPanel();
      case 'firebase':
        return _buildFirebasePanel();
      case 'supabase':
        return _buildSupabasePanel(provider);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildGeneralPanel() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'General Settings',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Configure project properties and target deployment environments.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 32),
          
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('App Information', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Project Name',
                        controller: _projectNameController,
                        hint: 'e.g. todoapp',
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildTextField(
                        label: 'Bundle Identifier / Package Name',
                        controller: _bundleIdController,
                        hint: 'com.example.app',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        label: 'Version',
                        controller: _versionController,
                        hint: '1.0.0',
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: _buildTextField(
                        label: 'Build Number',
                        controller: _buildNumberController,
                        hint: '1',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Target Platforms', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text(
                  'Select the native platforms this project will target when exporting code.',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  children: [
                    _buildPlatformChip('web', 'Web', Icons.language),
                    _buildPlatformChip('android', 'Android', Icons.android),
                    _buildPlatformChip('ios', 'iOS', Icons.phone_iphone),
                    _buildPlatformChip('macos', 'macOS', Icons.laptop_mac),
                    _buildPlatformChip('windows', 'Windows', Icons.laptop_windows),
                    _buildPlatformChip('linux', 'Linux', Icons.terminal),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformChip(String platformId, String label, IconData icon) {
    final isSelected = _selectedPlatforms.contains(platformId);

    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedPlatforms.remove(platformId);
          } else {
            _selectedPlatforms.add(platformId);
          }
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF38BDF8).withOpacity(0.15) : const Color(0xFF1E293B),
          border: Border.all(
            color: isSelected ? const Color(0xFF38BDF8) : Colors.white10,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? const Color(0xFF38BDF8) : Colors.white54,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirebasePanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Firebase Integration',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Manage your connection to Firebase services and configure platform credentials.',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        const SizedBox(height: 32),
        
        _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.local_fire_department, color: Colors.amber, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Firebase Credentials Status',
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Local platform configuration detected from default_firebase_options.',
                          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Configured',
                      style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white10, height: 32),
              const Text(
                'To change Firebase projects, run flutterfire configure locally in your command-line interface to update configuration options.',
                style: TextStyle(color: Colors.white38, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupabasePanel(WidgetTreeProvider provider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Doc Links header block
          Row(
            children: [
              Image.asset(
                'images/supabase.png',
                height: 28,
                errorBuilder: (ctx, err, stack) => const Icon(
                  Icons.storage,
                  color: Color(0xFF3ECF8E),
                  size: 28,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'supabase',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Connect to your Supabase project and fetch your database schemas.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 32),

          // Collapsible Supabase Connection card
          _buildCollapsibleConnectionCard(provider),
        ],
      ),
    );
  }

  Widget _buildCollapsibleConnectionCard(WidgetTreeProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: true,
          iconColor: Colors.white54,
          collapsedIconColor: Colors.white54,
          title: Row(
            children: const [
              Icon(Icons.settings_input_component_outlined, color: Colors.white70, size: 20),
              SizedBox(width: 12),
              Text(
                'Supabase Connection',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          children: [
            const Divider(color: Colors.white10, height: 1),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: DefaultTabController(
                length: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tabs Header
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TabBar(
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.white54,
                        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        tabs: const [
                          Tab(text: 'Connect with Supabase OAuth'),
                          Tab(text: 'Connect Manually (Self-Hosted / Cloud)'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Tabs Content
                    SizedBox(
                      height: 380,
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _buildOAuthFlowView(provider),
                          _buildSelfHostedFlowView(provider),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOAuthFlowView(WidgetTreeProvider provider) {
    if (_isConnectingReal) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF3ECF8E)),
            SizedBox(height: 16),
            Text(
              'Dynamic project connection in progress...',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_isFetchingSchema) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF3ECF8E)),
            SizedBox(height: 16),
            Text(
              'Fetching database schema...',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      );
    }

    switch (_oauthState) {
      case 0:
        return _buildOAuthUnconnected();
      case 3:
        return _buildOAuthConnectedDashboard(provider);
      default:
        return _buildOAuthUnconnected();
    }
  }

Widget _buildOAuthUnconnected() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Supabase Integration',
            style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _fetchOrgsAndProjects,
            icon: const Icon(Icons.cloud, size: 14),
            label: const Text('Connect with PAT', style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3ECF8E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('OAuth flow not implemented yet'), backgroundColor: Colors.orangeAccent),
              );
            },
            icon: const Icon(Icons.login, size: 14),
            label: const Text('Connect via OAuth', style: TextStyle(fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOAuthProjectSelect(WidgetTreeProvider provider) {
    // Filter projects for the selected organization
    final filteredProjects = _projects.where((p) => p['organization_id'] == _selectedOrgId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF3ECF8E), size: 18),
            const SizedBox(width: 8),
            const Text(
              'Connected to Account',
              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _oauthState = 0;
                  _projects.clear();
                  _organizations.clear();
                });
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('Disconnect', style: TextStyle(fontSize: 11)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Select Organization', style: TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedOrgId,
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              iconEnabledColor: Colors.white54,
              isExpanded: true,
              items: _organizations.map((org) {
                return DropdownMenuItem<String>(
                  value: org['id'],
                  child: Text(org['name'] ?? 'Unnamed Organization'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  final matchedOrg = _organizations.firstWhere((element) => element['id'] == val);
                  setState(() {
                    _selectedOrgId = val;
                    _selectedOrgName = matchedOrg['name'] ?? '';
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Select a project to connect to:',
          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        
        // Projects list
        Expanded(
          child: filteredProjects.isEmpty
              ? const Center(
                  child: Text(
                    'No projects found in this organization.',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredProjects.length,
                  itemBuilder: (context, idx) {
                    final proj = filteredProjects[idx];
                    final ref = proj['id'] ?? '';
                    final name = proj['name'] ?? 'Unnamed Project';
                    final region = proj['region'] ?? 'Unknown Region';
                    final status = proj['status'] ?? 'UNKNOWN';
                    final isHealthy = status == 'ACTIVE_HEALTHY' || status == 'ACTIVE';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildProjectSelectionCard(
                        name: name,
                        region: '$region • ${isHealthy ? "Healthy" : status}',
                        isHealthy: isHealthy,
                        onTap: () => _connectDynamicProject(provider, ref, name),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Create New Project', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3ECF8E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _fetchOrgsAndProjects,
              icon: const Icon(Icons.refresh, size: 14),
              label: const Text('Refresh', style: TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white70,
                side: const BorderSide(color: Colors.white24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProjectSelectionCard({
    required String name,
    required String region,
    required bool isHealthy,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.dns_outlined, color: Colors.white54, size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(region, style: const TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.open_in_new, color: Colors.white24, size: 14),
            const SizedBox(width: 12),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isHealthy ? const Color(0xFF3ECF8E) : Colors.amber,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOAuthConnectedDashboard(WidgetTreeProvider provider) {
    final conn = provider.activeConnection;
    final name = conn?.name ?? 'Project';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF3ECF8E).withOpacity(0.2)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF3ECF8E), size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Connected to $name',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Organization: $_selectedOrgName',
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.open_in_new, color: Colors.white30, size: 16),
                onPressed: () {},
                tooltip: 'Open in Supabase Dashboard',
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _oauthState = 2; // switch back to selection
                  });
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('Switch Project', style: TextStyle(fontSize: 11)),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  provider.disconnectDataSource();
                  setState(() {
                    _oauthState = 0; // return to unconnected state
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                child: const Text('Disconnect', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Schema Definitions',
          style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Fetch your database tables and columns to populate widget builders on the design canvas.',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 24),
        Center(
          child: Column(
            children: [
              ElevatedButton.icon(
                onPressed: () => _fetchSchema(provider),
                icon: const Icon(Icons.cloud_download, size: 16),
                label: const Text('Get Schema', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3ECF8E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              if (conn != null && conn.tables.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  '${conn.tables.length} tables loaded successfully.',
                  style: const TextStyle(color: Color(0xFF3ECF8E), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _fetchSchema(WidgetTreeProvider provider) async {
    setState(() {
      _isFetchingSchema = true;
    });

    try {
      await provider.fetchActiveSchema();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database schema loaded successfully.'),
            backgroundColor: Color(0xFF3ECF8E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading schema: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      setState(() {
        _isFetchingSchema = false;
      });
    }
  }

  Widget _buildSelfHostedFlowView(WidgetTreeProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          label: 'Connection Name',
          controller: _selfHostNameController,
          hint: 'e.g. My Database',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Supabase URL',
          controller: _selfHostUrlController,
          hint: 'https://xxxxxx.supabase.co',
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Supabase service_role Key (or Anon Key)',
          controller: _selfHostKeyController,
          hint: 'your-service-role-key',
          isPassword: true,
        ),
        const SizedBox(height: 6),
        Text(
          'Note: If your database OpenAPI schema is restricted (HTTP 401), you must use your service_role key here so the design editor can fetch your database tables.',
          style: TextStyle(color: Colors.white.withOpacity(0.35), fontSize: 10, height: 1.3),
        ),
        if (_selfHostError != null) ...[
          const SizedBox(height: 12),
          Text(
            _selfHostError!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 11),
          ),
        ],
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0FADD5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: provider.isConnecting ? null : () => _connectSelfHosted(provider),
            child: provider.isConnecting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Connect Supabase', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  void _connectSelfHosted(WidgetTreeProvider provider) async {
    setState(() {
      _selfHostError = null;
    });

    final name = _selfHostNameController.text.trim();
    final url = _selfHostUrlController.text.trim();
    final key = _selfHostKeyController.text.trim();

    if (name.isEmpty || url.isEmpty || key.isEmpty) {
      setState(() {
        _selfHostError = 'All fields are required.';
      });
      return;
    }

    final success = await provider.connectDataSource(name, url, key);
    if (!success) {
      setState(() {
        _selfHostError = 'Failed to connect. Check URL and Anon Key.';
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connected to Self-Hosted Supabase successfully.'),
          backgroundColor: Color(0xFF0FADD5),
        ),
      );
    }
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: child,
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: const Color(0xFF0F172A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}
