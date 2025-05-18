import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AppsServicesPage extends StatelessWidget {
  const AppsServicesPage({super.key});

  Future<void> _launchExternalUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch the website.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Apps & Services"),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              "Recommended",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded),
            title: const Text("Harmony"),
            subtitle: const Text("This is the main app by The Highland Cafe™, for doing everything from booking a hotel to ordering food, and more!"),
            onTap: () {
              _launchExternalUrl(context, 'https://github.com/aarjay123/harmonyapp');
            },
          ),
          ListTile(
            leading: const Icon(Icons.music_note_rounded),
            title: const Text("HiOSMusic"),
            subtitle: const Text("This is our brand new music app for Android. Your music, your vibe."),
            onTap: () {
              _launchExternalUrl(context, 'https://github.com/aarjay123/hiosmusic');
            },
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_customize_rounded),
            title: const Text("Other software by HiDev"),
            subtitle: const Text("Take a look at other great apps, software, and services also by HiDev!"),
            onTap: () {
              _launchExternalUrl(context, 'https://sites.google.com/view/nuggetdev');
            },
          ),
        ],
      ),
    );
  }
}
