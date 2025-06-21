import 'package:atelier/main.dart';
import 'package:atelier/widgets/listings/listing_card.dart';
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

  Future<List<Map<String, dynamic>>> _fetchListings() async {
    // Fetch the listing data and the creator's profile data in a single query
    final response = await supabase
        .from('listings')
        .select('*, profiles(display_name)') 
        .order('created_at', ascending: false);
    return response;
  }

  Future<void> _refreshListings() async {
    setState(() {
      _listingsFuture = _fetchListings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _listingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No listings yet.\nBe the first to create one!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final listings = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refreshListings,
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.7,
              ),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final listing = listings[index];
                final imageUrls = listing['image_urls'] as List?;
                final imageUrl = (imageUrls != null && imageUrls.isNotEmpty)
                  ? imageUrls[0] as String
                  : 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?q=80&w=2845&auto=format&fit=crop';
                final authorName = (listing['profiles'] as Map?)?['display_name'] ?? 'Unknown Artist';
                
                // Create the map that will be passed to both the ListingCard and the DetailsScreen
                final listingDataForCard = {
                  'title': listing['title'],
                  'author': authorName,
                  'price': listing['price_guide'],
                  'imageUrl': imageUrl,
                  'user_id': listing['user_id'], // Pass user_id for messaging
                  'description': listing['description'] // Pass description for details page
                };
                
                // Pass the prepared map directly to the card
                return ListingCard(listing: listingDataForCard);
              },
            ),
          );
        },
      ),
    );
  }
}