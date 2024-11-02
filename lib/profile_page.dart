import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'add_article_page.dart'; // Import the AddArticlePage
import 'dart:convert'; // For JSON encoding/decoding
import 'package:http/http.dart' as http;
import 'session_manager.dart'; // Import your session manager

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final String? loggedInEmail = SessionManager().userEmail;

    if (loggedInEmail != null) {
      final url = Uri.parse('https://g2izee01b8.execute-api.us-east-1.amazonaws.com/dev/user');
      final Map<String, String> requestBody = {
        'user': loggedInEmail,
      };

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        final Map<String, dynamic> userData = jsonDecode(responseBody['body']);

        setState(() {
          _emailController.text = userData['email'];
          _passwordController.text = userData['password']; // Handle carefully
          _birthdayController.text = userData['birthday'];
          _addressController.text = userData['address'];
          _postalCodeController.text = userData['codePostal'];
          _cityController.text = userData['ville'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec du chargement du profil utilisateur : ${response.statusCode}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email de l’utilisateur non trouvé dans la session')),
      );
    }
  }

  Future<void> _updateUserProfile() async {
    final String? loggedInEmail = SessionManager().userEmail;

    if (loggedInEmail != null) {
      final url = Uri.parse('https://g2izee01b8.execute-api.us-east-1.amazonaws.com/dev/user');

      final Map<String, String> requestBody = {
        'email': loggedInEmail,
        'codePostal': _postalCodeController.text,
        'address': _addressController.text,
        'ville': _cityController.text,
        'birthday': _birthdayController.text,
      };

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Échec de la mise à jour du profil : ${response.statusCode}')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email de l’utilisateur non trouvé dans la session')),
      );
    }
  }

  void _deconnecter() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Déconnecté')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage(title: 'Login UI')),
    );
  }

  void _addArticle() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddArticlePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Informations du Profil',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                enabled: false,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                ),
                enabled: false,
                obscureText: true,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _birthdayController,
                decoration: const InputDecoration(
                  labelText: 'Anniversaire',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre anniversaire';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre adresse';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _postalCodeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Code Postal',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre code postal';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'Ville',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre ville';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _updateUserProfile();
                        }
                      },
                      child: const Text('Valider'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addArticle,
                      child: const Text('Ajouter un Article'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _deconnecter,
                  child: const Text('Se déconnecter'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
