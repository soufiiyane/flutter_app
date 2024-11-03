import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'cart_model.dart';
import 'cart_page.dart';
import 'session_manager.dart'; 

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
        _checkIfInCart(); 
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec du chargement des articles du panier : ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la récupération des articles du panier')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _checkIfInCart() {
    for (var item in cartItems) {
      if (item['title'] == widget.title) { 
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
        const SnackBar(content: Text('Utilisateur non connecté')),
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
          const SnackBar(content: Text('Ajouté au panier !')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de l\'ajout au panier : ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
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
          ? Center(child: CircularProgressIndicator()) 
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
                  Text("Catégorie : ${widget.category}", style: const TextStyle(fontSize: 18)),
                  Text("Taille : ${widget.size}", style: const TextStyle(fontSize: 18)),
                  Text("Marque : ${widget.brand}", style: const TextStyle(fontSize: 18)),
                  Text(
                    "Prix : ${widget.price}",
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
                            'Article déjà dans le panier',
                            style: TextStyle(fontSize: 16, color: Colors.green),
                          )
                        : ElevatedButton(
                            onPressed: () => _addToCart(context),
                            child: const Text("Ajouter au panier"),
                          ),
                  ),
                  const SizedBox(height: 10), 
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); 
                      },
                      child: const Text("Retour"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
