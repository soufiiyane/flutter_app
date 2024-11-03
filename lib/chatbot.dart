import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatBotDialog extends StatefulWidget {
  @override
  _ChatBotDialogState createState() => _ChatBotDialogState();
}

class _ChatBotDialogState extends State<ChatBotDialog> {
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, String>> _messages = [
    {"sender": "chatbot", "text": "Bonjour, je suis un chatbot IA basé sur GPT. Vous pouvez communiquer avec moi pour vous aider sur n'importe quel sujet!"}
  ]; // Initial message from chatbot

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      setState(() {
        // Add user message
        _messages.add({"sender": "user", "text": _messageController.text});
      });

      String responseText = await _getResponseFromOpenAI(_messageController.text);
      
      setState(() {
        // Add chatbot's response
        _messages.add({"sender": "chatbot", "text": responseText});
        _messageController.clear(); // Clear input field after sending
      });
    }
  }

  Future<String> _getResponseFromOpenAI(String userInput) async {
    final String apiKey = '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'; // Replace with your OpenAI API key
    final String apiUrl = 'https://api.openai.com/v1/chat/completions';
    
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "model": "gpt-3.5-turbo", 
          "messages": [
            {"role": "user", "content": userInput}
          ],
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['choices'][0]['message']['content'].toString();
      } else {
        // Log response for debugging
        print('Error: ${response.statusCode}, Response: ${response.body}');
        return "Désolé, je n'ai pas pu obtenir de réponse.";
      }
    } catch (e) {
      print('Exception: $e'); // Log exception for debugging
      return "Une erreur est survenue : $e";
    }
  }

  Widget _buildMessage(Map<String, String> message) {
    bool isUserMessage = message['sender'] == 'user';
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isUserMessage ? Colors.blue[200] : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message['text']!,
          style: TextStyle(color: isUserMessage ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ChatBot'),
      content: Container(
        width: double.maxFinite,
        height: 400, // Fixed height for the dialog
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: _messages.map((message) => _buildMessage(message)).toList(),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(hintText: 'Écrivez un message...'),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
