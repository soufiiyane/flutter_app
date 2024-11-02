import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_model.dart';
import 'cart_page.dart';
import 'session_manager.dart'; // Ensure this file manages user session appropriately

class ArticleDetailPage extends StatefulWidget {
  final String image;
  final String title;
  final String category;
  final String size;
  final String brand;
  final String price;

  const ArticleDetailPage({
    Key? key,
    required this.image,
    required this.title,
    required this.category,
    required this.size,
    required this.brand,
    required this.price,
  }) : super(key: key);

  @override
  _ArticleDetailPageState createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  bool _isInCart = false;
  List<dynamic> cartItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchCartItems();
  }

  Future<void> _fetchCartItems() async {
    final String? loggedInEmail = SessionManager().userEmail;
    if (loggedInEmail == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final url = Uri.parse('https://g2izee01b8.execute-api.us-east-1.amazonaws.com/dev/cart');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user': loggedInEmail}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String body = responseBody['body'];
        final Map<String, dynamic> decodedBody = jsonDecode(body);
        cartItems = decodedBody['Items'];
        _checkIfInCart(); // Check if the item is already in the cart
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load cart items: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error fetching cart items')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _checkIfInCart() {
    for (var item in cartItems) {
      if (item['title'] == widget.title) { // Match based on title or a unique identifier
        setState(() {
          _isInCart = true;
        });
        break;
      }
    }
  }

  Future<void> _addToCart(BuildContext context) async {
    final String? loggedInEmail = SessionManager().userEmail;

    if (loggedInEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final newItem = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "title": widget.title,
      "category": widget.category,
      "brand": widget.brand,
      "size": widget.size,
      "price": widget.price,
      "image": widget.image,
    };

    final body = {
      "user": loggedInEmail,
      "item": [newItem],
    };

    final url = Uri.parse("https://g2izee01b8.execute-api.us-east-1.amazonaws.com/dev/cart");
    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        setState(() {
          _isInCart = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Added to Cart!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to cart: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartPage()),
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.image,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Category: ${widget.category}", style: const TextStyle(fontSize: 18)),
                  Text("Size: ${widget.size}", style: const TextStyle(fontSize: 18)),
                  Text("Brand: ${widget.brand}", style: const TextStyle(fontSize: 18)),
                  Text(
                    "Price: ${widget.price}",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: _isInCart
                        ? const Text(
                            'Item already in cart',
                            style: TextStyle(fontSize: 16, color: Colors.green),
                          )
                        : ElevatedButton(
                            onPressed: () => _addToCart(context),
                            child: const Text("Add to Cart"),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
