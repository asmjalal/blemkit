import 'package:flutter/material.dart';

class SubmitMarketplaceDialog extends StatefulWidget {
  const SubmitMarketplaceDialog({super.key});

  @override
  State<SubmitMarketplaceDialog> createState() => _SubmitMarketplaceDialogState();
}

class _SubmitMarketplaceDialogState extends State<SubmitMarketplaceDialog> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  String _selectedCategory = 'E-Commerce & Retail';
  bool _isPremium = false;
  String _thumbnailUrl = '';

  final List<String> _categories = [
    'E-Commerce & Retail',
    'Food & Grocery Delivery',
    'Banking & Finance',
    'Social Media & Chat',
    'Healthcare & Fitness',
    'Education & Learning',
    'Travel & Transport',
    'Productivity & Tasks',
    'Real Estate & Property',
    'Entertainment & Music',
    'News & Blogs',
    'Events & Booking',
    'Smart Home & IoT',
    'Utilities & Tools',
    'Business & CRM',
  ];

  final List<String> _presets = [
    'https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=600', // Business/CRM
    'https://images.unsplash.com/photo-1472851294608-062f824d29cc?w=600', // E-commerce
    'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=600', // Finance
    'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600', // Education
    'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=600', // News/Blogs
    'https://images.unsplash.com/photo-1542751371-adc38448a05e?w=600', // Social/Chat
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 600,
        padding: const EdgeInsets.all(28),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Submit to Marketplace',
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Submit your template design for community review. Once approved, it will be published to the public catalog.',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 24),
              
              // Inputs Wrapper
              Theme(
                data: ThemeData.dark().copyWith(
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 1.5)),
                  ),
                ),
                child: Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Template Name',
                            labelStyle: TextStyle(color: Colors.white70),
                            hintText: 'e.g. Premium Shop App',
                          ),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a template name' : null,
                          onSaved: (value) => _name = value ?? '',
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          maxLines: 3,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Template Description',
                            labelStyle: TextStyle(color: Colors.white70),
                            hintText: 'Describe the pages, features, and target audience.',
                          ),
                          validator: (value) => value == null || value.trim().isEmpty ? 'Please enter a description' : null,
                          onSaved: (value) => _description = value ?? '',
                        ),
                        const SizedBox(height: 16),
                        
                        // Category Dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            labelStyle: TextStyle(color: Colors.white70),
                          ),
                          style: const TextStyle(color: Colors.white),
                          dropdownColor: const Color(0xFF1E293B),
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (value) {
                            if (value != null) setState(() => _selectedCategory = value);
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        TextFormField(
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            labelText: 'Thumbnail Image URL',
                            labelStyle: TextStyle(color: Colors.white70),
                          ),
                          onSaved: (value) => _thumbnailUrl = value ?? '',
                          controller: TextEditingController(text: _thumbnailUrl),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Preset covers:',
                          style: TextStyle(color: Colors.white38, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 48,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _presets.length,
                            itemBuilder: (context, idx) => GestureDetector(
                              onTap: () => setState(() => _thumbnailUrl = _presets[idx]),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                width: 72,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: _thumbnailUrl == _presets[idx] ? const Color(0xFF38BDF8) : Colors.transparent,
                                    width: 2,
                                  ),
                                  image: DecorationImage(image: NetworkImage(_presets[idx]), fit: BoxFit.cover),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Premium Checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _isPremium,
                              activeColor: const Color(0xFF38BDF8),
                              onChanged: (value) => setState(() => _isPremium = value ?? false),
                            ),
                            const Text(
                              'Flag as Premium Template',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        _formKey.currentState?.save();
                        Navigator.pop(context, {
                          'name': _name,
                          'description': _description,
                          'category': _selectedCategory,
                          'is_premium': _isPremium,
                          'thumbnail_url': _thumbnailUrl.isEmpty ? _presets[0] : _thumbnailUrl,
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF38BDF8),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    child: const Text('Submit for Review'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
