import 'package:flutter/material.dart';
import 'package:leafy_lenz/views/saved_guides_screen.dart';
import 'package:leafy_lenz/views/identification_screen.dart';
import 'package:leafy_lenz/views/profile_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {

  int _currentPageIndex = 1;

  List<Widget> destinations = [
    const NavigationDestination(
      selectedIcon: Icon(Icons.menu_book, color: Colors.green),
      icon: Icon(Icons.menu_book_outlined),
      label: 'My Guides',
    ),
    const NavigationDestination(
      selectedIcon: Icon(Icons.eco, color: Colors.green),
      icon: Icon(Icons.eco_outlined),
      label: 'Identify',
    ),
    const NavigationDestination(
      selectedIcon: Icon(Icons.person, color: Colors.green),
      icon: Icon(Icons.person_outline),
      label: 'Profile',
    ),
  ];


  List<Widget> Screens = [
    const HomeScreen(),
    const IdentificationScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white, // White background
          indicatorColor: Colors.green[100], // Light green for selected tab background
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green, // Green text for active tabs
            ),
          ),
        ),
        child: NavigationBar(
          onDestinationSelected: (int index){
            setState(() {
              _currentPageIndex = index;
            });
          },
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
          selectedIndex: _currentPageIndex,
          destinations: destinations,
        ),
      ),
      body: Screens[_currentPageIndex],
    );
  }
}
