import '../../models/widget_node.dart';
import '../../providers/widget_tree_provider.dart';
import '../widget_tree/widget_tree_editor.dart';

abstract class WidgetContextMenuAction {
  void execute();
  void undo();
}

class _ParentLocation {
  final WidgetNode parent;
  final int? index;
  final String? propertyKey;
  final int? listIndex;

  _ParentLocation({
    required this.parent,
    this.index,
    this.propertyKey,
    this.listIndex,
  });

  bool get isInChildren => index != null;
  bool get isInProperty => propertyKey != null && listIndex == null;
  bool get isInPropertyList => propertyKey != null && listIndex != null;
}

_ParentLocation? _findParent(WidgetNode current, WidgetNode target) {
  // 1. Check children
  for (int i = 0; i < current.children.length; i++) {
    if (current.children[i].id == target.id) {
      return _ParentLocation(parent: current, index: i);
    }
    final found = _findParent(current.children[i], target);
    if (found != null) return found;
  }

  // 2. Check properties (since property widgets are now WidgetNodes)
  for (final key in current.properties.keys) {
    final val = current.properties[key];
    
    if (val is WidgetNode) {
      if (val.id == target.id) {
        return _ParentLocation(parent: current, propertyKey: key);
      }
      final found = _findParent(val, target);
      if (found != null) return found;
    }
    
    if (val is List) {
      for (int i = 0; i < val.length; i++) {
        final item = val[i];
        if (item is WidgetNode) {
          if (item.id == target.id) {
            return _ParentLocation(parent: current, propertyKey: key, listIndex: i);
          }
          final found = _findParent(item, target);
          if (found != null) return found;
        }
      }
    }
  }

  return null;
}

// ---------------------------------------------------------------------------
// Actions
// ---------------------------------------------------------------------------

class DeleteWidgetAction extends WidgetContextMenuAction {
  final WidgetNode node;
  final WidgetTreeProvider provider;
  final WidgetNode root;

  _ParentLocation? _loc;
  dynamic _removedData;

  DeleteWidgetAction({required this.node, required this.provider, required this.root});

  @override
  void execute() {
    _loc = _findParent(root, node);
    if (_loc == null) return;

    if (_loc!.isInChildren) {
      _removedData = _loc!.parent.children.removeAt(_loc!.index!);
    } else if (_loc!.isInProperty) {
      _removedData = _loc!.parent.properties.remove(_loc!.propertyKey!);
    } else if (_loc!.isInPropertyList) {
      final list = _loc!.parent.properties[_loc!.propertyKey!] as List;
      _removedData = list.removeAt(_loc!.listIndex!);
    }

    if (provider.selectedNode?.id == node.id) {
      provider.selectedNode = null;
    }
    provider.notify();
  }

  @override
  void undo() {
    if (_loc == null) return;
    if (_loc!.isInChildren) {
      _loc!.parent.children.insert(_loc!.index!, _removedData as WidgetNode);
    } else if (_loc!.isInProperty) {
      _loc!.parent.properties[_loc!.propertyKey!] = _removedData;
    } else if (_loc!.isInPropertyList) {
      final list = _loc!.parent.properties[_loc!.propertyKey!] as List;
      list.insert(_loc!.listIndex!, _removedData);
    }
    provider.notify();
  }
}

class DuplicateWidgetAction extends WidgetContextMenuAction {
  final WidgetNode node;
  final WidgetTreeProvider provider;
  final WidgetNode root;

  _ParentLocation? _loc;
  WidgetNode? _duplicate;

  DuplicateWidgetAction({required this.node, required this.provider, required this.root});

  @override
  void execute() {
    _loc = _findParent(root, node);
    if (_loc == null || !_loc!.isInChildren) return;

    _duplicate = node.copy();
    _duplicate!.id = '${node.id}_copy_${DateTime.now().millisecondsSinceEpoch}';
    _loc!.parent.children.insert(_loc!.index! + 1, _duplicate!);
    provider.notify();
  }

  @override
  void undo() {
    if (_loc != null && _duplicate != null) {
      _loc!.parent.children.remove(_duplicate);
      provider.notify();
    }
  }
}

class WrapWidgetAction extends WidgetContextMenuAction {
  final WidgetNode node;
  final WidgetTreeProvider provider;
  final WidgetNode root;
  final String wrapperType;

  _ParentLocation? _loc;
  WidgetNode? _wrapper;

  WrapWidgetAction({
    required this.node,
    required this.provider,
    required this.root,
    required this.wrapperType,
  });

  @override
  void execute() {
    _loc = _findParent(root, node);
    if (_loc == null || !_loc!.isInChildren) return;

    _wrapper = WidgetTreeEditor.createWidgetNodeWithDefaults(wrapperType);
    _wrapper!.children.add(node);
    _loc!.parent.children[_loc!.index!] = _wrapper!;
    provider.notify();
  }

  @override
  void undo() {
    if (_loc != null && _wrapper != null) {
      _loc!.parent.children[_loc!.index!] = node;
      provider.notify();
    }
  }
}