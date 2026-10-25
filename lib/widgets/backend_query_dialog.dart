import 'package:flutter/material.dart';
import '../ui/editor_theme.dart';
import 'package:provider/provider.dart';
import '../models/backend_query_model.dart';
import '../models/supabase_connection_model.dart';
import '../providers/widget_tree_provider.dart';
import '../services/supabase_data_service.dart';
import 'dart:convert';

class BackendQueryDialog extends StatefulWidget {
  final BackendQuery? queryToEdit;

  const BackendQueryDialog({super.key, this.queryToEdit});

  @override
  State<BackendQueryDialog> createState() => _BackendQueryDialogState();
}

class _BackendQueryDialogState extends State<BackendQueryDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _id;
  late String _name;
  String? _selectedTable;
  List<String> _selectedColumns = [];
  final List<QueryFilter> _filters = [];
  String? _orderBy;
  bool _ascending = true;
  int? _limit;
  bool _enableRealtime = false;
  
  bool _isTesting = false;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    if (widget.queryToEdit != null) {
      final q = widget.queryToEdit!;
      _id = q.id;
      _name = q.name;
      _selectedTable = q.tableName;
      _selectedColumns = q.selectColumns == '*' 
          ? [] 
          : q.selectColumns.split(',').map((c) => c.trim()).toList();
      _filters.addAll(q.filters);
      _orderBy = q.orderBy;
      _ascending = q.ascending;
      _limit = q.limit;
      _enableRealtime = q.enableRealtime;
    } else {
      _id = 'q_${DateTime.now().millisecondsSinceEpoch}';
      _name = '';
      _selectedColumns = [];
      _ascending = true;
      _enableRealtime = true;
    }
  }

  void _addFilter() {
    setState(() {
      _filters.add(QueryFilter(column: '', operator: 'eq', value: ''));
    });
  }

  void _removeFilter(int index) {
    setState(() {
      _filters.removeAt(index);
    });
  }

  Future<void> _testQuery(WidgetTreeProvider provider) async {
    if (_selectedTable == null) return;
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final tempQuery = BackendQuery(
      id: _id,
      name: _name.isEmpty ? 'Test Query' : _name,
      tableName: _selectedTable!,
      filters: _filters.where((f) => f.column.isNotEmpty).toList(),
      selectColumns: _selectedColumns.isEmpty ? '*' : _selectedColumns.join(','),
      orderBy: _orderBy,
      ascending: _ascending,
      limit: _limit,
      enableRealtime: _enableRealtime,
    );

    try {
      final dataService = SupabaseDataService();
      final results = await dataService.executeQuery(provider.activeConnection!, tempQuery);
      setState(() {
        _testResult = const JsonEncoder.withIndent('  ').convert(results);
      });
    } catch (e) {
      setState(() {
        _testResult = 'Error executing query: $e';
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  void _save(WidgetTreeProvider provider) {
    if (!_formKey.currentState!.validate() || _selectedTable == null) return;
    _formKey.currentState!.save();

    final query = BackendQuery(
      id: _id,
      name: _name,
      tableName: _selectedTable!,
      filters: _filters.where((f) => f.column.isNotEmpty).toList(),
      selectColumns: _selectedColumns.isEmpty ? '*' : _selectedColumns.join(','),
      orderBy: _orderBy,
      ascending: _ascending,
      limit: _limit,
      enableRealtime: _enableRealtime,
    );

    if (widget.queryToEdit != null) {
      provider.updateQuery(query);
    } else {
      provider.addQuery(query);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WidgetTreeProvider>(context);
    final activeConnection = provider.activeConnection;

    if (activeConnection == null) {
      return const AlertDialog(
        backgroundColor: EditorColors.surface,
        title: Text('Error', style: TextStyle(color: Colors.white)),
        content: Text('Please connect a data source before creating a query.', style: TextStyle(color: Colors.white70)),
      );
    }

    final tables = activeConnection.tables;
    final SupabaseTable? currentTableSchema = tables.firstWhere(
      (t) => t.name == _selectedTable,
      orElse: () => SupabaseTable(name: '', columns: []),
    );
    final columns = currentTableSchema?.columns.map((c) => c.name).toList() ?? [];

    return Dialog(
      backgroundColor: EditorColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.queryToEdit != null ? 'Edit Backend Query' : 'Create Backend Query',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
              const Divider(color: Colors.white24, height: 24),
              
              // Body (Split view - Left side form builder, Right side preview/test results)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Form Column
                    Expanded(
                      flex: 3,
                      child: ListView(
                        children: [
                          // Query Name Field
                          TextFormField(
                            initialValue: _name,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Query Name',
                              labelStyle: const TextStyle(color: Colors.white70),
                              hintText: 'e.g. Fetch Active Users',
                              hintStyle: const TextStyle(color: Colors.white30),
                              filled: true,
                              fillColor: EditorColors.surfaceRaised,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Query name is required';
                              }
                              return null;
                            },
                            onSaved: (val) => _name = val!.trim(),
                          ),
                          const SizedBox(height: 16),
                          
                          // Table Selector Dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedTable,
                            dropdownColor: EditorColors.surfaceRaised,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Select Table',
                              labelStyle: const TextStyle(color: Colors.white70),
                              filled: true,
                              fillColor: EditorColors.surfaceRaised,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            items: tables.map((t) {
                              return DropdownMenuItem<String>(
                                value: t.name,
                                child: Text(t.name, style: const TextStyle(color: Colors.white)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedTable = val;
                                _selectedColumns = [];
                                _orderBy = null;
                                _filters.clear();
                              });
                            },
                            validator: (val) => val == null ? 'Table selection is required' : null,
                          ),
                          const SizedBox(height: 16),
                          
                          if (_selectedTable != null) ...[
                            // Column Selector Chips
                            const Text('Select Columns (leave empty for *)', style: TextStyle(color: Colors.white70, fontSize: 13)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: columns.map((colName) {
                                final isSelected = _selectedColumns.contains(colName);
                                return FilterChip(
                                  label: Text(colName),
                                  selected: isSelected,
                                  selectedColor: EditorColors.accent.withOpacity(0.3),
                                  checkmarkColor: EditorColors.accent,
                                  backgroundColor: EditorColors.surfaceRaised,
                                  labelStyle: TextStyle(
                                    color: isSelected ? EditorColors.accent : Colors.white70,
                                    fontSize: 12,
                                  ),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedColumns.add(colName);
                                      } else {
                                        _selectedColumns.remove(colName);
                                      }
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                            
                            // Filters Builder
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Filters (WHERE)', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 14)),
                                TextButton.icon(
                                  icon: const Icon(Icons.add, size: 16, color: EditorColors.accent),
                                  label: const Text('Add Filter', style: TextStyle(color: EditorColors.accent, fontSize: 12)),
                                  onPressed: _addFilter,
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (_filters.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                child: Text('No filters defined. Fetching all rows.', style: TextStyle(color: Colors.white30, fontSize: 12)),
                              )
                            else
                              ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _filters.length,
                                separatorBuilder: (c, i) => const SizedBox(height: 8),
                                itemBuilder: (context, index) {
                                  final filter = _filters[index];
                                  return Row(
                                    children: [
                                      // Column selection
                                      Expanded(
                                        child: DropdownButtonFormField<String>(
                                          value: filter.column.isEmpty ? null : filter.column,
                                          dropdownColor: EditorColors.surfaceRaised,
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            filled: true,
                                            fillColor: EditorColors.surfaceRaised,
                                            border: OutlineInputBorder(borderSide: BorderSide.none),
                                          ),
                                          items: columns.map((c) {
                                            return DropdownMenuItem<String>(
                                              value: c,
                                              child: Text(c, style: const TextStyle(color: Colors.white)),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            setState(() {
                                              _filters[index] = QueryFilter(
                                                column: val ?? '',
                                                operator: filter.operator,
                                                value: filter.value,
                                              );
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      
                                      // Operator selection
                                      SizedBox(
                                        width: 80,
                                        child: DropdownButtonFormField<String>(
                                          value: filter.operator,
                                          dropdownColor: EditorColors.surfaceRaised,
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            filled: true,
                                            fillColor: EditorColors.surfaceRaised,
                                            border: OutlineInputBorder(borderSide: BorderSide.none),
                                          ),
                                          items: ['eq', 'neq', 'gt', 'lt', 'gte', 'lte', 'like', 'ilike', 'is', 'in']
                                              .map((op) => DropdownMenuItem<String>(
                                                    value: op,
                                                    child: Text(op, style: const TextStyle(color: Colors.white)),
                                                  ))
                                              .toList(),
                                          onChanged: (val) {
                                            setState(() {
                                              _filters[index] = QueryFilter(
                                                column: filter.column,
                                                operator: val ?? 'eq',
                                                value: filter.value,
                                              );
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      
                                      // Value input
                                      Expanded(
                                        child: TextFormField(
                                          initialValue: filter.value?.toString(),
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                          decoration: const InputDecoration(
                                            isDense: true,
                                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                            hintText: 'value',
                                            hintStyle: TextStyle(color: Colors.white24),
                                            filled: true,
                                            fillColor: EditorColors.surfaceRaised,
                                            border: OutlineInputBorder(borderSide: BorderSide.none),
                                          ),
                                          onChanged: (val) {
                                            // Handle booleans, numbers, or standard text gracefully
                                            dynamic parsedVal = val;
                                            if (val.toLowerCase() == 'true') parsedVal = true;
                                            else if (val.toLowerCase() == 'false') parsedVal = false;
                                            else if (int.tryParse(val) != null) parsedVal = int.parse(val);
                                            else if (double.tryParse(val) != null) parsedVal = double.parse(val);

                                            _filters[index] = QueryFilter(
                                              column: filter.column,
                                              operator: filter.operator,
                                              value: parsedVal,
                                            );
                                          },
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                        onPressed: () => _removeFilter(index),
                                      )
                                    ],
                                  );
                                },
                              ),
                            const SizedBox(height: 16),

                            // Order By and Limit row
                            Row(
                              children: [
                                // Order By
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _orderBy,
                                    dropdownColor: EditorColors.surfaceRaised,
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                    decoration: InputDecoration(
                                      labelText: 'Order By',
                                      labelStyle: const TextStyle(color: Colors.white70),
                                      filled: true,
                                      fillColor: EditorColors.surfaceRaised,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    items: [
                                      const DropdownMenuItem<String>(
                                        value: null,
                                        child: Text('None', style: TextStyle(color: Colors.white70)),
                                      ),
                                      ...columns.map((c) => DropdownMenuItem<String>(
                                            value: c,
                                            child: Text(c, style: const TextStyle(color: Colors.white)),
                                          )),
                                    ],
                                    onChanged: (val) => setState(() => _orderBy = val),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                
                                // Order Direction
                                if (_orderBy != null) ...[
                                  IconButton(
                                    icon: Icon(
                                      _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                                      color: EditorColors.accent,
                                    ),
                                    tooltip: _ascending ? 'Ascending' : 'Descending',
                                    onPressed: () => setState(() => _ascending = !_ascending),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                
                                // Limit
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _limit?.toString(),
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Colors.white, fontSize: 12),
                                    decoration: InputDecoration(
                                      labelText: 'Limit',
                                      labelStyle: const TextStyle(color: Colors.white70),
                                      hintText: 'Unlimited',
                                      hintStyle: const TextStyle(color: Colors.white24),
                                      filled: true,
                                      fillColor: EditorColors.surfaceRaised,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        _limit = int.tryParse(val);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Realtime Stream Toggle
                            SwitchListTile(
                              title: const Text('Realtime Stream', style: TextStyle(color: Colors.white, fontSize: 14)),
                              subtitle: const Text('Updates widget UI dynamically in real time on database changes.', style: TextStyle(color: Colors.white54, fontSize: 11)),
                              value: _enableRealtime,
                              activeColor: const Color(0xFF10B981),
                              contentPadding: EdgeInsets.zero,
                              onChanged: (val) => setState(() => _enableRealtime = val),
                            ),
                          ],
                        ],
                      ),
                    ),
                    
                    const VerticalDivider(color: Colors.white24, width: 32),
                    
                    // Right Test Column
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Live Test Panel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF10B981),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: _isTesting 
                                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Icon(Icons.play_arrow, size: 16),
                                label: const Text('Run Test', style: TextStyle(fontSize: 12)),
                                onPressed: _selectedTable == null || _isTesting ? null : () => _testQuery(provider),
                              )
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: EditorColors.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white10),
                              ),
                              child: _isTesting
                                  ? const Center(child: CircularProgressIndicator(color: EditorColors.accent))
                                  : _testResult == null
                                      ? const Center(
                                          child: Text(
                                            'Click "Run Test" to fetch live rows from your table.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(color: Colors.white30, fontSize: 12),
                                          ),
                                        )
                                      : SingleChildScrollView(
                                          child: Text(
                                            _testResult!,
                                            style: const TextStyle(
                                              fontFamily: 'Courier',
                                              fontSize: 11,
                                              color: Color(0xFF10B981),
                                            ),
                                          ),
                                        ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const Divider(color: Colors.white24, height: 32),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white30),
                      foregroundColor: Colors.white70,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: EditorColors.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: _selectedTable == null ? null : () => _save(provider),
                    child: const Text('Save Query'),
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
