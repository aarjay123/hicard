import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

// Re-import shared UI components
import '../settings_ui_components.dart'; // Make sure this path is correct

class HelpcenterPage extends StatefulWidget {
  const HelpcenterPage({super.key});

  @override
  State<HelpcenterPage> createState() => _HelpcenterPageState();
}

class _HelpcenterPageState extends State<HelpcenterPage> {
  bool showWebPage = false;
  String currentUrl = '';
  String currentArticleTitle = ''; // To store the title of the current article
  InAppWebViewController? _webViewController;

  Key webViewKey = UniqueKey();

  // Modified to accept the article title
  void _loadWebPage(String url, String title) {
    setState(() {
      currentUrl = url;
      currentArticleTitle = title; // Set the article title
      showWebPage = true;
      webViewKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define the groups and items for the help center page,
    // mirroring the structure implied by the original Dividers.
    final List<_HelpPageGroup> helpGroups = [
      _HelpPageGroup(
        title: "Getting Started", // Title for the first group
        items: [
          _HelpPageItem(
            icon: Icons.smartphone_rounded,
            label: "App Tutorial",
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/tutorial.html",
                "App Tutorial"), // Pass title
          ),
        ],
      ),
      _HelpPageGroup(
        title: "Help Topics", // Title for the second group
        items: [
          _HelpPageItem(
            icon: Icons.qr_code_rounded,
            label: "Collecting Points",
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/rewards/collect.html",
                "Collecting Points"), // Pass title
          ),
          _HelpPageItem(
            icon: Icons.hotel_rounded,
            label: "Redeeming Points",
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/rewards/redeem.html",
                "Redeeming Points"), // Pass title
          ),
          _HelpPageItem(
            icon: Icons.account_circle_rounded,
            label: "Signing-Up",
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/rewards/signup.html",
                "Signing-Up"), // Pass title
          ),
        ],
      ),
      _HelpPageGroup(
        title: "More Information", // Title for the third group
        items: [
          _HelpPageItem(
            icon: Icons.description_rounded,
            label: "Terms & Conditions",
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/more/terms-conditions.html",
                "Terms & Conditions"), // Pass title
          ),
          _HelpPageItem(
            icon: Icons.feedback_rounded,
            label: "App Feedback",
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/more/appfeedback.html",
                "App Feedback"), // Pass title
          ),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        // Updated title logic
        title: Text(showWebPage ? currentArticleTitle : "Help Center"),
        leading: showWebPage
            ? IconButton(
          // Changed icon to back arrow
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            setState(() {
              showWebPage = false;
            });
          },
        )
            : null,
      ),
      body: showWebPage
          ? InAppWebView(
        key: webViewKey,
        initialUrlRequest: URLRequest(url: WebUri(currentUrl)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
      )
          : Padding( // Added padding for consistency
        padding: const EdgeInsets.all(24.0),
        child: ListView.builder(
          itemCount: helpGroups.length,
          itemBuilder: (context, groupIndex) {
            final group = helpGroups[groupIndex];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingsGroupTitle(title: group.title),
                Column(
                  children: List.generate(group.items.length, (itemIndex) {
                    final itemData = group.items[itemIndex];
                    final isFirstItem = itemIndex == 0;
                    final isLastItem = itemIndex == group.items.length - 1;

                    return SettingsListItem(
                      icon: itemData.icon,
                      label: itemData.label,
                      onTap: itemData.onTap,
                      isFirstItem: isFirstItem,
                      isLastItem: isLastItem,
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

// Helper classes to structure the data for the settings UI components
class _HelpPageGroup {
  final String title;
  final List<_HelpPageItem> items;

  _HelpPageGroup({
    required this.title,
    required this.items,
  });
}

class _HelpPageItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  _HelpPageItem({
    required this.icon,
    required this.label,
    this.onTap,
  });
}