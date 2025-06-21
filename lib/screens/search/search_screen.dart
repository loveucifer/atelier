import 'package:atelier/main.dart';
import 'package:atelier/screens/listings/listing_details_screen.dart';
import 'package:atelier/screens/profile/profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<Map<String, dynamic>> _allResults = [];
  bool _isLoading = false;

  // --- Data Fetching Logic (Unchanged) ---
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _allResults = [];
      });
      return;
    }
    setState(() { _isLoading = true; });

    try {
      final results = await supabase.rpc(
        'search_atelier',
        params: {'search_term': query.trim()},
      );
      if (mounted) {
        setState(() {
          _allResults = (results as List).cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error searching: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Helper method to build a section with a title and list of items ---
  Widget _buildSection(BuildContext context, String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 8.0, left: 16.0, right: 16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ...items, // Spread operator to insert list items
      ],
    );
  }

  // --- Helper method to build a single result tile ---
  Widget _buildResultTile(Map<String, dynamic> item) {
    final bool isUser = item['item_type'] == 'user';
    final listingData = isUser ? null : (item['data'] as Map).cast<String, dynamic>();
    
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
        backgroundImage: item['image_url'] != null ? CachedNetworkImageProvider(item['image_url']) : null,
        child: item['image_url'] == null ? Icon(isUser ? CupertinoIcons.person : CupertinoIcons.photo, color: Colors.grey) : null,
      ),
      title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(isUser ? '@${item['username']}' : (item['display_name'] ?? 'Listing')),
      trailing: const Icon(CupertinoIcons.chevron_right),
      onTap: () {
        // --- FIXED NAVIGATION LOGIC ---
        if (isUser) {
          // Navigate to the user's public profile page
          Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen(userId: item['id'])));
        } else {
          // Navigate to the listing details screen
          final fullListingData = {
            'id': listingData?['id'],
            'title': listingData?['title'],
            'author': item['display_name'],
            'price': listingData?['price_guide'],
            'imageUrl': item['image_url'],
            'user_id': listingData?['user_id'],
            'description': listingData?['description']
          };
          Navigator.push(context, MaterialPageRoute(builder: (context) => ListingDetailsScreen(listing: fullListingData)));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- SEPARATE RESULTS INTO CATEGORIES ---
    final userResults = _allResults.where((r) => r['item_type'] == 'user').toList();
    final productResults = _allResults.where((r) => r['item_type'] == 'listing' && (r['data'] as Map)['type'] == 'PRODUCT').toList();
    final serviceResults = _allResults.where((r) => r['item_type'] == 'listing' && (r['data'] as Map)['type'] == 'SERVICE').toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for items or creators...',
                prefixIcon: const Icon(CupertinoIcons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
              ),
              onChanged: _performSearch,
              onFieldSubmitted: _performSearch,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _allResults.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty
                              ? 'Start typing to search Atelier.'
                              : 'No results found for "${_searchController.text}"',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                      )
                    // --- Display Categorized Results ---
                    : ListView(
                        children: [
                          if (userResults.isNotEmpty)
                            _buildSection(context, 'Users', userResults.map((item) => _buildResultTile(item)).toList()),
                          if (productResults.isNotEmpty)
                            _buildSection(context, 'Products', productResults.map((item) => _buildResultTile(item)).toList()),
                          if (serviceResults.isNotEmpty)
                             _buildSection(context, 'Services', serviceResults.map((item) => _buildResultTile(item)).toList()),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}