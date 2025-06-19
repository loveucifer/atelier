import 'package:atelier/widgets/common/glass_app_bar.dart';
import 'package:atelier/widgets/listings/listing_card.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Map<String, String>> _dummyListings = [
    {
      'title': 'Vintage Analog Synthesizer',
      'author': 'SynthGod',
      'price': '₹45,000',
      'imageUrl': 'https://images.unsplash.com/photo-1572199849349-583DE64a0b27?q=80&w=2940&auto=format&fit=crop',
    },
    {
      'title': 'Abstract Oil Painting "Cosmos"',
      'author': 'ArtByPriya',
      'price': '₹12,500',
      'imageUrl': 'https://images.unsplash.com/photo-1531826346122-303978317bad?q=80&w=2835&auto=format&fit=crop',
    },
    {
      'title': 'Handcrafted Leather Journal',
      'author': 'CraftyCorner',
      'price': '₹2,200',
      'imageUrl': 'https://images.unsplash.com/photo-1518621736915-f3b1c41bfd00?q=80&w=2894&auto=format&fit=crop',
    },
    {
      'title': 'Live Acoustic House Concert',
      'author': 'RohanMilton',
      'price': '₹1,500 / ticket',
      'imageUrl': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?q=80&w=2940&auto=format&fit=crop',
    },
     {
      'title': 'Minimalist Pottery Vase Set',
      'author': 'ClayCreations',
      'price': '₹3,800',
      'imageUrl': 'https://images.unsplash.com/photo-1565193566174-376663574242?q=80&w=2787&auto=format&fit=crop',
    },
    {
      'title': 'DJ for Private Events',
      'author': 'DJVibe',
      'price': '₹20,000 / night',
      'imageUrl': 'https://images.unsplash.com/photo-1516223725307-6d762b91a274?q=80&w=2787&auto=format&fit=crop',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const GlassAppBar(
        title: 'Atelier',
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90), 
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.7,
        ),
        itemCount: _dummyListings.length,
        itemBuilder: (context, index) {
          final listing = _dummyListings[index];
          // Pass the whole map to the card
          return ListingCard(listing: listing);
        },
      ),
    );
  }
}