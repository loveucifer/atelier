import 'package:flutter/material.dart';

class PulsatingGradientBackground extends StatefulWidget {
  final Widget child;
  const PulsatingGradientBackground({super.key, required this.child});

  @override
  State<PulsatingGradientBackground> createState() => _PulsatingGradientBackgroundState();
}

class _PulsatingGradientBackgroundState extends State<PulsatingGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8), // Slowed down for a calmer effect
    );

    // Animate the radius of the gradient from small to large
    _animation = Tween<double>(begin: 0.7, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // This makes the animation loop forever
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Use an AnimatedBuilder for a performance-optimized animation
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                // New black and white gradient
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: _animation.value, // The radius is animated
                  colors: const [
                    Color(0xFFEAEAEA), // Light grey
                    Colors.white,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            );
          },
        ),
        // This is the actual content of the screen
        widget.child,
      ],
    );
  }
}