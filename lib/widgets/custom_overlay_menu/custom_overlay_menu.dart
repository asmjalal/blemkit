import 'package:flutter/material.dart';

/// CustomOverlayMenu: Shows a popup menu at a given position, with support for submenus.
/// Usage: Call CustomOverlayMenu.show(context, position, items: [...]);
class CustomOverlayMenu {
  static void show(
    BuildContext context,
    Offset position, {
    required List<CustomOverlayMenuItem> items,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _CustomOverlayMenuWidget(
        position: position,
        items: items,
        onDismiss: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }
}

class CustomOverlayMenuItem {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final List<CustomOverlayMenuItem>? submenu;

  CustomOverlayMenuItem({
    required this.label,
    this.icon,
    this.onTap,
    this.submenu,
  });
}

class _CustomOverlayMenuWidget extends StatefulWidget {
  final Offset position;
  final List<CustomOverlayMenuItem> items;
  final VoidCallback onDismiss;

  const _CustomOverlayMenuWidget({
    required this.position,
    required this.items,
    required this.onDismiss,
  });

  @override
  State<_CustomOverlayMenuWidget> createState() => _CustomOverlayMenuWidgetState();
}

class _CustomOverlayMenuWidgetState extends State<_CustomOverlayMenuWidget> {
  OverlayEntry? _submenuEntry;
  int? _hoveredIndex;
  late List<GlobalKey> _itemKeys;
  bool _isPointerInsideMenu = false;
  bool _isPointerInsideSubmenu = false;
  bool _isMounted = true;

  @override
  void initState() {
    super.initState();
    _itemKeys = List.generate(widget.items.length, (_) => GlobalKey());
  }

  @override
  void dispose() {
    _isMounted = false;
    _removeSubmenu();
    super.dispose();
  }

  void _showSubmenu(BuildContext context, int index, List<CustomOverlayMenuItem> submenu) {
    _removeSubmenu();
    final overlay = Overlay.of(context);
    final key = _itemKeys[index];

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? itemBox = key.currentContext?.findRenderObject() as RenderBox?;
      if (itemBox == null || !itemBox.hasSize) return;
      final Offset itemPosition = itemBox.localToGlobal(Offset.zero);
      final Size itemSize = itemBox.size;
      final submenuOffset = Offset(itemPosition.dx + itemSize.width, itemPosition.dy);
      _submenuEntry = OverlayEntry(
        builder: (context) => MouseRegion(
          onEnter: (_) {
            _isPointerInsideSubmenu = true;
          },
          onExit: (_) {
            _isPointerInsideSubmenu = false;
            Future.delayed(const Duration(milliseconds: 100), () {
              if (!_isPointerInsideMenu && !_isPointerInsideSubmenu) {
                _removeSubmenu();
              }
            });
          },
          child: _CustomOverlayMenuWidget(
            position: submenuOffset,
            items: submenu,
            onDismiss: () {
              _removeSubmenu();
              widget.onDismiss();
            },
          ),
        ),
      );
      overlay.insert(_submenuEntry!);
    });
  }

  void _removeSubmenu() {
    _submenuEntry?.remove();
    _submenuEntry = null;
    if (_isMounted) {
      setState(() {
        _hoveredIndex = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _isPointerInsideMenu = true;
      },
      onExit: (_) {
        _isPointerInsideMenu = false;
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!_isPointerInsideMenu && !_isPointerInsideSubmenu) {
            if (_isMounted) widget.onDismiss();
            _removeSubmenu();
          }
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          if (_isMounted) widget.onDismiss();
          _removeSubmenu();
        },
        child: Stack(
          children: [
            Positioned(
              left: widget.position.dx,
              top: widget.position.dy,
              child: Material(
                elevation: 8,
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 180, maxWidth: 240),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    itemCount: widget.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.items[index];
                      return MouseRegion(
                        onEnter: (_) {
                          if (item.submenu != null) {
                            setState(() {
                              _hoveredIndex = index;
                            });
                            _showSubmenu(context, index, item.submenu!);
                          } else {
                            _removeSubmenu();
                          }
                        },
                        child: ListTile(
                          key: _itemKeys[index],
                          leading: item.icon != null ? Icon(item.icon, color: Colors.white) : null,
                          title: Text(item.label, style: const TextStyle(color: Colors.white)),
                          trailing: item.submenu != null ? const Icon(Icons.arrow_right, color: Colors.white) : null,
                          tileColor: _hoveredIndex == index ? Colors.grey[800] : null,
                          onTap: () {
                            if (item.submenu != null) {
                              setState(() {
                                _hoveredIndex = index;
                              });
                              _showSubmenu(context, index, item.submenu!);
                            } else {
                              if (item.onTap != null) item.onTap!();
                              if (_isMounted) widget.onDismiss();
                              _removeSubmenu();
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 