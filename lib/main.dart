import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_provider.dart';
import 'colour_scheme.dart';
import 'fullscreen_menu_page.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<bool> checkIfLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('hasLoggedIn') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return FutureBuilder<bool>(
      future: checkIfLoggedIn(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final hasLoggedIn = snapshot.data!;
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
          home: hasLoggedIn ? const ResponsiveScaffold() : const AuthScreen(),
        );
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasLoggedIn', true);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ResponsiveScaffold()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login or Sign Up')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) =>
                value!.isEmpty ? 'Please enter a username' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                value!.isEmpty ? 'Please enter a password' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
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
    'https://thehighlandcafe.github.io/hioswebcore/rewards/hicard/account.html',
  ];

  final List<String> _titles = [
    'Home',
    'Rewards',
    'Pay',
    'Account',
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const FullscreenMenuPage()));
            },
          ),
        ],
      ),
      body: Row(
        children: [
          if (isWideScreen) _buildNavigationRail(),
          Expanded(
            child: InAppWebView(
              initialUrlRequest:
              URLRequest(url: WebUri(_urls[_selectedIndex])),
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

  NavigationRail _buildNavigationRail() {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
            icon: Icon(Icons.home_rounded), label: Text('Home')),
        NavigationRailDestination(
            icon: Icon(Icons.stars_rounded), label: Text('Rewards')),
        NavigationRailDestination(
            icon: Icon(Icons.wallet_rounded), label: Text('Pay')),
        NavigationRailDestination(
            icon: Icon(Icons.account_circle_rounded), label: Text('Account')),
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
          NavigationDestination(icon: Icon(Icons.account_circle_rounded), label: 'Account'),
        ],
      ),
    );
  }
}
