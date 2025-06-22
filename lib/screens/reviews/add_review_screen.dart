// lib/screens/reviews/add_review_screen.dart

import 'package:atelier/main.dart';
import 'package:flutter/material.dart';

class AddReviewScreen extends StatefulWidget {
  final String revieweeId; // The ID of the user we are reviewing
  final String? listingId;

  const AddReviewScreen({
    super.key,
    required this.revieweeId,
    this.listingId,
  });

  @override
  State<AddReviewScreen> createState() => _AddReviewScreenState();
}

class _AddReviewScreenState extends State<AddReviewScreen> {
  final _contentController = TextEditingController();
  int _rating = 0;
  bool _isLoading = false;

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a star rating.'), backgroundColor: Colors.red));
      return;
    }
    setState(() { _isLoading = true; });

    try {
      final reviewerId = supabase.auth.currentUser!.id;
      if (reviewerId == widget.revieweeId) {
        throw Exception("You cannot review yourself.");
      }

      await supabase.from('reviews').insert({
        'reviewer_id': reviewerId,
        'reviewee_id': widget.revieweeId,
        'listing_id': widget.listingId,
        'rating': _rating,
        'content': _contentController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Thank you for your review!')));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error submitting review: $e'), backgroundColor: Colors.red));
      }
    }

    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    // The old BreathingGradientBackground is replaced with a standard Scaffold
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leave a Review'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Select your rating:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            // Star rating row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() { _rating = index + 1; });
                  },
                  icon: Icon(
                    index < _rating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 40,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            // Experience text field
            TextFormField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Share your experience (optional)',
                hintText: 'Describe your interaction with the user or their product...',
                alignLabelWithHint: true,
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 32),
            // Submit button
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitReview,
                    child: const Text('Submit Review'),
                  ),
          ],
        ),
      ),
    );
  }
}