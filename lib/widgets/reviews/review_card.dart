import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:intl/intl.dart';

class ReviewCard extends StatelessWidget {
  final Map<String, dynamic> review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final reviewer = review['reviewer'] as Map<String, dynamic>?;
    final reviewerName = reviewer?['display_name'] ?? 'Anonymous';
    final reviewerAvatar = reviewer?['avatar_url'];
    final rating = review['rating'] as int;
    final content = review['content'] as String?;
    final createdAt = DateTime.parse(review['created_at']);

    return GlassmorphicContainer(
      width: double.infinity,
      height: 120, // A fixed height can work well in a list
      borderRadius: 16,
      blur: 20,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Theme.of(context).colorScheme.surface.withOpacity(0.2),
          Theme.of(context).colorScheme.surface.withOpacity(0.1),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.3),
          Colors.white.withOpacity(0.2),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white10,
                  backgroundImage: reviewerAvatar != null ? CachedNetworkImageProvider(reviewerAvatar) : null,
                  child: reviewerAvatar == null ? const Icon(CupertinoIcons.person, size: 20,) : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reviewerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        children: List.generate(5, (i) => Icon(
                          i < rating ? Icons.star_rounded : Icons.star_border_rounded,
                          color: Colors.amber, size: 18)
                        ),
                      ),
                    ],
                  ),
                ),
                Text(DateFormat.yMMMd().format(createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const Spacer(),
            if (content != null && content.isNotEmpty)
              Text(
                content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[300]),
              ),
          ],
        ),
      ),
    );
  }
}