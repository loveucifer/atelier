import 'package:flutter/material.dart';
import 'dart:math';

class BreathingGradientBackground extends StatefulWidget {
  final Widget child;
  const BreathingGradientBackground({super.key, required this.child});

  @override
  State<BreathingGradientBackground> createState() => _BreathingGradientBackgroundState();
}

class _BreathingGradientBackgroundState extends State<BreathingGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // NEW: Darker, more subtle color palette
  static const List<Color> darkColorList = [
    Color(0xFF4A0000), // Deeper, less vibrant red
    Color(0xFF000000), // Pitch Black
  ];

  static const List<Color> lightColorList = [
    Color(0xFFE57373), // Muted Red
    Color(0xFFFFFFFF), // White
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    );

    _animation = Tween<double>(begin: 1.0, end: 1.5).animate(
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colors = isDarkMode ? darkColorList : lightColorList;

    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: _animation.value,
                  colors: colors,
                  stops: const [0.0, 1.0],
                ),
              ),
            );
          },
        ),
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/noise.png'),
              fit: BoxFit.cover,
              opacity: 0.03,
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}