import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding/decoding
import 'cart_model.dart';
import 'session_manager.dart'; // Make sure this file manages user session appropriately

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<dynamic> cartItems = []; // Initialize an empty list for cart items
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    _fetchCartItems(); // Fetch cart items when the widget is initialized
  }

  Future<void> _fetchCartItems() async {
    final String? loggedInEmail = SessionManager().userEmail; // Get the logged-in email
    if (loggedInEmail == null) {
      setState(() {
        isLoading = false;
      });
      return; // Exit if no user is logged in
    }

    final url = Uri.parse('https://g2izee01b8.execute-api.us-east-1.amazonaws.com/dev/cart');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user': loggedInEmail}), // Send the email in the request body
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String body = responseBody['body']; // Extract the 'body' as a string

        // Decode the JSON body into a map
        final Map<String, dynamic> decodedBody = jsonDecode(body);

        // Extract the 'Items' list from the decoded body
        cartItems = decodedBody['Items']; // Assign to cartItems
      } else {
        // Handle non-200 responses
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
        isLoading = false; // Stop loading regardless of success or failure
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
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
                            setState(() {
                              // Logic to remove item from the cart can be added here if needed
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              CartModel().clearCart(); // Assuming you have a clearCart method in your CartModel
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Cart cleared!")),
            );
          },
          child: const Text("Clear Cart"),
        ),
      ),
    );
  }
}
