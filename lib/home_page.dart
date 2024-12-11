import 'package:flutter/material.dart';
import 'article_detail_page.dart';  // Import the article detail page.

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isChatVisible = false;
  TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _articles = List.generate(15, (index) {
    return {
      "title": "Article ${index + 1}",
      "tags": "Tag${index + 1}, Category",
      "imageUrl": "https://images.unsplash.com/photo-1607863680132-4a1ed66c6263?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "description": "This is a sample description for article ${index + 1}. This description is meant to show how the article description text looks when it's about 100-150 words long.",
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

  // List to hold chat messages
  List<Map<String, String>> _chatMessages = [
    {"sender": "System", "message": "Hello! I'm your AI assistant. How can I help you today?"}
  ];

  // Method to add a user message
  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        // Add the user's message to the chat
        _chatMessages.add({"sender": "User", "message": _controller.text});
        // Optionally, add a system response after the user's message
        _chatMessages.add({"sender": "System", "message": "Thank you for your message. I'll help you shortly."});
        _controller.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalPages = (_articles.length / _pageSize).ceil();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Blog"),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          Column(
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
                          // Navigate to the article detail page on tap.
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
                            mainAxisSize: MainAxisSize.min,
                            children: [
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
              // Pagination with Number Buttons
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(totalPages, (index) {
                    return GestureDetector(
                      onTap: () => _goToPage(index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _currentPage == index ? Colors.blue : Colors.transparent,
                          border: Border.all(
                            color: _currentPage == index ? Colors.blue : Colors.grey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: _currentPage == index ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          // Chat Popup - Positioned at bottom-right with a z-index effect
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isChatVisible = !_isChatVisible;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  _isChatVisible ? Icons.chat_bubble : Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          // Chat Window - Displayed when chat is visible
          if (_isChatVisible)
            Positioned(
              bottom: 80,
              right: 20,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                elevation: 5,
                child: Container(
                  width: 300,
                  height: 400, // Increased height of the chat window
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _chatMessages.length,
                          itemBuilder: (context, index) {
                            final message = _chatMessages[index];
                            return Align(
                              alignment: message['sender'] == 'User'
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.all(8.0),
                                margin: const EdgeInsets.symmetric(vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: message['sender'] == 'User'
                                      ? Colors.blue[100]
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Text(
                                  message['message']!,
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16.0), // Reduced padding
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.0),
                          color: Colors.grey[200],
                        ),
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: "Type your message...",
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Reduced padding
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: _sendMessage,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
