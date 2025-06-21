import 'package:atelier/screens/listings/listing_details_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ListingCard extends StatelessWidget {
  final Map<String, dynamic> listing;

  const ListingCard({
    super.key,
    required this.listing,
  });

  @override
  Widget build(BuildContext context) {
    // Safely extract data from the map
    final title = listing['title'] as String? ?? 'No Title';
    final author = listing['author'] as String? ?? 'Unknown Artist';
    // Using a placeholder for price as per the new design
    final price = '₹${listing['price']?.toString() ?? '0.00'}'; 
    final imageUrl = listing['imageUrl'] as String? ?? '';

    return GestureDetector(
      onTap: () {
        // This navigation logic is preserved
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListingDetailsScreen(listing: listing),
          ),
        );
      },
      // The old GlassmorphicContainer is replaced with a simple Column
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image container with rounded corners
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                // Placeholder while the image is loading
                placeholder: (context, url) => Container(
                  color: Theme.of(context).inputDecorationTheme.fillColor,
                ),
                // Widget to display if the image fails to load
                errorWidget: (context, url, error) => Container(
                  color: Theme.of(context).inputDecorationTheme.fillColor,
                  child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Text content with updated styling
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            'by $author',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 14
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price, // Example: "$12.99 - $15.99"
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}