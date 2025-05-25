import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Step 1: Import shared UI components
import '../settings_ui_components.dart'; // Make sure this path is correct

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  // URL for the latest update
  final String _latestUpdateUrl = 'https://github.com/aarjay123/hicard/releases/latest';

  // Helper function to launch URLs
  Future<void> _launchExternalUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    // Check if the URL can be launched
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      // Show a snackbar if the URL cannot be launched
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch the website.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the groups and items for the updates page
    // These data structures are specific to this page
    final groups = [
      _UpdatePageGroup(
        title: "Downloads",
        items: [
          _UpdatePageItem(
            icon: Icons.download_rounded,
            label: "Download HiCard Update",
            subtitle:
            "Download the latest app installer file.\n1. Tap here, then tap the installer matching your OS.\n2. Install the update how you usually would.",
            onTap: () => _launchExternalUrl(context, _latestUpdateUrl),
          ),
        ],
      ),
      _UpdatePageGroup(
        title: "Version Information",
        items: [
          _UpdatePageItem(
            icon: Icons.info_outline_rounded,
            label: "This version: v1.1.0",
            subtitle: null,
            onTap: null,
          ),
        ],
      ),
      _UpdatePageGroup(
        title: "About",
        items: [
          _UpdatePageItem(
            icon: Icons.info_outline_rounded,
            label: "About HiCard",
            subtitle:
            "HiCard is the successor to HiRewards -- the app is now based on Flutter, so is adaptive and cross-platform.\nThis app shares a similar codebase with Harmony.",
            onTap: null,
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Updates"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0), // Consistent padding
        child: ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, groupIndex) {
            final group = groups[groupIndex];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Step 2: Use the shared SettingsGroupTitle widget
                SettingsGroupTitle(title: group.title),
                // Items in the group
                Column(
                  children: List.generate(group.items.length, (itemIndex) {
                    final itemData = group.items[itemIndex]; // Renamed for clarity
                    final isFirstItem = itemIndex == 0;
                    final isLastItem = itemIndex == group.items.length - 1;

                    // Step 3: Use the shared SettingsListItem widget and RETURN it
                    return SettingsListItem(
                      icon: itemData.icon,
                      label: itemData.label,
                      subtitle: itemData.subtitle,
                      onTap: itemData.onTap,
                      isFirstItem: isFirstItem,
                      isLastItem: isLastItem,
                      // No 'trailing' widget passed, so chevron will appear if onTap is not null
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Step 4: Keep Local Data Structures
// Helper class to define the structure of a group for this specific page
class _UpdatePageGroup {
  final String title;
  final List<_UpdatePageItem> items;

  _UpdatePageGroup({
    required this.title,
    required this.items,
  });
}

// Helper class to define the structure of an item for this specific page
class _UpdatePageItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;

  _UpdatePageItem({
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
  });
}