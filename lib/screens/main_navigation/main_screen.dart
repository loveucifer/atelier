import 'package:atelier/screens/conversations/conversations_screen.dart';
import 'package:atelier/screens/home/home_screen.dart';
import 'package:atelier/screens/listings/create_listing_screen.dart';
import 'package:atelier/screens/profile/profile_screen.dart';
import 'package:atelier/screens/search/search_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  // List of the pages to be displayed, excluding the "create" screen.
  final List<Widget> _pages = const [
    HomeScreen(),
    SearchScreen(),
    ConversationsScreen(),
    ProfileScreen(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Handles tapping on the bottom navigation bar items.
  void _onItemTapped(int index) {
    // The middle button (index 2) is for creating a new listing.
    // We'll navigate to a dedicated screen instead of a modal.
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CreateListingScreen()),
      );
      return;
    }

    setState(() {
      _selectedIndex = index;
    });

    // Adjust the page index because the "List" button is not a page in the PageView.
    int pageIndex = index > 2 ? index - 1 : index;
    _pageController.jumpToPage(pageIndex);
  }

  @override
  Widget build(BuildContext context) {
    // The old Stack with custom backgrounds is replaced by a simple Scaffold.
    return Scaffold(
      body: PageView(
        controller: _pageController,
        // Update the selected index when the user swipes between pages.
        onPageChanged: (index) {
          int navIndex = index >= 2 ? index + 1 : index;
          setState(() {
            _selectedIndex = navIndex;
          });
        },
        children: _pages,
      ),
      // A standard BottomNavigationBar that uses the theme we defined.
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house),
            activeIcon: Icon(CupertinoIcons.house_fill),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: 'Search',
          ),
          // This is the special middle button for creating a new listing.
          BottomNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.add, color: Colors.white),
            ),
            label: 'List',
          ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2),
            activeIcon: Icon(CupertinoIcons.chat_bubble_2_fill),
            label: 'Inbox',
          ),
          const BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            activeIcon: Icon(CupertinoIcons.person_fill),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}