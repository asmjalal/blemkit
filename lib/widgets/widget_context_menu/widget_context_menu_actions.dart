import 'package:flutter/material.dart';
import '../../models/widget_node.dart';
import '../../providers/widget_tree_provider.dart';
import '../widget_tree/widget_tree_editor.dart';

abstract class WidgetContextMenuAction {
  void execute();
  void undo();
}

class DuplicateWidgetAction extends WidgetContextMenuAction {
  final WidgetNode node;
  final WidgetTreeProvider provider;
  final WidgetNode root;
  WidgetNode? _parent;
  int? _insertIndex;
  WidgetNode? _duplicate;

  DuplicateWidgetAction({required this.node, required this.provider, required this.root});

  @override
  void execute() {
    _parent = _findParent(root, node);
    if (_parent == null) return;
    _insertIndex = _parent!.children.indexOf(node) + 1;
    _duplicate = node.copy();
    _autoIncrementName(_duplicate!);
    _parent!.children.insert(_insertIndex!, _duplicate!);
    provider.notifyListeners();
  }

  @override
  void undo() {
    if (_parent != null && _duplicate != null) {
      _parent!.children.remove(_duplicate);
      provider.notifyListeners();
    }
  }

  WidgetNode? _findParent(WidgetNode? root, WidgetNode child) {
    if (root == null) return null;
    if (root.children.contains(child)) return root;
    for (final c in root.children) {
      final found = _findParent(c, child);
      if (found != null) return found;
    }
    return null;
  }

  void _autoIncrementName(WidgetNode node) {
    if (node.properties.containsKey('text')) {
      final text = node.properties['text'] as String;
      final regex = RegExp(r'(.+?)( Copy)?( \d+)?');
      final match = regex.firstMatch(text);
      if (match != null) {
        String base = match.group(1) ?? text;
        int copyNum = 1;
        if (text.contains('Copy')) {
          final numMatch = RegExp(r'Copy( \d+)?').firstMatch(text);
          if (numMatch != null && numMatch.group(1) != null) {
            copyNum = int.tryParse(numMatch.group(1)!.trim()) ?? 1;
            copyNum++;
          }
        }
        node.properties['text'] = '$base Copy${copyNum > 1 ? ' $copyNum' : ''}';
      } else {
        node.properties['text'] = '$text Copy';
      }
    }
  }
}

class DeleteWidgetAction extends WidgetContextMenuAction {
  final WidgetNode node;
  final WidgetTreeProvider provider;
  final WidgetNode root;
  WidgetNode? _parent;
  int? _index;

  DeleteWidgetAction({required this.node, required this.provider, required this.root});

  @override
  void execute() {
    _parent = _findParent(root, node);
    if (_parent == null) return;
    _index = _parent!.children.indexOf(node);
    if (_index != -1) {
      _parent!.children.removeAt(_index!);
      provider.notifyListeners();
    }
  }

  @override
  void undo() {
    if (_parent != null && _index != null) {
      _parent!.children.insert(_index!, node);
      provider.notifyListeners();
    }
  }

  WidgetNode? _findParent(WidgetNode? root, WidgetNode child) {
    if (root == null) return null;
    if (root.children.contains(child)) return root;
    for (final c in root.children) {
      final found = _findParent(c, child);
      if (found != null) return found;
    }
    return null;
  }
}

class WrapWidgetAction extends WidgetContextMenuAction {
  final WidgetNode node;
  final WidgetTreeProvider provider;
  final WidgetNode root;
  final String wrapperType;
  WidgetNode? _parent;
  int? _index;
  WidgetNode? _wrapper;

  WrapWidgetAction({
    required this.node,
    required this.provider,
    required this.root,
    required this.wrapperType,
  });

  @override
  void execute() {
    _parent = _findParent(root, node);
    if (_parent == null) return;
    _index = _parent!.children.indexOf(node);
    _wrapper = WidgetTreeEditor.createWidgetNodeWithDefaults(wrapperType);
    _wrapper!.children.add(node);
    _parent!.children[_index!] = _wrapper!;
    provider.notifyListeners();
  }

  @override
  void undo() {
    if (_parent != null && _index != null && _wrapper != null) {
      _parent!.children[_index!] = node;
      provider.notifyListeners();
    }
  }

  WidgetNode? _findParent(WidgetNode? root, WidgetNode child) {
    if (root == null) return null;
    if (root.children.contains(child)) return root;
    for (final c in root.children) {
      final found = _findParent(c, child);
      if (found != null) return found;
    }
    return null;
  }
}

// Add more actions: WrapWidgetAction, RemoveWidgetAction, UndoAction, RedoAction, etc. 