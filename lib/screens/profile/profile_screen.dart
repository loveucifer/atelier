import 'package:atelier/main.dart';
import 'package:atelier/screens/profile/edit_profile_screen.dart';
import 'package:atelier/screens/listings/listing_details_screen.dart';
import 'package:atelier/widgets/reviews/review_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// A helper type to make the return type of _fetchProfileData clearer
typedef ProfileData = (Map<String, dynamic> profile, List<Map<String, dynamic>> listings, List<Map<String, dynamic>> reviews);

class ProfileScreen extends StatefulWidget {
  final String? userId;
  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ProfileData> _profileFuture;
  late final String _userIdToFetch;

  @override
  void initState() {
    super.initState();
    _userIdToFetch = widget.userId ?? supabase.auth.currentUser!.id;
    _profileFuture = _fetchProfileData();
  }

  // Data fetching logic is preserved
  Future<ProfileData> _fetchProfileData() async {
    final profileFuture = supabase.from('profiles').select().eq('id', _userIdToFetch).single();
    final listingsFuture = supabase.from('listings').select().eq('user_id', _userIdToFetch).order('created_at');
    final reviewsFuture = supabase.from('reviews').select('*, reviewer:reviewer_id(display_name, avatar_url)').eq('reviewee_id', _userIdToFetch).order('created_at', ascending: false);

    final results = await Future.wait([profileFuture, listingsFuture, reviewsFuture]);

    final profile = results[0] as Map<String, dynamic>;
    final listings = (results[1] as List).cast<Map<String, dynamic>>();
    final reviews = (results[2] as List).cast<Map<String, dynamic>>();

    return (profile, listings, reviews);
  }

  // Trust score calculation is preserved
  double _calculateTrustScore(List<Map<String, dynamic>> reviews) {
    if (reviews.isEmpty) return 0.0;
    double totalRating = 0;
    for (var review in reviews) {
      totalRating += (review['rating'] as int);
    }
    return (totalRating / reviews.length) / 5.0; // Returns a value between 0.0 and 1.0
  }

  Future<void> _refreshData() async {
    setState(() { _profileFuture = _fetchProfileData(); });
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = widget.userId == null || widget.userId == supabase.auth.currentUser!.id;

    return Scaffold(
      appBar: AppBar(
        // The back button will automatically appear if this screen is pushed on the stack
        title: Text(isCurrentUser ? 'Profile' : 'User Profile'),
        actions: [
          if (isCurrentUser)
            IconButton(
              icon: const Icon(Icons.logout_outlined),
              tooltip: 'Logout',
              onPressed: () async {
                await supabase.auth.signOut();
              },
            ),
        ],
      ),
      body: FutureBuilder<ProfileData>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("Could not load profile"));
          }

          final (profile, listings, reviews) = snapshot.data!;
          final avatarUrl = profile['avatar_url'];
          final trustScore = _calculateTrustScore(reviews);

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                const SizedBox(height: 20),
                // --- Profile Header ---
                Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
                      backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? CachedNetworkImageProvider(avatarUrl) : null,
                      child: (avatarUrl == null || avatarUrl.isEmpty) ? Icon(CupertinoIcons.person_fill, size: 50, color: Colors.grey.shade400) : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      profile['display_name'] ?? 'No Name',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${profile['username'] ?? 'nousername'}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    if (isCurrentUser)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                             Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())).then((_) => _refreshData());
                          },
                          child: const Text('Edit Info'),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // --- Trust Score Section ---
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(12)
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       const Text('Trust Score', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                       const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: trustScore,
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                        ),
                        const SizedBox(height: 4),
                        Text('${(trustScore * 100).toStringAsFixed(0)}% Good', style: TextStyle(color: Colors.grey[600]),),
                    ],
                  ),
                ),

                const Divider(height: 48),

                // --- Listings Section ---
                Text('Listings (${listings.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                 listings.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(isCurrentUser ? "You haven't created any listings yet." : "This user has no listings.", style: TextStyle(color: Colors.grey[600])),
                    )
                  : Column(
                      children: listings.map((listing) {
                        final imageUrls = listing['image_urls'] as List?;
                        final imageUrl = (imageUrls != null && imageUrls.isNotEmpty) ? imageUrls[0] as String : '';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedNetworkImage(imageUrl: imageUrl, width: 56, height: 56, fit: BoxFit.cover),
                            ),
                            title: Text(listing['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('₹${listing['price_guide']}'),
                            trailing: const Icon(CupertinoIcons.chevron_right),
                            onTap: () {
                              final listingData = {
                                  'id': listing['id'],
                                  'title': listing['title'],
                                  'author': profile['display_name'],
                                  'price': listing['price_guide'],
                                  'imageUrl': imageUrl,
                                  'user_id': listing['user_id'],
                                  'description': listing['description']
                                };
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ListingDetailsScreen(listing: listingData)));
                            },
                          ),
                        );
                      }).toList(),
                  ),
                  
                const Divider(height: 48),

                // --- Reviews Section ---
                Text('Reviews Received (${reviews.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                 reviews.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text("No reviews yet.", style: TextStyle(color: Colors.grey[600])),
                    )
                  : Column(
                      children: reviews.map((review) => Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: ReviewCard(review: review),
                      )).toList(),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}