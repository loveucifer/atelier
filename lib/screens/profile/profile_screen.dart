import 'package:atelier/main.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // A Future to hold the profile data. This prevents re-fetching on every rebuild.
  late final Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _getProfile();
  }

  // Asynchronous function to fetch profile data from Supabase
  Future<Map<String, dynamic>> _getProfile() async {
    // Get the current user's ID
    final userId = supabase.auth.currentUser!.id;
    // Fetch the profile row where the 'id' matches the current user's ID
    final data = await supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single(); // .single() expects exactly one row, which is perfect for a profile
    return data;
  }

  // Simple Trust Score calculation based on the project document
  String _calculateTrustScore(Map<String, dynamic> profile) {
      // Placeholder logic: 100 if verified, 50 otherwise.
      // This will be expanded later with review counts and other metrics.
      return profile['is_verified'] ? '100%' : '50%';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // TODO: Navigate to Edit Profile screen
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Sign out the user
              await supabase.auth.signOut();
              // The StreamBuilder in main.dart will automatically navigate to LoginScreen
            },
          ),
        ],
      ),
      // FutureBuilder handles the asynchronous loading of data
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          // Show a loading spinner while data is being fetched
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Show an error message if something went wrong
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // If there's no data, show a message (shouldn't happen if sign-up trigger works)
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Could not load profile"));
          }

          // If data is loaded successfully, display it
          final profile = snapshot.data!;
          final avatarUrl = profile['avatar_url'];

          return RefreshIndicator(
            onRefresh: () async {
                // Allows user to pull down to refresh their profile data
                setState(() {
                    _profileFuture = _getProfile();
                });
            },
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade800,
                      backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) 
                          ? CachedNetworkImageProvider(avatarUrl) 
                          : null,
                      child: (avatarUrl == null || avatarUrl.isEmpty) 
                          ? const Icon(CupertinoIcons.person_fill, size: 50, color: Colors.white)
                          : null,
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
                    // Conditionally show the "Verified" badge
                     if (profile['is_verified'] == true) ...[
                        const SizedBox(height: 8),
                        Chip(
                          avatar: Icon(Icons.verified, color: Theme.of(context).primaryColor, size: 16),
                          label: Text('Verified', style: TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          side: BorderSide.none,
                        ),
                     ],
                    const SizedBox(height: 16),
                    Text(
                      profile['bio'] ?? 'No bio yet. Tap the edit button to add one!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5, color: Colors.grey[400]),
                    ),
                  ],
                ),
                const Divider(height: 40),
                ListTile(
                  leading: const Icon(CupertinoIcons.shield_fill),
                  title: const Text('Trust Score'),
                  trailing: Text(
                    _calculateTrustScore(profile),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(CupertinoIcons.star_fill),
                  title: const Text('Ratings & Reviews'),
                  trailing: const Icon(CupertinoIcons.right_chevron),
                  onTap: () {}, // TODO: Navigate to reviews screen
                ),
                const Divider(height: 30),
                 ListTile(
                  leading: const Icon(Icons.workspace_premium),
                  title: const Text('Promotional Tools'),
                  trailing: const Icon(CupertinoIcons.right_chevron),
                  onTap: () {}, // TODO: Navigate to monetization screen
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}