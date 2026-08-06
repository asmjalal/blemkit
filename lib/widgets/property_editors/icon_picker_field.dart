import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class IconPickerField extends StatefulWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const IconPickerField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<IconPickerField> createState() => _IconPickerFieldState();
}

class _IconPickerFieldState extends State<IconPickerField> {
  static const Map<String, dynamic> availableIcons = {
    'Icons.home': Icons.home,
    'Icons.home_outlined': Icons.home_outlined,
    'Icons.search': Icons.search,
    'Icons.search_outlined': Icons.search_outlined,
    'Icons.add': Icons.add,
    'Icons.add_circle': Icons.add_circle,
    'Icons.add_circle_outline': Icons.add_circle_outline,
    'Icons.favorite': Icons.favorite,
    'Icons.favorite_border': Icons.favorite_border,
    'Icons.person': Icons.person,
    'Icons.person_outline': Icons.person_outline,
    'Icons.group': Icons.group,
    'Icons.settings': Icons.settings,
    'Icons.settings_outlined': Icons.settings_outlined,
    'Icons.notifications': Icons.notifications,
    'Icons.notifications_outlined': Icons.notifications_outlined,
    'Icons.chat': Icons.chat,
    'Icons.chat_bubble_outline': Icons.chat_bubble_outline,
    'Icons.message': Icons.message,
    'Icons.email': Icons.email,
    'Icons.phone': Icons.phone,
    'Icons.shopping_cart': Icons.shopping_cart,
    'Icons.shopping_bag_outlined': Icons.shopping_bag_outlined,
    'Icons.camera_alt': Icons.camera_alt,
    'Icons.place': Icons.place,
    'Icons.location_on': Icons.location_on,
    'Icons.edit': Icons.edit,
    'Icons.edit_outlined': Icons.edit_outlined,
    'Icons.delete': Icons.delete,
    'Icons.delete_outline': Icons.delete_outline,
    'Icons.share': Icons.share,
    'Icons.star': Icons.star,
    'Icons.star_border': Icons.star_border,
    'Icons.menu': Icons.menu,
    'Icons.close': Icons.close,
    'Icons.check': Icons.check,
    'Icons.check_circle': Icons.check_circle,
    'Icons.info': Icons.info,
    'Icons.info_outline': Icons.info_outline,
    'Icons.arrow_back': Icons.arrow_back,
    'Icons.arrow_forward': Icons.arrow_forward,
    'Icons.chevron_right': Icons.chevron_right,
    'Icons.more_vert': Icons.more_vert,
    'Icons.more_horiz': Icons.more_horiz,
    'Icons.explore': Icons.explore,
    'Icons.thumb_up': Icons.thumb_up,
    'Icons.play_arrow': Icons.play_arrow,
    'Icons.pause': Icons.pause,
    'Icons.image': Icons.image,
    'Icons.photo_camera': Icons.photo_camera,
    'Icons.dashboard': Icons.dashboard,
    'FontAwesomeIcons.instagram': FontAwesomeIcons.instagram,
    'FontAwesomeIcons.facebook': FontAwesomeIcons.facebook,
    'FontAwesomeIcons.twitter': FontAwesomeIcons.twitter,
    'FontAwesomeIcons.tiktok': FontAwesomeIcons.tiktok,
    'FontAwesomeIcons.youtube': FontAwesomeIcons.youtube,
    'FontAwesomeIcons.linkedin': FontAwesomeIcons.linkedin,
    'FontAwesomeIcons.github': FontAwesomeIcons.github,
    'FontAwesomeIcons.apple': FontAwesomeIcons.apple,
    'FontAwesomeIcons.google': FontAwesomeIcons.google,
    'FontAwesomeIcons.heart': FontAwesomeIcons.heart,
    'FontAwesomeIcons.solidHeart': FontAwesomeIcons.solidHeart,
    'FontAwesomeIcons.comment': FontAwesomeIcons.comment,
    'FontAwesomeIcons.solidComment': FontAwesomeIcons.solidComment,
    'FontAwesomeIcons.paperPlane': FontAwesomeIcons.paperPlane,
    'FontAwesomeIcons.solidPaperPlane': FontAwesomeIcons.solidPaperPlane,
    'FontAwesomeIcons.bookmark': FontAwesomeIcons.bookmark,
    'FontAwesomeIcons.solidBookmark': FontAwesomeIcons.solidBookmark,
    'FontAwesomeIcons.magnifyingGlass': FontAwesomeIcons.magnifyingGlass,
    'FontAwesomeIcons.house': FontAwesomeIcons.house,
    'FontAwesomeIcons.bell': FontAwesomeIcons.bell,
    'FontAwesomeIcons.solidBell': FontAwesomeIcons.solidBell,
    'FontAwesomeIcons.user': FontAwesomeIcons.user,
    'FontAwesomeIcons.solidUser': FontAwesomeIcons.solidUser,
    'FontAwesomeIcons.gear': FontAwesomeIcons.gear,
    'FontAwesomeIcons.plus': FontAwesomeIcons.plus,
    'FontAwesomeIcons.xmark': FontAwesomeIcons.xmark,
    'FontAwesomeIcons.bars': FontAwesomeIcons.bars,
    'FontAwesomeIcons.ellipsisVertical': FontAwesomeIcons.ellipsisVertical,
    'FontAwesomeIcons.ellipsis': FontAwesomeIcons.ellipsis,
  };

  void _showIconPickerDialog(BuildContext context) {
    String searchQuery = '';
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final materialIcons = availableIcons.entries.where((entry) {
              return entry.key.startsWith('Icons.') && entry.key.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();
            
            final faIcons = availableIcons.entries.where((entry) {
              return entry.key.startsWith('FontAwesomeIcons.') && entry.key.toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            Widget buildGrid(List<MapEntry<String, dynamic>> icons) {
              return GridView.builder(
                padding: const EdgeInsets.only(top: 16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: icons.length,
                itemBuilder: (context, index) {
                  final iconEntry = icons[index];
                  final isSelected = widget.value == iconEntry.key;
                  return InkWell(
                    onTap: () {
                      widget.onChanged(iconEntry.key);
                      Navigator.of(context).pop();
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.withValues(alpha: 0.2) : const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected ? Border.all(color: Colors.blue) : Border.all(color: Colors.transparent),
                      ),
                      child: Center(
                        child: iconEntry.key.startsWith('FontAwesomeIcons.')
                            ? FaIcon(
                                iconEntry.value,
                                color: isSelected ? Colors.blue : Colors.white70,
                                size: 28,
                              )
                            : Icon(
                                iconEntry.value,
                                color: isSelected ? Colors.blue : Colors.white70,
                                size: 28,
                              ),
                      ),
                    ),
                  );
                },
              );
            }

            return Dialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: DefaultTabController(
                length: 2,
                child: Container(
                  width: 400,
                  height: 550,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Icon',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search icons...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(Icons.search, color: Colors.white54),
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      const TabBar(
                        indicatorColor: Colors.blue,
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.white54,
                        dividerColor: Colors.transparent,
                        tabs: [
                          Tab(text: 'Material'),
                          Tab(text: 'FontAwesome'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            buildGrid(materialIcons),
                            buildGrid(faIcons),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isEmpty = widget.value.isEmpty;
    final currentIcon = isEmpty ? Icons.do_not_disturb_alt : (availableIcons[widget.value] ?? Icons.widgets);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _showIconPickerDialog(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Row(
                children: [
                  widget.value.startsWith('FontAwesomeIcons.')
                      ? FaIcon(currentIcon, color: isEmpty ? Colors.white30 : Colors.white, size: 20)
                      : Icon(currentIcon, color: isEmpty ? Colors.white30 : Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEmpty ? 'None' : widget.value.replaceAll('Icons.', '').replaceAll('FontAwesomeIcons.', ''),
                      style: TextStyle(color: isEmpty ? Colors.white30 : Colors.white, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (!isEmpty)
                    GestureDetector(
                      onTap: () => widget.onChanged(''),
                      child: const Icon(Icons.close, color: Colors.white54, size: 18),
                    )
                  else
                    const Icon(Icons.arrow_drop_down, color: Colors.white54),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
