import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
        cartItems = decodedBody['Items'] ?? []; 
        print("Fetched cart items: $cartItems"); 
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

  double _calculateTotal() {
  double total = cartItems.fold(0.0, (sum, item) {
    final priceString = item['price'] as String?;
    
    final sanitizedPriceString = priceString?.replaceAll(RegExp(r'[^\d.]'), '') ?? '';

    final price = double.tryParse(sanitizedPriceString) ?? 0.0;

    
    return sum + price;
  });

  return total;
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon Panier"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text("Votre panier est vide."))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Card(
                            margin: const EdgeInsets.all(10),
                            child: ListTile(
                              leading: Image.network(
                                item["image"] ?? '', 
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                              ),
                              title: Text(item["title"] ?? 'Unknown Title'), 
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Taille: ${item["size"] ?? 'Unknown Size'}"), 
                                  Text("Prix: ${item["price"] ?? '0.00'}", style: const TextStyle(color: Colors.redAccent)),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () {
                                  _removeItemFromCart(item["id"] ?? ''); 
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Total: ${_calculateTotal().toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
    );
  }
}
