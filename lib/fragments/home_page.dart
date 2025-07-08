import 'package:flutter/material.dart';

// --- HomePage Fragment ---
// This widget represents the main home screen of the HiCard app, styled for
// consistency with the Harmony app's modern aesthetic.
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  // Helper function to get the greeting based on the time of day.
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    // The Scaffold no longer has an AppBar, creating a more modern, seamless look.
    // SafeArea ensures the UI avoids system intrusions like notches.
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The UI is now broken into cleaner, reusable builder methods.
                _buildGreeting(context),
                const SizedBox(height: 24),
                _buildInfoCard(context),
                const SizedBox(height: 16),
                _buildRewardsCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the top greeting text.
  Widget _buildGreeting(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Using a ShaderMask to create the gradient text effect.
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              colors: [colorScheme.primary, colorScheme.tertiary],
            ).createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            ),
            child: Text(
              _getGreeting(),
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            'Welcome to HiCard!',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the card displaying user account information, styled like the Harmony app.
  Widget _buildInfoCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // The text style for content within the styled card.
    final cardTextStyle = TextStyle(color: colorScheme.onSecondaryContainer);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.secondaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 8.0),
            child: Text(
              'Your Accounts',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          // ExpansionTiles are used for a clean, expandable view of account details.
          ExpansionTile(
            shape: const Border(), // Removes default border for a cleaner look inside the card.
            tilePadding: const EdgeInsets.symmetric(horizontal: 20.0),
            iconColor: colorScheme.onSecondaryContainer,
            collapsedIconColor: colorScheme.onSecondaryContainer,
            title: Text('Current Account', style: cardTextStyle),
            subtitle: Text('£567.46', style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.w600)),
            children: <Widget>[
              const Divider(height: 1, indent: 20, endIndent: 20),
              ListTile(
                leading: Icon(Icons.shopping_cart, color: colorScheme.onSecondaryContainer),
                title: Text('The Highland Cafe™️, Lancaster', style: cardTextStyle),
                trailing: Text('-£35.98', style: cardTextStyle),
                dense: true,
              ),
              ListTile(
                leading: Icon(Icons.fastfood, color: colorScheme.onSecondaryContainer),
                title: Text('FoodHall™️, Carnforth', style: cardTextStyle),
                trailing: Text('-£78.99', style: cardTextStyle),
                dense: true,
              ),
            ],
          ),
          Divider(color: colorScheme.onSecondaryContainer.withOpacity(0.2), height: 1, indent: 20, endIndent: 20),
          ExpansionTile(
            shape: const Border(),
            tilePadding: const EdgeInsets.symmetric(horizontal: 20.0),
            iconColor: colorScheme.onSecondaryContainer,
            collapsedIconColor: colorScheme.onSecondaryContainer,
            title: Text('Savings Account', style: cardTextStyle),
            subtitle: Text('£2,499.48', style: textTheme.headlineSmall?.copyWith(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.w600)),
            children: <Widget>[
              ListTile(
                title: Text('No recent transactions.', style: cardTextStyle),
                dense: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the card displaying user rewards points, styled like the Harmony app.
  Widget _buildRewardsCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.secondaryContainer,
      child: ExpansionTile(
        shape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
        iconColor: colorScheme.onSecondaryContainer,
        collapsedIconColor: colorScheme.onSecondaryContainer,
        title: Text(
          'Your Rewards',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSecondaryContainer,
          ),
        ),
        subtitle: Text(
          '2,457 pts',
          style: textTheme.headlineSmall?.copyWith(
            color: colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: <Widget>[
          ListTile(
            title: Text('No recent redemptions.', style: TextStyle(color: colorScheme.onSecondaryContainer)),
            dense: true,
          )
        ],
      ),
    );
  }
}
