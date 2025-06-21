import 'package:atelier/main.dart';
import 'package:atelier/screens/messaging/chat_screen.dart';
import 'package:atelier/screens/profile/profile_screen.dart';
import 'package:atelier/screens/reviews/add_review_screen.dart';
import 'package:atelier/widgets/common/glass_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ListingDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> listing;
  const ListingDetailsScreen({super.key, required this.listing});

  @override
  State<ListingDetailsScreen> createState() => _ListingDetailsScreenState();
}

class _ListingDetailsScreenState extends State<ListingDetailsScreen> {
  bool _isFavorited = false;
  bool _isLoadingFavorite = true;

  @override
  void initState() {
    super.initState();
    // Only check favorites if the listing has an ID (i.e., it's a real listing)
    if (widget.listing['id'] != null) {
      _checkIfFavorited();
    } else {
      _isLoadingFavorite = false;
    }
  }

  Future<void> _checkIfFavorited() async {
    try {
      final userId = supabase.auth.currentUser!.id;
      final listingId = widget.listing['id'];
      if (listingId == null) return;

      final response = await supabase
          .from('favorites')
          .select()
          .eq('user_id', userId)
          .eq('listing_id', listingId)
          .limit(1);

      if (mounted) {
        setState(() {
          _isFavorited = response.isNotEmpty;
          _isLoadingFavorite = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFavorite = false;
        });
        // Optionally show an error message
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (widget.listing['id'] == null) return;
    setState(() { _isLoadingFavorite = true; });

    final userId = supabase.auth.currentUser!.id;
    final listingId = widget.listing['id'];

    try {
      if (_isFavorited) {
        // Unfavorite: Delete the row
        await supabase.from('favorites').delete().match({'user_id': userId, 'listing_id': listingId});
      } else {
        // Favorite: Insert a new row
        await supabase.from('favorites').insert({'user_id': userId, 'listing_id': listingId});
      }
      if (mounted) {
        await _checkIfFavorited(); // Re-check the status
      }
    } catch (e) {
      if (mounted) setState(() { _isLoadingFavorite = false; });
    }
  }

  Future<void> _startConversation(BuildContext context) async {
    final otherUserId = widget.listing['user_id'];
    if (otherUserId == supabase.auth.currentUser!.id) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("You can't message yourself.")));
      return;
    }

    try {
      final conversationId = await supabase.rpc(
        'create_conversation_and_get_id',
        params: {'other_user_id': otherUserId},
      );
      
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              conversationId: conversationId,
              otherUserName: widget.listing['author'] ?? 'User',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting conversation: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.listing['title'] as String? ?? 'Listing';
    final authorName = widget.listing['author'] as String? ?? 'User';
    final authorId = widget.listing['user_id'] as String?;
    final price = '₹${widget.listing['price']?.toString() ?? '0'}';
    final imageUrl = widget.listing['imageUrl'] as String? ?? '';
    final description = widget.listing['description'] as String? ?? 'No description provided.';
    final revieweeId = widget.listing['user_id'] as String?;
    final listingId = widget.listing['id'] as String?;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        title: title,
        actions: [
          if (listingId != null && revieweeId != supabase.auth.currentUser!.id)
            _isLoadingFavorite
              ? const Padding(padding: EdgeInsets.all(12.0), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white,)))
              : IconButton(
                  icon: Icon(
                    _isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorited ? Theme.of(context).primaryColor : Colors.white,
                    size: 28,
                  ),
                  onPressed: _toggleFavorite,
                ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              height: MediaQuery.of(context).size.height * 0.5,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  if (authorId != null)
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => ProfileScreen(userId: authorId),
                        ));
                      },
                      child: Text('by $authorName', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[400])),
                    )
                  else
                    Text('by $authorName', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[400])),
                  const SizedBox(height: 16),
                  Text(price, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                  const Divider(height: 40, color: Colors.white24),
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  Text(description, style: TextStyle(color: Colors.grey[300], fontSize: 16, height: 1.5)),
                  const SizedBox(height: 24),
                  if (revieweeId != null && revieweeId != supabase.auth.currentUser!.id)
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AddReviewScreen(revieweeId: revieweeId, listingId: listingId)));
                      },
                      icon: const Icon(Icons.rate_review_outlined),
                      label: const Text('Leave a Review for this User'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
          onPressed: () => _startConversation(context),
          child: const Text('Message User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}