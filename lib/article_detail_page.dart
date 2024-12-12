import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home_page.dart';

class ArticleDetailPage extends StatefulWidget {
  final MedicinalPlant plant;

  const ArticleDetailPage({Key? key, required this.plant}) : super(key: key);

  @override
  _ArticleDetailPageState createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, String>> _localComments = [];
  
  final Color primaryColor = const Color(0xFF2D3250);
  final Color accentColor = const Color(0xFF7077A1); 
  final Color lightColor = const Color(0xFFF6F4EB);

  @override
  void initState() {
    super.initState();
    _localComments = List.from(widget.plant.comments);
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch \$urlString');
    }
  }

  void _addComment() {
    if (_commentController.text.isNotEmpty) {
      setState(() {
        _localComments.add({
          'userId': 'Current User',
          'text': _commentController.text,
        });
        _commentController.clear();
      });
    }
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: primaryColor, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoList(List<String> items, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accentColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: primaryColor,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: widget.plant.plantId,
                child: Image.network(
                  widget.plant.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.plant.name,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.plant.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 8
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(tag, style: TextStyle(color: accentColor)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.plant.description,
                    style: const TextStyle(
                      fontSize: 17,
                      height: 1.7,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Regions section moved here
                  _buildSectionTitle('Regions', Icons.public),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.plant.region.map((region) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 8
                        ),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(region, style: TextStyle(color: accentColor)),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  
                  // Properties and Uses in Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Properties', Icons.format_list_bulleted),
                            const SizedBox(height: 16),
                            _buildInfoList(widget.plant.properties, Icons.check_circle_outline),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle('Uses', Icons.healing),
                            const SizedBox(height: 16),
                            _buildInfoList(widget.plant.uses, Icons.arrow_right),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Precautions section
                  _buildSectionTitle('Precautions', Icons.warning_amber),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.plant.precautions.map((precaution) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning, color: Colors.amber, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              precaution,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),

                  const SizedBox(height: 24),
                  
                  // Articles section
                  _buildSectionTitle('Articles', Icons.library_books),
                  const SizedBox(height: 16),
                  Column(
                    children: widget.plant.articles.map((article) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => _launchURL(article),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.article, color: accentColor, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                article,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: accentColor,
                                  decoration: TextDecoration.underline,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )).toList(),
                  ),

                  const SizedBox(height: 24),
                  const Divider(height: 32),
                  
                  // Comments Section
                  _buildSectionTitle('Comments', Icons.comment),
                  const SizedBox(height: 16),
                  Container(
                    height: 300, // Fixed height for comments
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          ..._localComments.map((comment) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: accentColor.withOpacity(0.1),
                                      child: Icon(Icons.person, color: accentColor),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      comment['userId'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  comment['text'] ?? '',
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const Divider(height: 32),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.send, color: accentColor),
                        onPressed: _addComment,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}