import 'package:flutter/material.dart';

class ArticleDetailPage extends StatefulWidget {
  final Map<String, String> article;

  const ArticleDetailPage({Key? key, required this.article}) : super(key: key);

  @override
  _ArticleDetailPageState createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  int articleUpvotes = 0;
  int articleDownvotes = 0;
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, dynamic>> comments = [
    {
      'user': 'User1',
      'comment': 'This is a great article!',
      'likes': 5,
      'dislikes': 1,
    },
    {
      'user': 'User2',
      'comment': 'I disagree with some points, but overall okay.',
      'likes': 2,
      'dislikes': 3,
    }
  ];

  bool isAccordion1Open = true; // Default to open

  void _toggleAccordion1() {
    setState(() {
      isAccordion1Open = !isAccordion1Open;
    });
  }

  void _upvoteArticle() {
    setState(() {
      articleUpvotes++;
    });
  }

  void _downvoteArticle() {
    setState(() {
      articleDownvotes++;
    });
  }

  void _likeComment(int index) {
    setState(() {
      comments[index]['likes']++;
    });
  }

  void _dislikeComment(int index) {
    setState(() {
      comments[index]['dislikes']++;
    });
  }

  void _submitComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        comments.add({
          'user': 'New User',
          'comment': _commentController.text,
          'likes': 0,
          'dislikes': 0,
        });
        _commentController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.article['title'] ?? 'Article Details'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Article Image
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  widget.article['imageUrl']!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              // Article Title
              Text(
                widget.article['title']!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Article Tags
              Text(
                widget.article['tags']!,
                style: const TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              // Article Description
              Text(
                widget.article['description']!,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              // Upvote/Downvote Section for Article
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.thumb_up),
                    onPressed: _upvoteArticle,
                  ),
                  Text('$articleUpvotes'),
                  IconButton(
                    icon: const Icon(Icons.thumb_down),
                    onPressed: _downvoteArticle,
                  ),
                  Text('$articleDownvotes'),
                ],
              ),
              const SizedBox(height: 32),
              // Accordion 1
              GestureDetector(
                onTap: _toggleAccordion1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Precautions for Medicinal Plants',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Icon(
                          isAccordion1Open ? Icons.expand_less : Icons.expand_more,
                        ),
                      ],
                    ),
                    if (isAccordion1Open)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text("• Always consult a healthcare provider before use."),
                            Text("• Be aware of potential allergic reactions."),
                            Text("• Avoid combining with prescription medications without advice."),
                            Text("• Use recommended dosages to prevent toxicity."),
                            Text("• Keep away from children."),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(),
              const SizedBox(height: 32),
              // Recommendations Section
              const Text(
                'Recommended Articles',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: PageView.builder(
                  itemCount: 3,
                  controller: PageController(viewportFraction: 0.9),
                  itemBuilder: (context, pageIndex) {
                    int startIndex = pageIndex * 2;
                    return Row(
                      children: [
                        Expanded(child: _buildArticleCard(startIndex)),
                        const SizedBox(width: 16),
                        Expanded(child: _buildArticleCard(startIndex + 1)),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              // Comments Section
              const Text(
                'Comments',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment['user'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          comment['comment'],
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.thumb_up),
                              onPressed: () => _likeComment(index),
                            ),
                            Text('${comment['likes']}'),
                            IconButton(
                              icon: const Icon(Icons.thumb_down),
                              onPressed: () => _dislikeComment(index),
                            ),
                            Text('${comment['dislikes']}'),
                          ],
                        ),
                        const Divider(),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _commentController,
                decoration: InputDecoration(
                  labelText: 'Add a comment...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _submitComment,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleCard(int index) {
    final recommendedArticle = {
      "title": "Recommended Article ${index + 1}",
      "imageUrl":
          "https://images.unsplash.com/photo-1607863680132-4a1ed66c6263?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      "tags": "Tech, News",
      "description":
          "This is a recommended article to enhance your experience."
    };
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ArticleDetailPage(article: recommendedArticle),
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
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              child: Image.network(
                recommendedArticle['imageUrl']!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                recommendedArticle['title']!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                recommendedArticle['tags']!,
                style: const TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _getShortDescription(recommendedArticle['description']!),
                style: const TextStyle(fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getShortDescription(String description) {
    final words = description.split(' ');
    if (words.length > 10) {
      return words.take(10).join(' ') + '...';
    }
    return description;
  }
}
