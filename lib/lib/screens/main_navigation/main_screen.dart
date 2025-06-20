import 'package:atelier/screens/conversations/conversations_screen.dart';
import 'package:atelier/screens/home/home_screen.dart';
import 'package:atelier/screens/listings/create_listing_screen.dart';
import 'package:atelier/screens/profile/profile_screen.dart';
import 'package:atelier/screens/search/search_screen.dart';
import 'package:atelier/widgets/common/breathing_gradient_background.dart';
import 'package:atelier/widgets/common/glass_navigation_bar.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (_, controller) => BreathingGradientBackground(
            child: CreateListingScreen(),
          ),
        ),
      );
      return;
    }

    int pageIndex = index > 2 ? index - 1 : index;
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BreathingGradientBackground(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                int navIndex = index >= 2 ? index + 1 : index;
                setState(() {
                  _selectedIndex = navIndex;
                });
              },
              children: const <Widget>[
                HomeScreen(),
                SearchScreen(),
                ConversationsScreen(),
                ProfileScreen(),
              ],
            ),
          ),
          GlassNavigationBar(
            selectedIndex: _selectedIndex,
            onItemTapped: _onItemTapped,
          ),
        ],
      ),
    );
  }
}