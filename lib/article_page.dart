import 'package:flutter/material.dart';
import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as http;
import 'article_detail_page.dart';

class ArticlePage extends StatefulWidget {
  ArticlePage({Key? key}) : super(key: key);

  @override
  _ArticlePageState createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  List<Map<String, dynamic>> articles = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchArticles();
  }

  Future<void> fetchArticles() async {
    final url = Uri.parse('https://g2izee01b8.execute-api.us-east-1.amazonaws.com/dev/articles');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final List<dynamic> articleData = jsonDecode(responseBody['body']);

        setState(() {
          articles = articleData.map((data) => Map<String, dynamic>.from(data)).toList();
          isLoading = false;
        });
      } else {
        // Error response
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      // Exception
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Articles"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? const Center(child: Text('Failed to load articles'))
              : ListView.builder(
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ArticleDetailPage(
                              image: article["image"],
                              title: article["title"],
                              category: article["category"],
                              size: article["size"],
                              brand: article["brand"],
                              price: article["price"],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.red[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                article["image"],
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article["title"],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Size: ${article["size"]}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    "Price: ${article["price"]}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
