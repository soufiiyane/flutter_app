import 'package:flutter/material.dart';
import 'article_page.dart'; 
import 'cart_page.dart'; 
import 'profile_page.dart'; 
import 'chatbot.dart'; 

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

  void _openChatBot() {
    showDialog(
      context: context,
      builder: (context) => ChatBotDialog(), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application de Shopping'),
      ),
      body: Stack(
        children: [
          _pages[_selectedIndex],
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _openChatBot,
              child: const Icon(Icons.chat),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.attach_money),
            label: 'Acheter',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Panier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
