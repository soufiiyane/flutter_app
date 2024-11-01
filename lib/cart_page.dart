import 'package:flutter/material.dart';
import 'cart_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final cartItems = CartModel().cartItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Cart"),
      ),
      body: cartItems.isEmpty
          ? const Center(child: Text("Your cart is empty."))
          : ListView.builder(
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                final item = cartItems[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: Image.asset(item["image"], width: 50, height: 50),
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
                          CartModel().removeItem(index);
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
              CartModel().clearCart();
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
