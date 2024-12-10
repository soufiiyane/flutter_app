import 'package:flutter/material.dart';
import 'article_detail_page.dart';  // Import the article detail page.

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _articles = List.generate(15, (index) {
    return {
      "title": "Article ${index + 1}",
      "tags": "Tag${index + 1}, Category",
      "imageUrl": "https://images.unsplash.com/photo-1607863680132-4a1ed66c6263?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "description": "This is a sample description for article ${index + 1}. This description is meant to show how the article description text looks when it's about 100-150 words long. It provides a brief preview of the article content to encourage the user to click and read more. The actual text here can be adjusted to fit your requirements or content structure. Don't forget to use an engaging opening sentence!",
    };
  });

  final int _pageSize = 10;
  int _currentPage = 0;

  List<Map<String, String>> get _currentPageArticles {
    int startIndex = _currentPage * _pageSize;
    int endIndex = ((_currentPage + 1) * _pageSize).clamp(0, _articles.length);
    return _articles.sublist(startIndex, endIndex);
  }

  void _goToPage(int pageIndex) {
    setState(() {
      _currentPage = pageIndex;
    });
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  String _getShortDescription(String description) {
    final words = description.split(' ');
    if (words.length > 12) {
      return words.take(12).join(' ') + '...';
    }
    return description;
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (_articles.length / _pageSize).ceil();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Blog"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search articles...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          // Articles
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                controller: _scrollController,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 0.75,
                ),
                itemCount: _currentPageArticles.length,
                itemBuilder: (context, index) {
                  final article = _currentPageArticles[index];
                  return GestureDetector(
                    onTap: () {
                      // Navigate to the detail page on tap.
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticleDetailPage(
                            article: article,  // Pass the article to the detail page.
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,  // This ensures the card adjusts based on the content's height
                        children: [
                          // Image with natural height
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                            child: Image.network(
                              article['imageUrl']!,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  article['title']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  article['tags']!,
                                  style: const TextStyle(
                                    color: Colors.blueGrey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Description limited to 12 words
                                Text(
                                  _getShortDescription(article['description']!),
                                  style: const TextStyle(fontSize: 14),
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
            ),
          ),
          // Pagination Buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                totalPages,
                (index) => MouseRegion(
                  onEnter: (_) => setState(() {}),
                  onExit: (_) => setState(() {}),
                  child: GestureDetector(
                    onTap: () => _goToPage(index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? Colors.blue
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        "${index + 1}",
                        style: TextStyle(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
