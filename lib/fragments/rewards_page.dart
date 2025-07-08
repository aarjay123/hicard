import 'package:flutter/material.dart';

// A simple data model for a reward offer.
class _Offer {
  final String title;
  final String description;
  final String expiryInfo;
  final int? points; // Null for expired offers without a redeem button.

  // The constructor is now 'const' to allow for compile-time constant instantiation.
  const _Offer({
    required this.title,
    required this.description,
    required this.expiryInfo,
    this.points,
  });
}

// --- RewardsPage Fragment ---
// This widget displays the user's rewards, barcode, and available offers.
class RewardsPage extends StatelessWidget {
  const RewardsPage({Key? key}) : super(key: key);

  // --- Mock Data ---
  // In a real app, this data would come from an API.
  // Explicitly typing the list and using a const constructor for the objects.
  final List<_Offer> _activeOffers = const [
    _Offer(
      title: 'Summer 2025 Special Drinks Deal!',
      description: 'On this Summer 2025, make this summer special for you, with 5% off any small tea at any of our restaurants! Don\'t miss out though!',
      expiryInfo: 'Posted 18/05/2025 16:14, offer expires 25/05/2025 23:59',
      points: 1500,
    ),
  ];

  final List<_Offer> _expiredOffers = const [
    _Offer(
      title: 'HiRewards Overhaul 2024 Special Deal!',
      description: 'On this design overhaul of HiRewards 2024, make this year special, with 5% off a Small Tea at any HiCafe™ branch! Don\'t miss out though!',
      expiryInfo: 'Posted 31/08/2024 10:00, offer expired 24/09/2024 23:59',
    ),
    _Offer(
      title: 'HiRewards Opening 2023 Special Stay Deal!',
      description: 'On this opening of HiRewards 2023, make this year special, with 5% off any stay above 15 days at any SnugMotels, WorstEastern, or HotelComfy branch! Don\'t miss out though!',
      expiryInfo: 'Posted 20/10/2023 16:54, offer expired 31/10/2023 23:59',
    ),
  ];


  @override
  Widget build(BuildContext context) {
    // Using DefaultTabController to manage the state of the tabs.
    return DefaultTabController(
      length: 2, // The number of tabs
      child: Scaffold(
        body: SafeArea(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(child: _buildHeader(context)),
                SliverToBoxAdapter(child: _buildBarcodeCard(context)),
                SliverPersistentHeader(
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      labelColor: Theme.of(context).colorScheme.onPrimary,
                      unselectedLabelColor: Theme.of(context).colorScheme.primary,
                      indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: const [
                        Tab(text: 'Active'),
                        Tab(text: 'Expired'),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              children: [
                _buildOfferList(_activeOffers),
                _buildOfferList(_expiredOffers),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the main header for the page, styled like the HomePage.
  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 16.0),
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
              'Your Rewards',
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            'View your offers and barcode',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the card displaying the user's barcode.
  Widget _buildBarcodeCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        color: colorScheme.secondaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                'Your Barcode',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(height: 16),
              Icon(Icons.qr_code_2_rounded, size: 150, color: colorScheme.onSecondaryContainer),
              const SizedBox(height: 16),
              Text(
                'Please scan this at checkout',
                style: TextStyle(color: colorScheme.onSecondaryContainer),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a list of offer cards from a list of [_Offer] objects.
  Widget _buildOfferList(List<_Offer> offers) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: offers.length,
      itemBuilder: (context, index) {
        final offer = offers[index];
        final colorScheme = Theme.of(context).colorScheme;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          color: colorScheme.surfaceVariant, // Using a slightly different color for offer cards
          margin: const EdgeInsets.only(bottom: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  offer.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  offer.expiryInfo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                  ),
                ),
                if (offer.points != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Scan the QR code on the homepage to redeem.'),
                            // The behavior is now fixed to avoid layout issues with the FAB and BottomNavBar.
                            // The 'floating' behavior was conflicting with the Scaffold's other bottom widgets.
                            behavior: SnackBarBehavior.fixed,
                          ),
                        );
                      },
                      child: Text('${offer.points} Points - Redeem'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }
}

// A custom delegate to make the TabBar stick to the top when scrolling.
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this.tabBar);

  final TabBar tabBar;

  @override
  double get minExtent => tabBar.preferredSize.height + 16;
  @override
  double get maxExtent => tabBar.preferredSize.height + 16;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(50),
        ),
        child: tabBar,
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
