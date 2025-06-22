import 'package:atelier/main.dart';
import 'package:atelier/widgets/listings/listing_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Map<String, dynamic>>> _listingsFuture;

  @override
  void initState() {
    super.initState();
    _listingsFuture = _fetchListings();
  }

  // Data fetching logic remains the same
  Future<List<Map<String, dynamic>>> _fetchListings() async {
    final response = await supabase
        .from('listings')
        .select('*, profiles(display_name)')
        .order('created_at', ascending: false);
    return response;
  }

  // Refresh logic remains the same
  Future<void> _refreshListings() async {
    setState(() {
      _listingsFuture = _fetchListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    // We use a standard Scaffold now, no custom backgrounds.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement cart functionality or other actions.
            },
            icon: const Icon(CupertinoIcons.shopping_cart),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshListings,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _listingsFuture,
          builder: (context, snapshot) {
            // Logic for handling different connection states is preserved.
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'No listings yet.\nBe the first to create one!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                ),
              );
            }

            final listings = snapshot.data!;
            // The GridView is updated to match the new design's layout.
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24, // Increased spacing for the new design
                childAspectRatio: 0.65, // Adjusted aspect ratio for the taller card
              ),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final listing = listings[index];
                // Data mapping logic is preserved.
                final imageUrls = listing['image_urls'] as List?;
                final imageUrl = (imageUrls != null && imageUrls.isNotEmpty)
                    ? imageUrls[0] as String
                    : ''; // Default to an empty string for no image
                final authorName = (listing['profiles'] as Map?)?['display_name'] ?? 'Unknown Artist';

                final listingDataForCard = {
                  'id': listing['id'],
                  'title': listing['title'],
                  'author': authorName,
                  'price': listing['price_guide'],
                  'imageUrl': imageUrl,
                  'user_id': listing['user_id'],
                  'description': listing['description']
                };

                // We now use the new, refactored ListingCard.
                return ListingCard(listing: listingDataForCard);
              },
            );
          },
        ),
      ),
    );
  }
}