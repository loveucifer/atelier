import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  const AnimatedGradientBackground({super.key, required this.child});

  @override
  State<AnimatedGradientBackground> createState() => _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground> {
  // Define the colors for our gradient, inspired by your image
  List<Color> colorList = [
    const Color(0xFFB71C1C), // Darker Red
    const Color(0xFF000000), // Pitch Black
    const Color(0xFFD32F2F), // Brighter Red
    const Color(0xFF1A1A1A), // Dark Grey
  ];
  
  // These control the alignment and therefore the "position" of the gradient
  List<Alignment> alignmentList = [
    Alignment.topLeft,
    Alignment.topRight,
    Alignment.bottomLeft,
    Alignment.bottomRight,
  ];

  int index = 0;
  // Start with a specific color set and alignment
  Color bottomColor = const Color(0xFFB71C1C);
  Color topColor = const Color(0xFF000000);
  Alignment begin = Alignment.bottomLeft;
  Alignment end = Alignment.topRight;

  @override
  void initState() {
    super.initState();
    // Use a timer to periodically change the gradient's properties
    Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          bottomColor = colorList[index % colorList.length];
          topColor = colorList[(index + 1) % colorList.length];
          begin = alignmentList[index % alignmentList.length];
          end = alignmentList[(index + 2) % alignmentList.length];
        });
        index++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The animated gradient layer
        AnimatedContainer(
          duration: const Duration(seconds: 3), // Duration for the color/alignment transition
          onEnd: () {
            // Optional: can trigger something when animation ends
          },
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: begin, // Animate the center point
              radius: 1.5,   // Make the gradient large
              colors: [bottomColor, topColor],
            ),
          ),
        ),
        // A subtle noise/texture overlay for a more organic feel
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/noise.png'), // You'll need to add this asset
              fit: BoxFit.cover,
              opacity: 0.03,
            ),
          ),
        ),
        // The actual content of the screen
        widget.child,
      ],
    );
  }
}