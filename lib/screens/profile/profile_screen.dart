import 'dart:ui';
import 'package:atelier/main.dart';
import 'package:atelier/screens/profile/edit_profile_screen.dart';
import 'package:atelier/screens/profile/verification_screen.dart';
import 'package:atelier/widgets/listings/listing_card.dart';
import 'package:atelier/widgets/reviews/review_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

// A helper type to make the return type of _fetchProfileData clearer
typedef ProfileData = (Map<String, dynamic> profile, List<Map<String, dynamic>> listings, List<Map<String, dynamic>> reviews);

class ProfileScreen extends StatefulWidget {
  // This allows us to pass a specific user's ID to the screen
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
    // If a userId is passed to the widget, use it. Otherwise, use the current user's ID.
    _userIdToFetch = widget.userId ?? supabase.auth.currentUser!.id;
    _profileFuture = _fetchProfileData();
  }

  // Fetches all data for the specified user profile
  Future<ProfileData> _fetchProfileData() async {
    final profileFuture = supabase.from('profiles').select().eq('id', _userIdToFetch).single();
    final listingsFuture = supabase.from('listings').select('*, profiles(display_name)').eq('user_id', _userIdToFetch).order('created_at');
    final reviewsFuture = supabase.from('reviews').select('*, reviewer:reviewer_id(display_name, avatar_url)').eq('reviewee_id', _userIdToFetch).order('created_at', ascending: false);
    
    final results = await Future.wait([profileFuture, listingsFuture, reviewsFuture]);

    final profile = results[0] as Map<String, dynamic>;
    final listings = (results[1] as List).cast<Map<String, dynamic>>();
    final reviews = (results[2] as List).cast<Map<String, dynamic>>();

    return (profile, listings, reviews);
  }
  
  // Calculates a user's trust score based on their review ratings
  String _calculateTrustScore(List<Map<String, dynamic>> reviews) {
    if (reviews.isEmpty) return 'New User';
    double totalRating = 0;
    for (var review in reviews) {
      totalRating += (review['rating'] as int);
    }
    double averageRating = totalRating / reviews.length;
    return '${(averageRating / 5 * 100).toStringAsFixed(0)}%';
  }

  // Allows for pull-to-refresh functionality
  Future<void> _refreshData() async {
    setState(() { _profileFuture = _fetchProfileData(); });
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the profile being viewed belongs to the currently logged-in user
    final isCurrentUser = widget.userId == null || widget.userId == supabase.auth.currentUser!.id;

    return Scaffold(
      backgroundColor: Colors.transparent,
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
          final isVerified = profile['is_verified'] as bool? ?? false;

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: _refreshData,
                child: CustomScrollView(
                  slivers: [
                    // --- Profile Header Section ---
                    SliverPadding(
                      padding: const EdgeInsets.only(top: 100, left: 16, right: 16),
                      sliver: SliverToBoxAdapter(
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey.shade800,
                              backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) ? CachedNetworkImageProvider(avatarUrl) : null,
                              child: (avatarUrl == null || avatarUrl.isEmpty) ? const Icon(CupertinoIcons.person_fill, size: 50, color: Colors.white) : null,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(profile['display_name'] ?? 'No Name', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                                if(isVerified) const SizedBox(width: 8),
                                if(isVerified) Icon(Icons.verified, color: Theme.of(context).primaryColor, size: 24),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('@${profile['username'] ?? 'nousername'}', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey)),
                            const SizedBox(height: 16),
                            Text(
                              profile['bio'] ?? (isCurrentUser ? 'No bio yet. Tap the edit button to add one!' : 'No bio yet.'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // --- Trust & Verification Section ---
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(children: [
                          const Divider(color: Colors.white24),
                          // Only show the "Get Verified" button to the profile owner
                          if (isCurrentUser && !isVerified)
                            ListTile(
                              leading: Icon(Icons.shield_outlined, color: Theme.of(context).primaryColor),
                              title: const Text('Get Verified'),
                              subtitle: const Text('Boost your trust score by verifying your identity.'),
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const VerificationScreen())).then((_) => _refreshData());
                              },
                            ),
                          ListTile(
                            leading: const Icon(CupertinoIcons.star_circle),
                            title: const Text('Trust Score'),
                            trailing: Text(_calculateTrustScore(reviews), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                          const Divider(color: Colors.white24),
                        ]),
                      ),
                    ),
                    // --- User's Listings Section ---
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('User Listings (${listings.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    listings.isEmpty
                        ? SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(isCurrentUser ? "You haven't created any listings yet." : "This user hasn't created any listings yet."))))
                        : SliverPadding(
                            padding: const EdgeInsets.all(16),
                            sliver: SliverGrid(
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.7,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final listing = listings[index];
                                  final imageUrls = listing['image_urls'] as List?;
                                  final imageUrl = (imageUrls != null && imageUrls.isNotEmpty)
                                      ? imageUrls[0] as String
                                      : 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?q=80&w=2845&auto=format&fit=crop';
                                  final authorName = (listing['profiles'] as Map?)?['display_name'] ?? 'Unknown Artist';
                                  final listingData = {
                                    'id': listing['id'],
                                    'title': listing['title'],
                                    'author': authorName,
                                    'price': listing['price_guide'],
                                    'imageUrl': imageUrl,
                                    'user_id': listing['user_id'],
                                    'description': listing['description']
                                  };
                                  return ListingCard(listing: listingData);
                                },
                                childCount: listings.length,
                              ),
                            ),
                          ),
                    // --- Reviews Section ---
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Reviews Received (${reviews.length})', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    reviews.isEmpty
                        ? const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text("No reviews yet."))))
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                  child: ReviewCard(review: reviews[index]),
                                );
                              },
                              childCount: reviews.length,
                            ),
                          ),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 90)),
                  ],
                ),
              ),
              // --- Edit and Logout Buttons ---
              // Only show these buttons if the current user is viewing their own profile
              if (isCurrentUser)
                Positioned(
                  top: 50,
                  right: 16,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen())).then((_) => _refreshData());
                        },
                        child: GlassmorphicContainer(
                          width: 45, height: 45, borderRadius: 22.5, blur: 20,
                          alignment: Alignment.center, border: 1,
                          linearGradient: LinearGradient(colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderGradient: LinearGradient(colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          child: const Icon(Icons.edit_outlined, color: Colors.white, size: 22),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () async {
                          await supabase.auth.signOut();
                          // The auth stream listener in main.dart will handle navigation
                        },
                        child: GlassmorphicContainer(
                          width: 45, height: 45, borderRadius: 22.5, blur: 20,
                          alignment: Alignment.center, border: 1,
                          linearGradient: LinearGradient(colors: [Colors.white.withOpacity(0.2), Colors.white.withOpacity(0.1)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          borderGradient: LinearGradient(colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.2)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          child: const Icon(Icons.logout, color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                )
            ],
          );
        },
      ),
    );
  }
}