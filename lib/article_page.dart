import 'package:flutter/material.dart';
import 'article_detail_page.dart';

class ArticlePage extends StatelessWidget {
  ArticlePage({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> articles = [
    {
      "image": "assets/images/article1.jpg",
      "title": "Article 1",
      "category": "Pantalon",
      "size": "Medium",
      "brand": "Brand A",
      "price": "\$20"
    },
    {
      "image": "assets/images/article2.jpg",
      "title": "Article 2",
      "category": "Short",
      "size": "Large",
      "brand": "Brand B",
      "price": "\$35"
    },
    {
      "image": "assets/images/article3.jpg",
      "title": "Article 3",
      "category": "Haut",
      "size": "Small",
      "brand": "Brand C",
      "price": "\$15"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Articles"),
      ),
      body: ListView.builder(
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
                    child: Image.asset(
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
