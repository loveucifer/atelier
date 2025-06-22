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
      duration: const Duration(seconds: 8),
    );

    _animation = Tween<double>(begin: 0.2, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

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
        // Layer 1: A solid white background.
        Container(color: Colors.white),

        // Layer 2: The animated black radial gradient pulse.
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: _animation.value,
                  colors: [
                    // --- OPACITY INCREASED HERE ---
                    // Increased from 0.15 to 0.35 for a stronger effect.
                    Colors.black.withOpacity(0.35),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 1.0],
                ),
              ),
            );
          },
        ),

        // Layer 3: Your screen's content.
        widget.child,
      ],
    );
  }
}