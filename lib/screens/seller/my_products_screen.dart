// lib/screens/seller/my_products_screen.dart

import 'package:flutter/material.dart';
import '../../models/product_model.dart'; // Import our new Product model

class MyProductsScreen extends StatefulWidget {
  const MyProductsScreen({super.key});

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  // This is our list of dummy data.
  // In a future step, this list will be fetched from Supabase.
  final List<Product> _products = [
    Product(
      id: 1,
      title: 'Hand-painted Mandala Coasters',
      price: 499.00,
      imageUrl: 'https://i.etsystatic.com/23249119/r/il/649833/2791016895/il_794xN.2791016895_k357.jpg', // Placeholder image URL
      status: 'Available',
    ),
    Product(
      id: 2,
      title: 'Customized Resin Keychain',
      price: 250.50,
      imageUrl: 'https://i.etsystatic.com/26432014/r/il/a7b189/3141380927/il_794xN.3141380927_s1m8.jpg', // Placeholder image URL
      status: 'Available',
    ),
    Product(
      id: 3,
      title: 'Vintage Style Oil Painting',
      price: 3500.00,
      imageUrl: 'https://i.etsystatic.com/25899986/r/il/a587ce/3153591965/il_794xN.3153591965_9z5s.jpg', // Placeholder image URL
      status: 'Sold',
    ),
    Product(
      id: 4,
      title: 'Handmade Velvet Scrunchies (Set of 3)',
      price: 180.00,
      imageUrl: 'https://i.etsystatic.com/21654271/r/il/302863/2568289456/il_794xN.2568289456_s48a.jpg', // Placeholder image URL
      status: 'Available',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Scaffold provides the basic structure of a visual screen in Material Design.
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        // We can add actions to the app bar, like a search icon later.
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      // The body of our screen.
      body: ListView.builder(
        // The total number of items in our list.
        itemCount: _products.length,
        // The builder function is called for each item in the list.
        // It's very efficient for long lists.
        itemBuilder: (context, index) {
          final product = _products[index];
          // We'll use a Card for a nice, clean look for each list item.
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  // --- Product Image ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      product.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                       // Shows a loading indicator while the image loads.
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator());
                      },
                      // Shows an icon if the image fails to load.
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.image_not_supported, size: 80);
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0), // Spacing between image and text

                  // --- Product Details ---
                  // Expanded makes this column take up all remaining horizontal space.
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2, // Prevent long titles from overflowing
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          '₹${product.price.toStringAsFixed(2)}', // Format price to 2 decimal places
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        // --- Status Chip ---
                        Chip(
                          label: Text(
                            product.status,
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: product.status == 'Available'
                              ? Colors.green.shade600
                              : Colors.grey.shade600,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),

                  // --- Edit Button ---
                  // This is the menu button (three dots)
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      // TODO: Implement edit/delete functionality
                      print('Tapped on product ${product.id}');
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // FloatingActionButton is the circular button, typically at the bottom right.
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Navigate to the Add/Edit Product Screen
          print('Navigate to Add Product Screen');
        },
        label: const Text('Add Product'),
        icon: const Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}