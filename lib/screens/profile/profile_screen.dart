import 'package:atelier/main.dart';
import 'package:atelier/widgets/common/glass_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _getProfile();
  }

  Future<Map<String, dynamic>> _getProfile() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase.from('profiles').select().eq('id', userId).single();
    return data;
  }

  String _calculateTrustScore(Map<String, dynamic> profile) {
    return profile['is_verified'] == true ? '100%' : '50%';
  }

  @override
  Widget build(BuildContext context) {
    // We need to extend the body behind the app bar for the blur to work
    return Scaffold(
      extendBodyBehindAppBar: true, 
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        title: 'Profile',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () { /* TODO: Navigate to Edit Profile screen */ },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await supabase.auth.signOut();
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Could not load profile"));
          }

          final profile = snapshot.data!;
          final avatarUrl = profile['avatar_url'];

          // Add a top padding to the ListView to avoid content going under the custom AppBar
          return Padding(
            padding: EdgeInsets.only(top: preferredSize.height + 20),
            child: RefreshIndicator(
              onRefresh: () async {
                setState(() { _profileFuture = _getProfile(); });
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  // ... ALL your existing profile content (CircleAvatar, Text, etc.) goes here
                  // The code from the previous version is unchanged.
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  // Expose the app bar's preferred size for padding calculation
  Size get preferredSize => const Size(double.infinity, 80);
}