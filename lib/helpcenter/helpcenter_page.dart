import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class HelpcenterPage extends StatefulWidget {
  const HelpcenterPage({super.key});

  @override
  State<HelpcenterPage> createState() => _HelpcenterPageState();
}

class _HelpcenterPageState extends State<HelpcenterPage> {
  bool showWebPage = false;
  String currentUrl = '';
  InAppWebViewController? _webViewController;

  // Generate a unique key to force widget rebuild
  Key webViewKey = UniqueKey();

  void _loadWebPage(String url) {
    setState(() {
      currentUrl = url;
      showWebPage = true;
      webViewKey = UniqueKey(); // Force rebuild with new URL
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help Center"),
        leading: showWebPage
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
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
          : ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.smartphone),
            title: const Text("App Tutorial"),
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/tutorial.html"),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.restaurant),
            title: const Text("Restaurant"),
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/restaurant.html"),
          ),
          ListTile(
            leading: const Icon(Icons.hotel),
            title: const Text("Hotel"),
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/hotel.html"),
          ),
          ListTile(
            leading: const Icon(Icons.vpn_key),
            title: const Text("Room Key"),
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/roomkey.html"),
          ),
          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text("Customer Support"),
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/more/support.html"),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text("Internet"),
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/internet.html"),
          ),
          ListTile(
            leading: const Icon(Icons.update),
            title: const Text("Updates"),
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/updates.html"),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.new_releases),
            title: const Text("Coming Soon"),
            onTap: () => _loadWebPage(
                "https://sites.google.com/view/x-by-thc-comingsoon"),
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text("Terms & Conditions"),
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/more/terms-conditions.html"),
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text("App Feedback"),
            onTap: () => _loadWebPage(
                "https://thehighlandcafe.github.io/hioswebcore/helpcenter/more/appfeedback.html"),
          ),
        ],
      ),
    );
  }
}
