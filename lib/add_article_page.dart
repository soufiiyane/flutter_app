import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'dart:typed_data'; // For handling image data
import 'dart:convert'; // For JSON encoding
import 'package:http/http.dart' as http;

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
        _categoryController.clear(); // Clear any existing text
        _categoryController.text = 'Pantalon'; // Set default category
      });
    }
  }

  void _submitArticle() async {
    if (_formKey.currentState!.validate() && _imageData != null) {
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

      // Show success message immediately
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Article ajouté avec succès')),
      );

      // Send the POST request without waiting for the response
      try {
        await http.post(
          Uri.parse('https://g2izee01b8.execute-api.us-east-1.amazonaws.com/dev/articles'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(articleData),
        );
      } catch (error) {
        // Handle network errors or any exceptions
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de l\'ajout de l\'article: $error')),
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
    } else if (_imageData == null) {
      // Show error if no image is uploaded
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez télécharger une image')),
      );
    }
  }

  void _returnToProfile() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un Article'),
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
                decoration: const InputDecoration(labelText: 'Marque'),
                validator: (value) => value!.isEmpty ? 'Entrez une marque' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Catégorie'),
                validator: (value) => value!.isEmpty ? 'Entrez une catégorie' : null,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Télécharger une image'),
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
                decoration: const InputDecoration(labelText: 'Prix'),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Entrez un prix' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _sizeController,
                decoration: const InputDecoration(labelText: 'Taille'),
                validator: (value) => value!.isEmpty ? 'Entrez une taille' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: (value) => value!.isEmpty ? 'Entrez un titre' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitArticle,
                child: const Text('Valider'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _returnToProfile,
                child: const Text('Retourner au profil'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
