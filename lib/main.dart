import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'colour_scheme.dart';
import 'settings/settings_page.dart';
import 'helpcenter/helpcenter_page.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

// Import the new fullscreen menu page
import 'fullscreen_menu_page.dart'; // Adjust path if needed

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HiCard',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Outfit'),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Outfit'),
      ),
      themeMode: themeProvider.themeMode,
      home: const ResponsiveScaffold(),
    );
  }
}

class ResponsiveScaffold extends StatefulWidget {
  const ResponsiveScaffold({super.key});

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  int _selectedIndex = 0;
  InAppWebViewController? _webViewController;

  final List<String> _urls = [
    'https://thehighlandcafe.github.io/hioswebcore/rewards/hicard/home.html',
    'https://thehighlandcafe.github.io/hioswebcore/rewards/hicard/offers.html',
    'https://thehighlandcafe.github.io/hioswebcore/rewards/hicard/pay.html',
  ];

  final List<String> _titles = [
    'Home',
    'Rewards',
    'Pay',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _webViewController?.loadUrl(
      urlRequest: URLRequest(url: WebUri(_urls[index])),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            _titles[_selectedIndex],
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const FullscreenMenuPage()));
            },
          ),
        ],
      ),
      body: Row(
        children: [
          if (isWideScreen) _buildNavigationRail(isWideScreen),
          Expanded(
            child: InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(_urls[_selectedIndex])),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  javaScriptEnabled: true,
                ),
              ),
              onWebViewCreated: (controller) {
                _webViewController = controller;
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: isWideScreen ? null : _buildNavigationBar(),
    );
  }

  NavigationRail _buildNavigationRail(bool isWideScreen) {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      labelType: isWideScreen ? NavigationRailLabelType.all : NavigationRailLabelType.none,
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.home_rounded), label: Text('Home')),
        NavigationRailDestination(icon: Icon(Icons.stars_rounded), label: Text('Rewards')),
        NavigationRailDestination(icon: Icon(Icons.wallet_rounded), label: Text('Pay')),
      ],
    );
  }

  Widget _buildNavigationBar() {
    return Theme(
      data: Theme.of(context).copyWith(
        navigationBarTheme: const NavigationBarThemeData(
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        ),
      ),
      child: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        height: 60,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.stars_rounded), label: 'Rewards'),
          NavigationDestination(icon: Icon(Icons.wallet_rounded), label: 'Pay'),
        ],
      ),
    );
  }

}
