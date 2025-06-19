import 'package:atelier/screens/conversations/conversations_screen.dart';
import 'package:atelier/screens/home/home_screen.dart';
import 'package:atelier/screens/profile/profile_screen.dart';
import 'package:atelier/screens/search/search_screen.dart';
import 'package:atelier/widgets/common/animated_gradient_background.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    const SearchScreen(),
    const Center(child: Text('Create Listing Placeholder')),
    const ConversationsScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // TODO: Handle create listing action
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // The Scaffold is now the root widget again.
    return Scaffold(
      // The body is now wrapped in the AnimatedGradientBackground.
      // This contains the animation to only the screen content area.
      body: AnimatedGradientBackground(
        child: Center(
          child: _widgetOptions.elementAt(_selectedIndex),
        ),
      ),
      // The BottomNavigationBar will now use the color from the theme,
      // creating a clean separation.
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.house_fill),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.add_circled_solid, size: 36),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2_fill),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person_fill),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        // All styling is correctly handled by the BottomNavigationBarTheme
        // defined in our app_theme.dart file.
      ),
    );
  }
}