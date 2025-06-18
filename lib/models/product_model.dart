// lib/models/product_model.dart

class Product {
  final int id;
  final String title;
  final double price;
  final String imageUrl;
  final String status; // 'Available' or 'Sold'

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.status,
  });
}