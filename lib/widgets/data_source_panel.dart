import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/widget_tree_provider.dart';

class DataSourcePanel extends StatelessWidget {
  const DataSourcePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WidgetTreeProvider>(
      builder: (context, provider, child) {
        final api = provider.apiSettings;

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const Text(
              'Data Sources',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connect your designer to live data from Supabase or any REST API.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('API Configuration'),
            const SizedBox(height: 12),
            _buildTextField(
              label: 'Base URL / Supabase URL',
              value: api['url'] ?? '',
              hint: 'https://prj.supabase.co',
              onChanged: (val) => provider.updateApiSettings({'url': val}),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'API Key / Supabase Anon Key',
              value: api['apiKey'] ?? '',
              hint: 'your-api-key',
              isPassword: true,
              onChanged: (val) => provider.updateApiSettings({'apiKey': val}),
            ),
            const SizedBox(height: 24),
            _buildSectionHeader('Supabase Helpers'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('Connect Supabase'),
                  backgroundColor: const Color(0xFF1E293B),
                  labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                  onPressed: () {
                    // Quick fill for demo or logic to test connection
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Card(
              color: Color(0xFF1E293B),
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF0fadd5), size: 16),
                        SizedBox(width: 8),
                        Text('Data Binding', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Once connected, you can bind widget properties (like Text) to specific fields in your API response using the Properties panel.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Colors.indigo.shade400,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required String hint,
    required ValueChanged<String> onChanged,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: TextEditingController(text: value)..selection = TextSelection.fromPosition(TextPosition(offset: value.length)),
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: const Color(0xFF181A20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
