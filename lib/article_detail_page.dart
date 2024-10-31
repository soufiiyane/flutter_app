import 'package:flutter/material.dart';
import 'cart_model.dart';

class ArticleDetailPage extends StatelessWidget {
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

  void _addToCart(BuildContext context) {
    final newItem = {
      "image": image,
      "title": title,
      "category": category,
      "size": size,
      "brand": brand,
      "price": price,
    };

    CartModel().addItem(newItem);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to Cart!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
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
                  image,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text("Catégorie: $category", style: const TextStyle(fontSize: 18)),
            Text("Taille: $size", style: const TextStyle(fontSize: 18)),
            Text("Marque: $brand", style: const TextStyle(fontSize: 18)),
            Text(
              "Prix: $price",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
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
