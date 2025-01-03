import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'article_detail_page.dart';
import 'login_page.dart';
import 'session_manager.dart';
import 'package:uuid/uuid.dart';

class MedicinalPlant {
  final String name;
  final String description;
  final String imageUrl;
  final String plantId;
  final List<String> properties;
  final List<String> uses;
  final List<String> tags;
  final List<String> articles;
  final List<String> precautions;
  final List<String> region;
  final List<Map<String, String>> comments;

  MedicinalPlant({
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.plantId,
    required this.properties,
    required this.uses,
    required this.tags,
    required this.articles,
    required this.precautions,
    required this.region,
    required this.comments,
  });

 factory MedicinalPlant.fromJson(Map<String, dynamic> json) {
    return MedicinalPlant(
      name: json['Name'] ?? '',
      description: json['Description'] ?? '',
      imageUrl: json['ImageS3Url'] ?? '',
      plantId: json['PlantId'] ?? '',
      properties: (json['Properties'] as List?)
          ?.map((prop) => prop['S'] as String)
          .toList() ?? [],
      uses: (json['Uses'] as List?)
          ?.map((use) => use['S'] as String)
          .toList() ?? [],
      tags: (json['Tags'] as List?)
          ?.map((tag) => tag['S'] as String)
          .toList() ?? [],
      articles: (json['Articles'] as List?)
          ?.map((article) => article['S'] as String)
          .toList() ?? [],
      precautions: (json['Precautions'] as List?)
          ?.map((precaution) => precaution['S'] as String)
          .toList() ?? [],
      region: (json['Region'] as List?)
          ?.map((reg) => reg['S'] as String)
          .toList() ?? [],
      comments: (json['Comments'] as List?)?.map((comment) {
        if (comment['M'] != null) {
          final commentMap = comment['M'];
          return <String, String>{  // Explicit type declaration
            'text': (commentMap['Text']?['S'] ?? '').toString(),
            'userId': (commentMap['UserId']?['S'] ?? '').toString(),
            'FirstName': (commentMap['FirstName']?['S'] ?? '').toString(),
            'LastName': (commentMap['LastName']?['S'] ?? '').toString(),
            'UserImageUrl': (commentMap['UserImageUrl']?['S'] ?? '').toString()
          };
        }
        return <String, String>{  // Explicit type declaration for empty map
          'text': '',
          'userId': '',
          'FirstName': '',
          'LastName': '',
          'UserImageUrl': ''
        };
      }).toList() ?? [],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isChatVisible = false;
  TextEditingController _searchController = TextEditingController();
  TextEditingController _chatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _chatScrollController = ScrollController();
  String _selectedSearchType = 'Name';
  List<MedicinalPlant> _plants = [];
  List<MedicinalPlant> _filteredPlants = [];
  bool _isLoading = true;
  String _error = '';
  String _sessionId = '';
  bool _isTyping = false;
  
  int _currentPage = 1;
  final int _itemsPerPage = 4;
  int _totalPages = 1;

  final Color primaryColor = const Color(0xFF2D3250);
  final Color accentColor = const Color(0xFF7077A1);
  final Color lightColor = const Color(0xFFF6F4EB);

  List<Map<String, String>> _chatMessages = [
    {"sender": "System", "message": "Hello! I'm your AI assistant. How can I help you today?"}
  ];

  @override
  void initState() {
    super.initState();
    _generateSessionId();
    _fetchPlants();
  }

  void _generateSessionId() {
    final uuid = Uuid();
    _sessionId = uuid.v4();
  }

  Future<void> _fetchPlants() async {
    try {
      final response = await http.get(Uri.parse(
          'https://ssmb5oqxxa.execute-api.us-east-1.amazonaws.com/dev/medicinalPlants'));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final items = json.decode(jsonResponse['body'])['items'] as List;
        setState(() {
          _plants = items.map((item) => MedicinalPlant.fromJson(item)).toList();
          _filteredPlants = _plants;
          _totalPages = (_filteredPlants.length / _itemsPerPage).ceil();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load plants';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterPlants(String query) {
    setState(() {
      _filteredPlants = _plants.where((plant) {
        if (_selectedSearchType == 'Name') {
          return plant.name.toLowerCase().contains(query.toLowerCase());
        } else if (_selectedSearchType == 'Tags') {
          return plant.tags.any((tag) =>
              tag.toLowerCase().contains(query.toLowerCase()));
        } else if (_selectedSearchType == 'Properties') {
          return plant.properties.any((property) =>
              property.toLowerCase().contains(query.toLowerCase()));
        }
        return false;
      }).toList();
      _currentPage = 1;
      _totalPages = (_filteredPlants.length / _itemsPerPage).ceil();
    });
  }

  List<MedicinalPlant> get _paginatedPlants {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    
    if (startIndex >= _filteredPlants.length) {
      return [];
    }
    
    if (endIndex > _filteredPlants.length) {
      return _filteredPlants.sublist(startIndex);
    }
    
    return _filteredPlants.sublist(startIndex, endIndex);
  }

  Widget _buildPageButton(int page) {
    final isSelected = _currentPage == page;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentPage = page;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor : accentColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${page}',
          style: TextStyle(
            color: isSelected ? Colors.white : primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: _currentPage > 1 ? accentColor : Colors.grey),
          onPressed: _currentPage > 1
              ? () {
                  setState(() {
                    _currentPage--;
                  });
                }
              : null,
        ),
        if (_totalPages <= 7) ...[
          // Show all pages if total pages are 7 or less
          for (int i = 1; i <= _totalPages; i++)
            _buildPageButton(i),
        ] else ...[
          // Show first page
          _buildPageButton(1),
          // Show dots or pages
          if (_currentPage > 3) 
            Text('...', style: TextStyle(color: accentColor))
          else
            for (int i = 2; i <= 3; i++) _buildPageButton(i),
          
          // Show current page and surrounding pages
          if (_currentPage > 3 && _currentPage < _totalPages - 2)
            for (int i = _currentPage - 1; i <= _currentPage + 1; i++) 
              _buildPageButton(i),
          
          // Show dots or pages
          if (_currentPage < _totalPages - 2) 
            Text('...', style: TextStyle(color: accentColor))
          else
            for (int i = _totalPages - 2; i < _totalPages; i++) _buildPageButton(i),
          
          // Show last page
          _buildPageButton(_totalPages),
        ],
        IconButton(
          icon: Icon(Icons.chevron_right, 
            color: _currentPage < _totalPages ? accentColor : Colors.grey),
          onPressed: _currentPage < _totalPages
              ? () {
                  setState(() {
                    _currentPage++;
                  });
                }
              : null,
        ),
        const SizedBox(width: 16),
        // Quick page jump dropdown
        if (_totalPages > 7) Container(
          padding: EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<int>(
            value: _currentPage,
            underline: SizedBox(),
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
            items: List.generate(_totalPages, (index) => index + 1)
                .map((page) => DropdownMenuItem(
                      value: page,
                      child: Text('Go to ${page}'),
                    ))
                .toList(),
            onChanged: (page) {
              if (page != null) {
                setState(() {
                  _currentPage = page;
                });
              }
            },
          ),
        ),
      ],
    );
  }


  Future<void> _sendMessage() async {
    if (_chatController.text.isEmpty) return;

    final userMessage = _chatController.text;
    _chatController.clear();

    setState(() {
      _chatMessages.add({"sender": "User", "message": userMessage});
      _isTyping = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://ssmb5oqxxa.execute-api.us-east-1.amazonaws.com/dev/agent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'inputText': userMessage,
          'session_id': _sessionId,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final bodyData = json.decode(responseData['body']);
        final messages = bodyData['messages'] as List;
        
        setState(() {
          _chatMessages.add({
            "sender": "System",
            "message": messages.first.toString(),
          });
          _isTyping = false;
        });
      } else {
        setState(() {
          _chatMessages.add({
            "sender": "System",
            "message": "Sorry, I encountered an error. Please try again.",
          });
          _isTyping = false;
        });
      }
    } catch (e) {
      setState(() {
        _chatMessages.add({
          "sender": "System",
          "message": "Sorry, there was an error connecting to the server.",
        });
        _isTyping = false;
      });
    }

    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_chatScrollController.hasClients) {
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
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
    return Scaffold(
      backgroundColor: lightColor,
      appBar: AppBar(
        title: const Text(
          "iPlant",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24, 
            color: Colors.white,
          ),
        ),
        backgroundColor: primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: accentColor),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Clear session
                        SessionManager().clear();
                        // Navigate to login page
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(title: 'iPlant'),
                          ),
                          (route) => false, // This removes all previous routes
                        );
                      },
                      child: Text(
                        'Logout',
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                color: lightColor,
                child: Container(
                  decoration: BoxDecoration(
                    color: lightColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildFilterOption("Name"),
                            _buildFilterOption("Tags"),
                            _buildFilterOption("Properties"),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _filterPlants,
                            decoration: InputDecoration(
                              hintText: "Search plants...",
                              prefixIcon: Icon(Icons.search, color: accentColor),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 12,
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: primaryColor))
                    : _error.isNotEmpty
                        ? Center(child: Text(_error))
                        : Column(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: GridView.builder(
                                    controller: _scrollController,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 16.0,
                                      mainAxisSpacing: 16.0,
                                      childAspectRatio: 0.75,
                                    ),
                                    itemCount: _paginatedPlants.length,
                                    itemBuilder: (context, index) {
                                      final plant = _paginatedPlants[index];
                                      return GestureDetector(
                                        onTap: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ArticleDetailPage(plant: plant),
                                            ),
                                          );
                                          _fetchPlants();
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Hero(
                                                tag: plant.plantId,
                                                child: ClipRRect(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    topLeft: Radius.circular(12),
                                                    topRight: Radius.circular(12),
                                                  ),
                                                  child: Image.network(
                                                    plant.imageUrl,
                                                    width: double.infinity,
                                                    height: 150,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(12.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      plant.name,
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: primaryColor,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Wrap(
                                                      spacing: 4,
                                                      runSpacing: 4,
                                                      children: plant.tags
                                                          .take(2)
                                                          .map((tag) => Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal: 8,
                                                                  vertical: 4,
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: accentColor
                                                                      .withOpacity(
                                                                          0.1),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child: Text(
                                                                  tag,
                                                                  style:
                                                                      TextStyle(
                                                                    color:
                                                                        accentColor,
                                                                    fontSize: 12,
                                                                  ),
                                                                ),
                                                              ))
                                                          .toList(),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      _getShortDescription(
                                                          plant.description),
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.grey[700],
                                                      ),
                                                      maxLines: 3,
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                              _buildPaginationControls(),
                              SizedBox(height: 16),
                            ],
                          ),
              ),
            ],
          ),
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
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  _isChatVisible ? Icons.close : Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          if (_isChatVisible)
            Positioned(
              bottom: 80,
              right: 20,
              child: Container(
                width: 300,
                height: 400,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12.0),
                          topRight: Radius.circular(12.0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.support_agent, color: lightColor),
                          const SizedBox(width: 8),
                          Text(
                            'AI Assistant',
                            style: TextStyle(
                              color: lightColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: _chatScrollController,
                        padding: const EdgeInsets.all(16.0),
                        itemCount: _chatMessages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _chatMessages.length && _isTyping) {
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.all(12.0),
                                margin: const EdgeInsets.only(bottom: 8.0),
                                decoration: BoxDecoration(
                                  color: lightColor,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text('Typing...'),
                                  ],
                                ),
                              ),
                            );
                          }

                          final message = _chatMessages[index];
                          return Align(
                            alignment: message['sender'] == 'User'
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.all(12.0),
                              margin: const EdgeInsets.only(bottom: 8.0),
                              decoration: BoxDecoration(
                                color: message['sender'] == 'User'
                                    ? accentColor.withOpacity(0.1)
                                    : lightColor,
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              constraints: BoxConstraints(maxWidth: 250),
                              child: Text(
                                message['message']!,
                                style: TextStyle(
                                  color: message['sender'] == 'User'
                                      ? primaryColor
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border(
                          top: BorderSide(color: Colors.grey[200]!),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _chatController,
                              decoration: InputDecoration(
                                hintText: 'Type your message...',
                                filled: true,
                                fillColor: lightColor,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.white),
                              onPressed: _sendMessage,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterOption(String option) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSearchType = option;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        decoration: BoxDecoration(
          color: _selectedSearchType == option ? accentColor : Colors.transparent,
          border: Border.all(color: accentColor, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          option,
          style: TextStyle(
            color: _selectedSearchType == option ? Colors.white : accentColor,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _chatController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}