import 'package:flutter/material.dart';
import 'article_page.dart'; // Import ArticlePage
import 'cart_page.dart'; // Import CartPage
import 'profile_page.dart'; // Import ProfilePage

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    ArticlePage(),
    CartPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application de Shopping'), // Changed to French
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money), // Changed to $ icon
            label: 'Acheter', // Changed text to French
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Panier', // Changed text to French
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil', // Changed text to French
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
