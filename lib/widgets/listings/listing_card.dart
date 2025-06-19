import 'package:atelier/screens/listings/listing_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class ListingCard extends StatelessWidget {
  // Pass the whole listing map now
  final Map<String, String> listing;

  const ListingCard({
    super.key,
    required this.listing,
  });

  @override
  Widget build(BuildContext context) {
    // Wrap the card with GestureDetector to make it tappable
    return GestureDetector(
      onTap: () {
        // Navigate to the details screen, passing the listing data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListingDetailsScreen(listing: listing),
          ),
        );
      },
      child: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: listing['imageUrl']!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(color: Colors.black26),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing['title']!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by ${listing['author']!}',
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      listing['price']!,
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}