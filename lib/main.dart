// Import Flutter core libraries
import 'package:flutter/foundation.dart' show kIsWeb; // For platform detection if needed
import 'package:flutter/material.dart';

// Import third-party packages
import 'package:provider/provider.dart'; // State management
import 'package:dynamic_color/dynamic_color.dart'; // For Material You dynamic colors (Android 12+)
import 'package:url_launcher/url_launcher.dart'; // For opening external links

// Import your own app files for theming, helpers, and UI components
import 'theme_provider.dart'; // Custom ThemeProvider managing theme state and preferences
import 'colour_scheme.dart'; // Defines your app's color schemes
import 'device_info_helper.dart'; // Helper for checking device capabilities like dynamic color support
import 'global_slide_transition_builder.dart'; // Custom page transitions

// Import your fragments (pages)
// TODO: Move the page classes at the bottom of this file into their own separate files.
// For example: 'fragments/home_page.dart', 'fragments/rewards_page.dart', etc.
import 'fragments/home_page.dart';
import 'fragments/rewards_page.dart';
import 'fragments/pay_page.dart';
import 'fragments/account_page.dart';

// Import pages for settings and help, adopted from the Harmony app structure
import 'settings/settings_page.dart';
import 'helpcenter/helpcenter_page.dart';

// Import the custom AnimatedFabMenu widget, adopted from the Harmony app structure
import 'widgets/animated_fab_menu.dart';

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

        // Common CardThemeData definition based on Material 3 toggle
        final CardThemeData commonCardTheme = CardThemeData(
          // Sharper corners for Material 2, softer for Material 3
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(themeProvider.useMaterial3 ? 12.0 : 8.0),
          ),
          // More pronounced shadow for Material 2, subtle for Material 3
          elevation: themeProvider.useMaterial3 ? 1.0 : 4.0,
        );

        if (useDynamic) {
          // If dynamic colors enabled and supported, build MaterialApp using them
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'HiCard', // App title changed to HiCard
            themeMode: themeProvider.themeMode,
            theme: ThemeData(
              useMaterial3: themeProvider.useMaterial3, // Enable Material 3 design
              colorScheme: lightDynamic ?? lightColorScheme, // Use dynamic or fallback light scheme
              textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Outfit'), // Custom font
              cardTheme: commonCardTheme, // Apply the common card theme
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  // Apply custom slide transition on all platforms
                  for (final platform in TargetPlatform.values)
                    platform: GlobalSlidePageTransitionsBuilder(),
                },
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: themeProvider.useMaterial3,
              colorScheme: darkDynamic ?? darkColorScheme, // Use dynamic or fallback dark scheme
              textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Outfit'),
              cardTheme: commonCardTheme, // Apply the common card theme
              pageTransitionsTheme: PageTransitionsTheme(
                builders: {
                  for (final platform in TargetPlatform.values)
                    platform: GlobalSlidePageTransitionsBuilder(),
                },
              ),
            ),
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
          title: 'HiCard', // App title changed to HiCard
          themeMode: themeProvider.themeMode,
          theme: ThemeData(
            useMaterial3: themeProvider.useMaterial3,
            colorScheme: lightScheme,
            textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Outfit'),
            cardTheme: commonCardTheme,
            pageTransitionsTheme: PageTransitionsTheme(
              builders: {
                for (final platform in TargetPlatform.values)
                  platform: GlobalSlidePageTransitionsBuilder(),
              },
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: themeProvider.useMaterial3,
            colorScheme: darkScheme,
            textTheme: ThemeData.dark().textTheme.apply(fontFamily: 'Outfit'),
            cardTheme: commonCardTheme,
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

// ResponsiveScaffold is the main UI scaffold that adapts navigation for wide or narrow screens
class ResponsiveScaffold extends StatefulWidget {
  final bool dynamicColorSupported; // Whether dynamic color is supported on this device

  const ResponsiveScaffold({Key? key, required this.dynamicColorSupported})
      : super(key: key);

  @override
  State<ResponsiveScaffold> createState() => _ResponsiveScaffoldState();
}

class _ResponsiveScaffoldState extends State<ResponsiveScaffold> {
  int _selectedIndex = 0; // Tracks currently selected navigation index

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // This method returns the current page based on the selected index.
  // It replaces the InAppWebView.
  Widget _buildCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return const HomePage();
      case 1:
        return const RewardsPage();
      case 2:
        return const PayPage();
      case 3:
        return const AccountPage();
      default:
      // Fallback for an invalid index
        return const Center(child: Text("Page not found."));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width >= 600;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool useMaterial3 = themeProvider.useMaterial3;

    // Define FAB menu items, similar to Harmony app
    final List<MiniFabItem> menuFabItems = [
      MiniFabItem(
        icon: Icons.settings_rounded,
        label: 'Settings',
        onTap: () {
          if (context.mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
          }
        },
      ),
      MiniFabItem(
        icon: Icons.help_outline_rounded,
        label: 'Help',
        onTap: () {
          if (context.mounted) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpcenterPage()));
          }
        },
      ),
      MiniFabItem(
        icon: Icons.web_rounded,
        label: 'Visit Blog',
        onTap: () async {
          const url = 'https://hienterprises.blogspot.com';
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Could not launch $url')),
              );
            }
          }
        },
      ),
    ];

    return Scaffold(
      // AppBar is removed to give each fragment control over its own app bar if needed.
      body: Row(
        children: [
          if (isWideScreen) _buildNavigationRail(isWideScreen),
          Expanded(
            // The body now builds a native fragment instead of a WebView
            child: _buildCurrentPage(),
          ),
        ],
      ),
      bottomNavigationBar: isWideScreen ? null : _buildNavigationBar(useMaterial3),
      // Floating Action Button for menu items, adopted from Harmony
      floatingActionButton: AnimatedFabMenu(fabItems: menuFabItems),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Builds the NavigationRail for wider screens
  NavigationRail _buildNavigationRail(bool isWideScreen) {
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      labelType: isWideScreen
          ? NavigationRailLabelType.all
          : NavigationRailLabelType.none,
      // Destinations updated for HiCard
      destinations: const [
        NavigationRailDestination(icon: Icon(Icons.home_rounded), label: Text('Home')),
        NavigationRailDestination(icon: Icon(Icons.stars_rounded), label: Text('Rewards')),
        NavigationRailDestination(icon: Icon(Icons.wallet_rounded), label: Text('Pay')),
        NavigationRailDestination(icon: Icon(Icons.account_circle_rounded), label: Text('Account')),
      ],
    );
  }

  // Builds the BottomNavigationBar for narrower screens
  Widget _buildNavigationBar(bool useMaterial3) {
    if (useMaterial3) {
      // Material 3 style NavigationBar
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
          elevation: 3,
          // Destinations updated for HiCard
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.stars_rounded), label: 'Rewards'),
            NavigationDestination(icon: Icon(Icons.wallet_rounded), label: 'Pay'),
            NavigationDestination(icon: Icon(Icons.account_circle_rounded), label: 'Account'),
          ],
        ),
      );
    } else {
      // Material 2 style BottomNavigationBar
      return BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        // Items updated for HiCard
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.stars_rounded), label: 'Rewards'),
          BottomNavigationBarItem(icon: Icon(Icons.wallet_rounded), label: 'Pay'),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle_rounded), label: 'Account'),
        ],
      );
    }
  }
}