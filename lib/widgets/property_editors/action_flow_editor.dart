import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/widget_node.dart';
import '../../providers/widget_tree_provider.dart';
import '../../models/supabase_connection_model.dart';

class ActionFlowEditor extends StatefulWidget {
  final WidgetNode node;

  const ActionFlowEditor({super.key, required this.node});

  @override
  State<ActionFlowEditor> createState() => _ActionFlowEditorState();
}

class _ActionFlowEditorState extends State<ActionFlowEditor> {
  late List<Map<String, dynamic>> _actions;

  @override
  void initState() {
    super.initState();
    _loadActions();
  }

  @override
  void didUpdateWidget(covariant ActionFlowEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.node != widget.node) {
      _loadActions();
    }
  }

  void _loadActions() {
    final actionsProp = widget.node.properties['actions'];
    if (actionsProp is List) {
      _actions = List<Map<String, dynamic>>.from(actionsProp.map((e) => Map<String, dynamic>.from(e)));
    } else {
      _actions = [];
    }
  }

  void _saveActions() {
    final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
    if (_actions.isEmpty) {
      widget.node.properties.remove('actions');
    } else {
      widget.node.properties['actions'] = _actions;
    }
    provider.notify();
  }

  void _addNewAction() {
    setState(() {
      _actions.add({
        'type': 'navigate', // default type
      });
    });
    _saveActions();
    _editAction(_actions.length - 1);
  }

  void _deleteAction(int index) {
    setState(() {
      _actions.removeAt(index);
    });
    _saveActions();
  }

  void _editAction(int index) {
    showDialog(
      context: context,
      builder: (context) => ActionConfigDialog(
        action: _actions[index],
        onSave: (updatedAction) {
          setState(() {
            _actions[index] = updatedAction;
          });
          _saveActions();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ReorderableListView.builder(
            itemCount: _actions.length,
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                final item = _actions.removeAt(oldIndex);
                _actions.insert(newIndex, item);
              });
              _saveActions();
            },
            itemBuilder: (context, index) {
              final action = _actions[index];
              return Card(
                key: ValueKey(action.hashCode.toString() + index.toString()),
                color: const Color(0xFF1E293B),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.indigo.shade400,
                    child: Text('${index + 1}', style: const TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                  title: Text(
                    _getActionTitle(action),
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _getActionSubtitle(action),
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16, color: Colors.white70),
                        onPressed: () => _editAction(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 16, color: Colors.redAccent),
                        onPressed: () => _deleteAction(index),
                      ),
                      const Icon(Icons.drag_handle, size: 16, color: Colors.white30),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: _addNewAction,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Action'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigo.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ],
    );
  }

  String _getActionTitle(Map<String, dynamic> action) {
    switch (action['type']) {
      case 'navigate': return 'Navigation';
      case 'supabase_insert': return 'Supabase: Insert Row';
      case 'supabase_update': return 'Supabase: Update Row';
      case 'supabase_delete': return 'Supabase: Delete Row';
      default: return 'Unknown Action';
    }
  }

  String _getActionSubtitle(Map<String, dynamic> action) {
    switch (action['type']) {
      case 'navigate': 
        if (action['targetScreenId'] == '__back__') return 'Go Back (Pop)';
        return 'To: ${action['targetScreenName'] ?? 'Unspecified'}';
      case 'supabase_insert':
      case 'supabase_update':
      case 'supabase_delete':
        return 'Table: ${action['tableName'] ?? 'Unspecified'}';
      default: return '';
    }
  }
}

class ActionConfigDialog extends StatefulWidget {
  final Map<String, dynamic> action;
  final Function(Map<String, dynamic>) onSave;

  const ActionConfigDialog({super.key, required this.action, required this.onSave});

  @override
  State<ActionConfigDialog> createState() => _ActionConfigDialogState();
}

class _ActionConfigDialogState extends State<ActionConfigDialog> {
  late Map<String, dynamic> _currentAction;
  List<SupabaseTable> _availableTables = [];
  List<WidgetNode> _availableScreens = [];

  @override
  void initState() {
    super.initState();
    _currentAction = Map<String, dynamic>.from(widget.action);
    if (_currentAction['payload'] == null) {
      _currentAction['payload'] = <String, dynamic>{};
    }
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
      setState(() {
        _availableScreens = provider.screens;
        if (provider.activeConnection != null) {
          _availableTables = provider.activeConnection!.tables;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Configure Action', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              
              DropdownButtonFormField<String>(
                value: _currentAction['type'],
                dropdownColor: const Color(0xFF0F172A),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  labelText: 'Action Type',
                  labelStyle: TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Color(0xFF0F172A),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'navigate', child: Text('Navigation')),
                  DropdownMenuItem(value: 'supabase_insert', child: Text('Supabase: Insert Row')),
                  DropdownMenuItem(value: 'supabase_update', child: Text('Supabase: Update Row')),
                  DropdownMenuItem(value: 'supabase_delete', child: Text('Supabase: Delete Row')),
                ],
                onChanged: (val) {
                  setState(() {
                    _currentAction['type'] = val;
                  });
                },
              ),
              const SizedBox(height: 20),
              
              _buildTypeSpecificConfig(),
              
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      widget.onSave(_currentAction);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo.shade500),
                    child: const Text('Save Action', style: TextStyle(color: Colors.white)),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  List<WidgetNode> _findInputNodes(WidgetNode root) {
    final nodes = <WidgetNode>[];
    if (root.type == 'TextField' || root.type == 'TextFormField') {
      nodes.add(root);
    }
    for (final child in root.children) {
      nodes.addAll(_findInputNodes(child));
    }
    return nodes;
  }

  Widget _buildTypeSpecificConfig() {
    final type = _currentAction['type'];
    
    if (type == 'navigate') {
      return DropdownButtonFormField<String>(
        value: _currentAction['targetScreenId'],
        dropdownColor: const Color(0xFF0F172A),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: const InputDecoration(
          labelText: 'Target Screen',
          labelStyle: TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Color(0xFF0F172A),
          border: OutlineInputBorder(),
        ),
        items: [
          const DropdownMenuItem<String>(
            value: '__back__',
            child: Text('← Go Back (Pop)', style: TextStyle(color: Colors.orangeAccent)),
          ),
          ..._availableScreens.map((s) => DropdownMenuItem(
            value: s.id,
            child: Text(s.properties['pageName'] ?? s.type),
          )),
        ],
        onChanged: (val) {
          setState(() {
            _currentAction['targetScreenId'] = val;
            if (val == '__back__') {
              _currentAction['targetScreenName'] = 'Back';
            } else {
              _currentAction['targetScreenName'] = _availableScreens.firstWhere((s) => s.id == val).properties['pageName'];
            }
          });
        },
      );
    }
    
    if (type.toString().startsWith('supabase_')) {
      if (_availableTables.isEmpty) {
        return const Text('No Supabase connection active. Please connect to Supabase first in the Data Sources tab.', style: TextStyle(color: Colors.redAccent));
      }
      
      final tableDropdown = DropdownButtonFormField<String>(
        value: _currentAction['tableName'],
        dropdownColor: const Color(0xFF0F172A),
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: const InputDecoration(
          labelText: 'Table Name',
          labelStyle: TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Color(0xFF0F172A),
          border: OutlineInputBorder(),
        ),
        items: _availableTables.map((t) => DropdownMenuItem(
          value: t.name,
          child: Text(t.name),
        )).toList(),
        onChanged: (val) {
          setState(() {
            _currentAction['tableName'] = val;
            _currentAction['payload'] = <String, dynamic>{}; // Reset payload when table changes
          });
        },
      );
      
      if (type == 'supabase_delete') {
         return Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             tableDropdown,
             const SizedBox(height: 16),
             const Text('Note: Delete will act on the active row data passed from a list or query.', style: TextStyle(color: Colors.white54, fontSize: 12)),
           ]
         );
      }
      
      // For Insert / Update, build the dynamic payload editor
      final currentTable = _availableTables.cast<SupabaseTable?>().firstWhere((t) => t?.name == _currentAction['tableName'], orElse: () => null);
      
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tableDropdown,
          const SizedBox(height: 20),
          if (currentTable != null) ...[
            const Text('Set Fields (Payload)', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...currentTable.columns.map((col) {
              if (col.name == 'id' || col.name == 'created_at') return const SizedBox(); // Usually auto-generated
              
              final payloadData = _currentAction['payload'] as Map<String, dynamic>;
              final valueObj = payloadData[col.name] as Map<String, dynamic>? ?? {'type': 'static', 'value': ''};
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(col.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 1,
                          child: DropdownButtonFormField<String>(
                            value: valueObj['type'],
                            dropdownColor: const Color(0xFF1E293B),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'static', child: Text('Static Value')),
                              DropdownMenuItem(value: 'widget_state', child: Text('Widget State')),
                            ],
                            onChanged: (val) {
                              setState(() {
                                payloadData[col.name] = {'type': val, 'value': ''};
                                _currentAction['payload'] = payloadData;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: valueObj['type'] == 'widget_state' ? Builder(
                            builder: (context) {
                              final provider = Provider.of<WidgetTreeProvider>(context, listen: false);
                              final screen = provider.selectedScreen;
                              final inputs = screen != null ? _findInputNodes(screen) : <WidgetNode>[];
                              
                              if (inputs.isEmpty) {
                                return const Text('No inputs on screen', style: TextStyle(color: Colors.white54, fontSize: 12));
                              }
                              
                              // Check if current value exists in inputs, if not default to null
                              final valObjValue = valueObj['value']?.toString();
                              final bool valueExists = inputs.any((n) => n.id == valObjValue);
                              
                              return DropdownButtonFormField<String>(
                                value: valueExists ? valObjValue : null,
                                dropdownColor: const Color(0xFF1E293B),
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  hintText: 'Select Input',
                                  hintStyle: TextStyle(color: Colors.white30),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(),
                                ),
                                items: inputs.map((node) {
                                  final label = node.properties['hintText'] ?? node.properties['labelText'] ?? 'TextField';
                                  return DropdownMenuItem<String>(
                                    value: node.id,
                                    child: Text('$label (${node.id.substring(0, 4)})', overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      payloadData[col.name] = {'type': valueObj['type'], 'value': val};
                                      _currentAction['payload'] = payloadData;
                                    });
                                  }
                                },
                              );
                            }
                          ) : TextField(
                            controller: TextEditingController(text: valueObj['value'].toString()),
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'Enter static value...',
                              hintStyle: const TextStyle(color: Colors.white30),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (val) {
                              payloadData[col.name] = {'type': valueObj['type'], 'value': val};
                              _currentAction['payload'] = payloadData;
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            }).toList(),
          ]
        ],
      );
    }
    
    return const SizedBox();
  }
}
