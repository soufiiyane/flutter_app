import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data'; // For handling image data
import 'dart:convert'; // For JSON encoding
import 'profile_page.dart';

class AddArticlePage extends StatefulWidget {
  const AddArticlePage({Key? key}) : super(key: key);

  @override
  _AddArticlePageState createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  Uint8List? _imageData; // Store the uploaded image data here

  Future<void> _pickImage() async {
    // Pick an image from the user’s files
    final Uint8List? imageData = await ImagePickerWeb.getImageAsBytes();
    if (imageData != null) {
      setState(() {
        _imageData = imageData;
      });
    }
  }

  void _submitArticle() async {
    if (_formKey.currentState!.validate()) {
      // Convert image data to Base64
      String base64Image = base64Encode(_imageData!);

      // Prepare the data to send
      Map<String, dynamic> articleData = {
        "brand": _brandController.text,
        "category": _categoryController.text,
        "price": double.tryParse(_priceController.text) ?? 0.0,
        "size": _sizeController.text,
        "title": _titleController.text,
        "image_data": base64Image,
      };

      // Send the POST request
      try {
        final response = await http.post(
          Uri.parse('https://g2izee01b8.execute-api.us-east-1.amazonaws.com/dev/articles'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(articleData),
        );

        // Show a message based on the response
        if (response.statusCode == 200) {
          // Article submitted successfully
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Article submitted successfully')),
          );
        } else {
          // Handle failure
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit article: ${response.body}')),
          );
        }
      } catch (error) {
        // Handle network errors or any exceptions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting article: $error')),
        );
      }
      
      // Clear the form after submission
      _brandController.clear();
      _categoryController.clear();
      _priceController.clear();
      _sizeController.clear();
      _titleController.clear();
      setState(() {
        _imageData = null; // Reset image data
      });
    }
  }

  void _returnToProfile() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add an Article'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Brand'),
                validator: (value) => value!.isEmpty ? 'Enter Brand' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) => value!.isEmpty ? 'Enter Category' : null,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Upload Image'),
              ),
              if (_imageData != null)
                Image.memory(
                  _imageData!,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter Price' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _sizeController,
                decoration: const InputDecoration(labelText: 'Size'),
                validator: (value) => value!.isEmpty ? 'Enter Size' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) => value!.isEmpty ? 'Enter Title' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitArticle,
                child: const Text('Submit'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _returnToProfile,
                child: const Text('Return to Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}