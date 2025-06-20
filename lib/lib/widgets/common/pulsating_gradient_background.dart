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
      duration: const Duration(seconds: 5), // Controls the speed of one pulse
    );

    // We'll animate the radius of the gradient from small to large
    _animation = Tween<double>(begin: 0.5, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // This makes the animation loop forever, zooming in and out
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
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: _animation.value, // The radius is now animated
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.8),
                    Theme.of(context).colorScheme.background,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            );
          },
        ),
        // This is the actual content of the screen (e.g., the login form)
        widget.child,
      ],
    );
  }
}