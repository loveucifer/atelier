import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class GlassAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const GlassAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: preferredSize.height,
      borderRadius: 0,
      blur: 15,
      alignment: Alignment.bottomCenter,
      border: 0,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Theme.of(context).colorScheme.surface.withOpacity(0.2),
          Theme.of(context).colorScheme.surface.withOpacity(0.1),
        ],
        stops: const [0.1, 1],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Theme.of(context).colorScheme.surface.withOpacity(0.5),
          Theme.of(context).colorScheme.surface.withOpacity(0.5),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (actions != null) Row(children: actions!),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size(double.infinity, 80);
}