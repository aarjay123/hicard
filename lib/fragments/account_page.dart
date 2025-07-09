import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- AccountPage Fragment ---
// This widget displays the user's account details.
class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This is now a stateless widget as the name is hardcoded.
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildProfileCard(context),
                const SizedBox(height: 16),
                _buildDetailsCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the main header for the page.
  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              colors: [colorScheme.primary, colorScheme.tertiary],
            ).createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            ),
            child: Text(
              'Account',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            'Your account details and information',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the card displaying the user's avatar and greeting.
  Widget _buildProfileCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          // This makes the Column expand to the full width of the card.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The name is now hardcoded to 'John Smith'.
            Text(
              'Hello, John Smith!',
              // The text is centered within the expanded column.
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: CircleAvatar(
                radius: 50,
                // The profile picture URL has been updated.
                backgroundImage: NetworkImage('https://thehighlandcafe.github.io/hioswebcore/rewards/pics/avatar.jpg'),
                backgroundColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the card displaying the user's details.
  Widget _buildDetailsCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Details',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            // Reusable row widget for each detail item.
            _buildDetailRow(context, title: 'Name', value: 'John Smith'),
            const Divider(),
            _buildDetailRow(context, title: 'Email Address', value: 'example@email.com'),
            const Divider(),
            _buildDetailRow(context, title: 'Member Since', value: 'October, 2023'),
            const Divider(),
            _buildDetailRow(context, title: 'Points', value: '2,457'),
          ],
        ),
      ),
    );
  }

  /// Helper widget to create a consistent row for user details.
  Widget _buildDetailRow(BuildContext context, {required String title, required String value}) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}
