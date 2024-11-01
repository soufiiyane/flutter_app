import 'package:flutter/material.dart';
import 'cart_model.dart';
import 'cart_page.dart';

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

  void _addToCart(BuildContext context) {
    final newItem = {
      "image": widget.image,
      "title": widget.title,
      "category": widget.category,
      "size": widget.size,
      "brand": widget.brand,
      "price": widget.price,
    };

    CartModel().addItem(newItem);

    setState(() {
      _isInCart = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to Cart!')),
    );
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
                MaterialPageRoute(builder: (context) => const CartPage()), // Navigate directly to CartPage
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  widget.image,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
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
            Text("Catégorie: ${widget.category}", style: const TextStyle(fontSize: 18)),
            Text("Taille: ${widget.size}", style: const TextStyle(fontSize: 18)),
            Text("Marque: ${widget.brand}", style: const TextStyle(fontSize: 18)),
            Text(
              "Prix: ${widget.price}",
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
