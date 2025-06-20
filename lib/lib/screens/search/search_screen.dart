import 'package:atelier/main.dart';
import 'package:atelier/screens/listings/listing_details_screen.dart';
import 'package:atelier/widgets/common/glass_app_bar.dart';
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
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
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
          _results = (results as List).cast<Map<String, dynamic>>();
        });
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error searching: $e'), backgroundColor: Colors.red,));
      }
    }

    if(mounted) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const GlassAppBar(title: 'Search'),
      body: Padding(
        padding: const EdgeInsets.only(top: 100),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                onFieldSubmitted: _performSearch,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                      ? Center(
                          child: Text(
                            _searchController.text.isEmpty
                                ? 'Start typing to search Atelier.'
                                : 'No results found for "${_searchController.text}"',
                            style: const TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final item = _results[index];
                            final isListing = item['item_type'] == 'listing';

                            return Card(
                              color: Colors.white.withOpacity(0.05),
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                                onTap: () {
                                  if (isListing) {
                                    final listingData = (item['listing_data'] as Map).cast<String, dynamic>();
                                    
                                    // Re-construct the data map for the details screen
                                    final fullListingData = {
                                      'id': listingData['id'],
                                      'title': listingData['title'],
                                      'author': 'Creator', // This needs enhancement later by joining profiles
                                      'price': listingData['price_guide'],
                                      'imageUrl': item['image_url'],
                                      'user_id': listingData['user_id'],
                                      'description': listingData['description']
                                    };
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => ListingDetailsScreen(listing: fullListingData)));
                                  } else {
                                    // TODO: Navigate to the user's public profile page
                                  }
                                },
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.white10,
                                  backgroundImage: item['image_url'] != null 
                                    ? CachedNetworkImageProvider(item['image_url'])
                                    : null,
                                  child: item['image_url'] == null 
                                    ? Icon(isListing ? CupertinoIcons.photo : CupertinoIcons.person, color: Colors.white)
                                    : null,
                                ),
                                title: Text(item['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  isListing ? 'Listing' : 'Creator',
                                  style: TextStyle(color: isListing ? Theme.of(context).primaryColor : Colors.cyan, fontWeight: FontWeight.bold),
                                ),
                                trailing: const Icon(CupertinoIcons.right_chevron),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}