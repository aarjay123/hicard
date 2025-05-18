import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class PrivacyPolicyPage extends StatefulWidget {
  const PrivacyPolicyPage({super.key});

  @override
  State<PrivacyPolicyPage> createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  late InAppWebViewController _webViewController;

  final String privacyPolicyUrl = 'https://thehighlandcafe.github.io/hioswebcore/settings/privacypolicy.html';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Privacy Policy")),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(privacyPolicyUrl)),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;
        },
      ),
    );
  }
}
