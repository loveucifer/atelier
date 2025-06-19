import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Return only the content, not a whole new Scaffold.
    // The Scaffold in MainScreen will handle the structure.
    return const Center(child: Text('Home Screen'));
  }
}