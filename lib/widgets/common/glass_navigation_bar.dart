import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';

class GlassNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const GlassNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 70,
          borderRadius: 20,
          blur: 15,
          alignment: Alignment.center,
          border: 1,
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
              Colors.white.withOpacity(0.3),
              Colors.white.withOpacity(0.2),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(CupertinoIcons.house_fill, 0, context),
              _buildNavItem(CupertinoIcons.search, 1, context),
              _buildCreateItem(2, context),
              _buildNavItem(CupertinoIcons.chat_bubble_2_fill, 3, context),
              _buildNavItem(CupertinoIcons.person_fill, 4, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, BuildContext context) {
    final bool isSelected = selectedIndex == index;
    // This logic ensures the correct color is used based on selection state
    final color = isSelected ? Theme.of(context).primaryColor : Colors.grey[400];

    return IconButton(
      onPressed: () => onItemTapped(index),
      icon: Icon(icon, color: color, size: 28),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }

  Widget _buildCreateItem(int index, BuildContext context) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: GlassmorphicContainer(
        width: 55,
        height: 55,
        borderRadius: 27.5,
        blur: 10,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.4),
            Theme.of(context).primaryColor.withOpacity(0.2),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.white.withOpacity(0.3),
          ],
        ),
        child: const Icon(CupertinoIcons.add, color: Colors.white, size: 28),
      ),
    );
  }
}