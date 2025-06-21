import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;

  const ReviewCard({super.key, required this.review});

  // Helper function to format time
  String timeAgo(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewer = review['reviewer'] as Map<String, dynamic>?;
    final reviewerName = reviewer?['display_name'] ?? 'Anonymous';
    final reviewerAvatar = reviewer?['avatar_url'];
    final rating = review['rating'] as int;
    final content = review['content'] as String?;
    final createdAt = DateTime.parse(review['created_at']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
              backgroundImage: reviewerAvatar != null ? CachedNetworkImageProvider(reviewerAvatar) : null,
              child: reviewerAvatar == null ? const Icon(CupertinoIcons.person, size: 20) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reviewerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(timeAgo(createdAt), style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (i) => Icon(
            i < rating ? Icons.star_rounded : Icons.star_border_rounded,
            color: Colors.amber, size: 20)
          ),
        ),
        const SizedBox(height: 8),
        if (content != null && content.isNotEmpty)
          Text(
            content,
            style: TextStyle(color: Colors.grey[800], fontSize: 15, height: 1.4),
          ),
        const SizedBox(height: 8),
        Row(
          children: [
             // For demonstration, these buttons don't do anything yet.
            IconButton(
              onPressed: (){},
              icon: Icon(CupertinoIcons.hand_thumbsup, size: 20, color: Theme.of(context).colorScheme.secondary),
              tooltip: 'Helpful',
            ),
            IconButton(
              onPressed: (){},
              icon: Icon(CupertinoIcons.hand_thumbsdown, size: 20, color: Theme.of(context).colorScheme.secondary),
              tooltip: 'Not Helpful',
            )
          ],
        )
      ],
    );
  }
}