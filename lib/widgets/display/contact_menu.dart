import 'package:flutter/material.dart';

class ContactMenu extends StatelessWidget {
  final VoidCallback? onPhoneTap;
  final VoidCallback? onVideoTap;
  final VoidCallback? onLocationTap;
  final VoidCallback? onMediaTap;
  final VoidCallback? onSearchTap;

  const ContactMenu({
    super.key,
    this.onPhoneTap,
    this.onVideoTap,
    this.onLocationTap,
    this.onMediaTap,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    // The background color from the mockup is a dark slate/gray.
    // Assuming this pops up over other content, adding a slight shadow helps it stand out.
    return Container(
      width: 48.0, // Close to the 45px specified in the CSS
      height: 275.0,
      decoration: BoxDecoration(
        color: const Color(0xFF23272F), // Dark background matching the image
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8.0,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMenuIcon(
            icon: Icons.phone_in_talk_outlined,
            onTap: onPhoneTap,
            tooltip: 'Phone Call',
          ),
          _buildMenuIcon(
            icon: Icons.videocam_outlined,
            onTap: onVideoTap,
            tooltip: 'Video Call',
          ),
          _buildMenuIcon(
            icon: Icons.map_outlined,
            onTap: onLocationTap,
            tooltip: 'Location',
          ),
          _buildMenuIcon(
            icon: Icons.photo_library_outlined, // Image/Media folder
            onTap: onMediaTap,
            tooltip: 'Media',
          ),
          _buildMenuIcon(
            icon: Icons.manage_search_outlined, // List with search glass
            onTap: onSearchTap,
            tooltip: 'Search',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuIcon({
    required IconData icon,
    required VoidCallback? onTap,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: IconButton(
        icon: Icon(icon),
        color: const Color(0xFF2EB82E), // Success-500 green from prompt CSS
        iconSize: 26.0, // Fits nicely inside the 48px width
        splashRadius: 20.0,
        tooltip: tooltip,
        onPressed: onTap ?? () {
          // TODO: Call other components/actions here later
          debugPrint('$tooltip icon tapped');
        },
      ),
    );
  }
}