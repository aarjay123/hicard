// Import Flutter core libraries
import 'package:flutter/foundation.dart' show kIsWeb; // For platform detection if needed
import 'package:flutter/material.dart';

// Import third-party packages
import 'package:provider/provider.dart'; // State management
import 'package:dynamic_color/dynamic_color.dart'; // For Material You dynamic colors (Android 12+)
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // For embedding web content
import 'package:shared_preferences/shared_preferences.dart';

// Import your own app files for theming, helpers, and UI components
import 'theme_provider.dart'; // Custom ThemeProvider managing theme state and preferences
import 'colour_scheme.dart'; // Defines your app's color schemes
import 'device_info_helper.dart'; // Helper for checking device capabilities like dynamic color support
import 'fullscreen_menu_page.dart'; // Fullscreen menu page for app navigation
import 'global_slide_transition_builder.dart'; // Custom page transitions

// For platform-specific imports (e.g. non-web platforms)
import 'dart:io' show Platform;

// The main entry point of the Flutter app
void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter engine is initialized before running app
  runApp(const AppLoader()); // Runs the root widget AppLoader
}

// Stateful widget to handle async initialization before showing main app
class AppLoader extends StatefulWidget {
  const AppLoader({Key? key}) : super(key: key);

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> {
  ThemeProvider? _themeProvider; // Holds the theme provider instance once loaded
  bool _error = false; // Flag to indicate if initialization failed
  bool _dynamicColorSupported = false; // Flag for whether dynamic color is supported on device

  @override
  void initState() {
    super.initState();
    _initTheme(); // Start theme initialization asynchronously on widget load
  }

  // Async method to initialize theme provider and detect dynamic color support
  Future<void> _initTheme() async {
    try {
      // Check device capability for dynamic color (Android 12+)
      final supported = await DeviceInfoHelper.supportsDynamicColor();
      _dynamicColorSupported = supported;

      // Create theme provider with dynamic color enabled flag
      final themeProvider = ThemeProvider(dynamicColorEnabled: supported);
      await themeProvider.loadPreferences(); // Load saved user theme preferences

      // If device doesn't support dynamic color, forcibly disable it in provider
      if (!supported) {
        themeProvider.dynamicColorEnabled = false;
      }

      // Update state with loaded provider instance, triggers UI rebuild
      setState(() {
        _themeProvider = themeProvider;
      });
    } catch (e, st) {
      // On error, log and set error flag to show error UI
      debugPrint('Failed to init theme: $e\n$st');
      setState(() {
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // If error occurred or theme provider is still null (loading), show error message
    if (_error || _themeProvider == null) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Failed to load preferences')),
        ),
      );
    }

    // Provide the loaded ThemeProvider to the widget subtree via Provider package
    return ChangeNotifierProvider.value(
      value: _themeProvider!,
      child: MyApp(dynamicColorSupported: _dynamicColorSupported),
    );
  }
}

// Main app widget, builds MaterialApp with theming based on dynamic color support and user preference
class MyApp extends StatelessWidget {
  final bool dynamicColorSupported; // Passed from AppLoader, device capability flag

  const MyApp({Key? key, required this.dynamicColorSupported}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      // Builder provides dynamic light and dark color schemes if available
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final themeProvider = Provider.of<ThemeProvider>(context);

        // Determine if dynamic color should be used based on device and user settings
        final useDynamic =
            themeProvider.dynamicColorEnabled && dynamicColorSupported;

        if (useDynamic) {
          // If dynamic colors enabled and supported, build MaterialApp using them
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'HiCard',
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              useMaterial3: true, // Enable Material 3 design
              colorScheme: lightDynamic ?? lightColorScheme, // Use dynamic or fallback light scheme
              textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Outfit'), // Custom font
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  // Apply custom slide transition on all platforms
                  for (final platform in TargetPlatform.values)
                    platform: GlobalSlidePageTransitionsBuilder(),
                },
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: darkDynamic ?? darkColorScheme, // Use dynamic or fallback dark scheme
              textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Outfit'),
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  for (final platform in TargetPlatform.values)
                    platform: GlobalSlidePageTransitionsBuilder(),
                },
              ),
            ),
            // Main app content scaffold
            home: ResponsiveScaffold(dynamicColorSupported: dynamicColorSupported),
          );
        }

        // Otherwise, build app with user's selected color scheme (no dynamic color)
        final ColorScheme lightScheme = themeProvider.currentColorScheme;
        final ColorScheme darkScheme = ColorScheme.fromSeed(
          seedColor: lightScheme.primary,
          brightness: Brightness.dark,
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'HiCard',
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightScheme,
            textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Outfit'),
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                for (final platform in TargetPlatform.values)
                  platform: GlobalSlidePageTransitionsBuilder(),
              },
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkScheme,
            textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Outfit'),
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                for (final platform in TargetPlatform.values)
                  platform: GlobalSlidePageTransitionsBuilder(),
              },
            ),
          ),
          home: ResponsiveScaffold(dynamicColorSupported: dynamicColorSupported),
        );
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  final bool dynamicColorSupported;

  const AuthScreen({super.key, required this.dynamicColorSupported});

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
        MaterialPageRoute(builder: (_) => ResponsiveScaffold(dynamicColorSupported: widget.dynamicColorSupported)),
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
  final bool dynamicColorSupported;

  const ResponsiveScaffold({super.key, required this.dynamicColorSupported});

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  int _selectedIndex = 0;
  InAppWebViewController? _webViewController;
  bool _hasError = false;

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
      _hasError = false;
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
            icon: const Icon(Icons.menu_open_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FullscreenMenuPage()),
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          if (isWideScreen) _buildNavigationRail(),
          Expanded(
            child: _hasError
                ? _buildErrorPage()
                : InAppWebView(
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
              onLoadError: (_, __, ___, ____) {
                setState(() => _hasError = true);
              },
              onLoadHttpError: (_, __, ___, ____) {
                setState(() => _hasError = true);
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
        NavigationRailDestination(icon: Icon(Icons.home_rounded), label: Text('Home')),
        NavigationRailDestination(icon: Icon(Icons.stars_rounded), label: Text('Rewards')),
        NavigationRailDestination(icon: Icon(Icons.wallet_rounded), label: Text('Pay')),
        NavigationRailDestination(icon: Icon(Icons.account_circle_rounded), label: Text('Account')),
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

  Widget _buildErrorPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 80),
          const SizedBox(height: 20),
          const Text('Failed to load page. Please check your connection.'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _hasError = false;
              });
              _webViewController?.reload();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}