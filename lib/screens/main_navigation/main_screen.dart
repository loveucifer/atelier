import 'package:atelier/screens/conversations/conversations_screen.dart';
import 'package:atelier/screens/home/home_screen.dart';
import 'package:atelier/screens/profile/profile_screen.dart';
import 'package:atelier/screens/search/search_screen.dart';
import 'package:atelier/widgets/common/animated_gradient_background.dart';
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
      // TODO: Handle create listing action
      print("Create button tapped!");
      return;
    }

    // A bug fix: The PageView has fewer items than the nav bar because of the create button.
    // We need to map the nav bar index to the correct page index.
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
          AnimatedGradientBackground(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                // A bug fix: Map the page index back to the correct nav bar index.
                int navIndex = index >= 2 ? index + 1 : index;
                setState(() {
                  _selectedIndex = navIndex;
                });
              },
              children: const <Widget>[
                HomeScreen(),
                SearchScreen(),
                // The "Create" button doesn't have a page, so it's not in this list.
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