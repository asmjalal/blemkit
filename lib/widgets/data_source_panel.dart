import 'package:flutter/material.dart';
import '../ui/editor_theme.dart';
import 'package:provider/provider.dart';
import '../providers/widget_tree_provider.dart';
import '../models/backend_query_model.dart';
import 'backend_query_dialog.dart';
import '../screens/app_settings_screen.dart';
import 'dart:convert';
import '../services/supabase_data_service.dart';

class DataSourcePanel extends StatefulWidget {
  const DataSourcePanel({super.key});

  @override
  State<DataSourcePanel> createState() => _DataSourcePanelState();
}

class _DataSourcePanelState extends State<DataSourcePanel> {
  final _nameController = TextEditingController(text: 'Primary Supabase');
  final _urlController = TextEditingController();
  final _keyController = TextEditingController();

  String? _connectError;

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  void _connect(WidgetTreeProvider provider) async {
    setState(() {
      _connectError = null;
    });

    final name = _nameController.text.trim();
    final url = _urlController.text.trim();
    final key = _keyController.text.trim();

    if (name.isEmpty || url.isEmpty || key.isEmpty) {
      setState(() {
        _connectError = 'All fields are required.';
      });
      return;
    }

    final success = await provider.connectDataSource(name, url, key);
    if (!success) {
      setState(() {
        _connectError = 'Failed to connect. Please check URL and API Key.';
      });
    }
  }

  void _showTestResult(BuildContext context, BackendQuery query, WidgetTreeProvider provider) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: EditorColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: SupabaseDataService().executeQuery(provider.activeConnection!, query),
          builder: (context, snapshot) {
            Widget content;
            if (snapshot.connectionState == ConnectionState.waiting) {
              content = const Center(child: CircularProgressIndicator(color: EditorColors.accent));
            } else if (snapshot.hasError) {
              content = Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.redAccent)),
              );
            } else {
              final jsonStr = const JsonEncoder.withIndent('  ').convert(snapshot.data);
              content = Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Text(
                    jsonStr,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 12,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Query Results: ${query.name}',
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const Divider(color: Colors.white24),
                  Expanded(child: content),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WidgetTreeProvider>(
      builder: (context, provider, child) {
        final conn = provider.activeConnection;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Title
            const Text(
              'Data Sources',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Connect widgets to live collections in your custom Supabase project.',
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 20),

            if (conn == null) ...[
              // Connection Config Setup Card
              _buildSectionHeader('Connect Supabase Database'),
              const SizedBox(height: 12),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Image.asset(
                      'assets/images/supabase.png',
                      height: 48,
                      errorBuilder: (ctx, err, stack) => const Icon(
                        Icons.storage_outlined,
                        color: EditorColors.accent,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Database Not Connected',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Connect your Supabase project in the App Settings to enable database bindings and queries.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: EditorColors.accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.settings, size: 16),
                      label: const Text(
                        'Open App Settings',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AppSettingsScreen(
                              initialTab: 'supabase',
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ] else ...[
              // Connected State Status Card
              _buildSectionHeader('Active Connection'),
              const SizedBox(height: 8),
              _buildCard(
                borderColor: const Color(0xFF10B981),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.cloud_done, color: Color(0xFF10B981), size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                conn.name,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                conn.projectUrl,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Disconnect DataSource',
                          icon: const Icon(Icons.link_off, color: Colors.redAccent),
                          onPressed: () => provider.disconnectDataSource(),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12, height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${conn.tables.length} tables loaded successfully',
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          icon: provider.isFetchingSchema
                              ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: EditorColors.accent))
                              : const Icon(Icons.refresh, size: 14, color: EditorColors.accent),
                          label: const Text('Reload Schema', style: TextStyle(color: EditorColors.accent, fontSize: 11)),
                          onPressed: provider.isFetchingSchema ? null : () => provider.fetchActiveSchema(),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Query Builder Section
              Row(
                children: [
                  Expanded(
                    child: _buildSectionHeader('Backend Queries'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: EditorColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      minimumSize: const Size(60, 32),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('Add Query', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => const BackendQueryDialog(),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (provider.queries.isEmpty)
                _buildCard(
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.query_builder, color: Colors.white24, size: 36),
                          SizedBox(height: 8),
                          Text(
                            'No queries defined yet.',
                            style: TextStyle(color: Colors.white30, fontSize: 12),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Click "Add Query" above to start.',
                            style: TextStyle(color: Colors.white24, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.queries.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final query = provider.queries[index];
                    return _buildCard(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Icon(
                            query.enableRealtime ? Icons.sensors : Icons.dns,
                            color: query.enableRealtime ? const Color(0xFF10B981) : EditorColors.accent,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      query.name,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    if (query.enableRealtime) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text('Realtime', style: TextStyle(color: Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.bold)),
                                      )
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'FROM ${query.tableName} SELECT ${query.selectColumns}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'Courier'),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            tooltip: 'Test Query',
                            icon: const Icon(Icons.play_arrow, color: Color(0xFF10B981), size: 18),
                            onPressed: () => _showTestResult(context, query, provider),
                          ),
                          IconButton(
                            tooltip: 'Edit Query',
                            icon: const Icon(Icons.edit, color: Colors.white60, size: 16),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => BackendQueryDialog(queryToEdit: query),
                              );
                            },
                          ),
                          IconButton(
                            tooltip: 'Delete Query',
                            icon: const Icon(Icons.delete, color: Colors.redAccent, size: 16),
                            onPressed: () => provider.removeQuery(query.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),

              // Expandable Database Tables view
              _buildSectionHeader('Database Tables'),
              const SizedBox(height: 8),
              if (conn.tables.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text('No tables found or schema not yet fetched.', style: TextStyle(color: Colors.white30, fontSize: 12)),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: conn.tables.length,
                  separatorBuilder: (c, i) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final table = conn.tables[index];
                    return ExpansionTile(
                      backgroundColor: EditorColors.surfaceRaised,
                      collapsedBackgroundColor: EditorColors.surfaceRaised,
                      iconColor: EditorColors.accent,
                      collapsedIconColor: Colors.white70,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      title: Text(
                        table.name,
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      children: table.columns.map((col) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  if (col.isPrimaryKey) ...[
                                    const Icon(Icons.key, color: Colors.amber, size: 12),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(col.name, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                              Text(
                                col.dataType + (col.isNullable ? '?' : ''),
                                style: const TextStyle(color: Colors.white38, fontSize: 11, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
            ],
            const SizedBox(height: 40),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: EditorColors.accent,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildCard({required Widget child, Color? borderColor, EdgeInsetsGeometry? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: EditorColors.surfaceRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor ?? Colors.white.withOpacity(0.08)),
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
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: EditorColors.background,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          ),
        ),
      ],
    );
  }
}
