import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import 'session_manager.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer votre email et votre mot de passe')),
      );
      return;
    }

    final url = Uri.parse('https://g2izee01b8.execute-api.us-east-1.amazonaws.com/dev/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String body = responseBody['body'];

        final emailInResponse = jsonDecode(body)['email'];
        if (emailInResponse != null && emailInResponse == email) {
          // Set the user email globally on successful login
          SessionManager().userEmail = email;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Connexion réussie')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else {
          _showInvalidLoginMessage();
        }
      } else {
        _showInvalidLoginMessage();
      }
    } catch (e) {
      _showInvalidLoginMessage();
    }
  }

  
  void _showInvalidLoginMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email ou mot de passe invalide')),
    );
    print('Tentative de connexion invalide'); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tenshiy application'), 
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Se connecter',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 40,
              ),
            ),
            const SizedBox(
              height: 60,
            ),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    validator: (value) => EmailValidator.validate(value!)
                        ? null
                        : "Veuillez entrer un email valide",
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: 'Entrez votre email',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre mot de passe';
                      }
                      return null;
                    },
                    maxLines: 1,
                    obscureText: true,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.lock),
                      hintText: 'Entrez votre mot de passe',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _login();
                      } else {
                        print('Validation échouée : champs vides');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.fromLTRB(40, 15, 40, 15),
                    ),
                    child: const Text(
                      'Se connecter', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
