import 'widget_context_menu_actions.dart';

class WidgetCommandManager {
  final List<WidgetContextMenuAction> _undoStack = [];
  final List<WidgetContextMenuAction> _redoStack = [];
  final int maxHistory;

  WidgetCommandManager({this.maxHistory = 50});

  void executeAction(WidgetContextMenuAction action) {
    action.execute();
    _undoStack.add(action);
    if (_undoStack.length > maxHistory) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }

  void undo() {
    if (_undoStack.isNotEmpty) {
      final action = _undoStack.removeLast();
      action.undo();
      _redoStack.add(action);
    }
  }

  void redo() {
    if (_redoStack.isNotEmpty) {
      final action = _redoStack.removeLast();
      action.execute();
      _undoStack.add(action);
    }
  }

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;
} 