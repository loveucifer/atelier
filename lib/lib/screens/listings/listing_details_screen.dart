import 'package:atelier/main.dart';
import 'package:atelier/screens/messaging/chat_screen.dart';
import 'package:atelier/screens/reviews/add_review_screen.dart';
import 'package:atelier/widgets/common/glass_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ListingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> listing;

  const ListingDetailsScreen({super.key, required this.listing});

  Future<void> _startConversation(BuildContext context) async {
    final otherUserId = listing['user_id'];
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
              otherUserName: listing['author'] ?? 'User',
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
    final title = listing['title'] as String? ?? 'Listing';
    final authorName = listing['author'] as String? ?? 'User';
    final price = '₹${listing['price']?.toString() ?? '0'}';
    final imageUrl = listing['imageUrl'] as String? ?? '';
    final description = listing['description'] as String? ?? 'No description provided.';
    final revieweeId = listing['user_id'] as String;
    final listingId = listing['id'] as String?;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(title: title),
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
                  Text('by $authorName', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[400])),
                  const SizedBox(height: 16),
                  Text(price, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                  const Divider(height: 40, color: Colors.white24),
                  const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  Text(description, style: TextStyle(color: Colors.grey[300], fontSize: 16, height: 1.5)),
                  const SizedBox(height: 24),
                  if (revieweeId != supabase.auth.currentUser!.id)
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