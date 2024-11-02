import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_model.dart';
import 'session_manager.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
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

  Future<void> _removeItemFromCart(String itemId) async {
    final String? loggedInEmail = SessionManager().userEmail;
    if (loggedInEmail == null) return;

    final url = Uri.parse('https://g2izee01b8.execute-api.us-east-1.amazonaws.com/dev/cart');

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user': loggedInEmail, 'item_id': itemId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          cartItems.removeWhere((item) => item['id'] == itemId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item removed from cart')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to remove item: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error removing item from cart')),
      );
    }
  }

  Future<void> _clearCartItems() async {
    final String? loggedInEmail = SessionManager().userEmail;
    if (loggedInEmail == null) return;

    final url = Uri.parse('https://g2izee01b8.execute-api.us-east-1.amazonaws.com/dev/cart');
    bool hasErrors = false;

    for (var item in cartItems) {
      final String itemId = item['id'];
      try {
        final response = await http.delete(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'user': loggedInEmail, 'item_id': itemId}),
        );

        if (response.statusCode != 200) {
          hasErrors = true;
        }
      } catch (e) {
        hasErrors = true;
      }
    }

    if (hasErrors) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Some items could not be removed')),
      );
    } else {
      setState(() {
        cartItems.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cart cleared!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text("Your cart is empty."))
              : ListView.builder(
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final item = cartItems[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: Image.network(
                          item["image"],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                        ),
                        title: Text(item["title"]),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Category: ${item["category"]}"),
                            Text("Size: ${item["size"]}"),
                            Text("Brand: ${item["brand"]}"),
                            Text(
                              "Price: ${item["price"]}",
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            _removeItemFromCart(item["id"]);
                          },
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _clearCartItems,
          child: const Text("Clear Cart"),
        ),
      ),
    );
  }
}
