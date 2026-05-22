import 'package:flutter/material.dart';

class CanvasPreviewMode extends InheritedWidget {
  final bool isLivePreview;

  const CanvasPreviewMode({
    super.key,
    required this.isLivePreview,
    required super.child,
  });

  static bool of(BuildContext context) {
    final mode = context.dependOnInheritedWidgetOfExactType<CanvasPreviewMode>();
    return mode?.isLivePreview ?? false;
  }

  @override
  bool updateShouldNotify(CanvasPreviewMode oldWidget) {
    return isLivePreview != oldWidget.isLivePreview;
  }
}
