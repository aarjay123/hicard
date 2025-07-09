import 'package:flutter/material.dart';

// --- PayPage Fragment ---
// This widget provides the interface for contactless payments.
class PayPage extends StatelessWidget {
  const PayPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                _buildCardImage(context),
                const SizedBox(height: 16),
                _buildInstructionsCard(context),
                const SizedBox(height: 16),
                _buildInfoCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the main header for the page, styled like the other fragments.
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
              'Pay',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            'Use your HiCard for payments',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the card displaying the HiCard image.
  Widget _buildCardImage(BuildContext context) {
    // In a real app, you would replace this with your local asset.
    // For example: Image.asset('assets/images/hicard.png')
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      clipBehavior: Clip.antiAlias, // Ensures the image respects the border radius.
      child: Image.network(
        'https://thehighlandcafe.github.io/hioswebcore/rewards/pics/hicard.png',
        fit: BoxFit.cover,
        // Shows a loading indicator while the network image is loading.
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const AspectRatio(
            aspectRatio: 600 / 375,
            child: Center(child: CircularProgressIndicator()),
          );
        },
        // Shows an error icon if the image fails to load.
        errorBuilder: (context, error, stackTrace) {
          return const AspectRatio(
            aspectRatio: 600 / 375,
            child: Center(child: Icon(Icons.credit_card_off_rounded, size: 48)),
          );
        },
      ),
    );
  }

  /// Builds the card with NFC payment instructions.
  Widget _buildInstructionsCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(
              'Your HiCard',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap your phone on the contactless payment terminal to pay.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSecondaryContainer),
            ),
            const SizedBox(height: 24),
            Icon(Icons.nfc_rounded, size: 120, color: colorScheme.onSecondaryContainer),
          ],
        ),
      ),
    );
  }

  /// Builds the informational card at the bottom.
  Widget _buildInfoCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      color: colorScheme.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.info_outline_rounded, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'You need NFC to be switched on to use your HiCard. You also need enough money in your account for each transaction.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
