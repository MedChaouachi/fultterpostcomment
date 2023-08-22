import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _register(BuildContext context) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Enregistrer les détails de l'utilisateur dans la collection "users" de Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': userCredential.user!.email,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
      });

      // L'utilisateur a été inscrit avec succès, afficher un message ou rediriger
      print('Inscription réussie: ${userCredential.user!.email}');
    } catch (e) {
      // Afficher un message d'erreur
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur d\'inscription'),
            content: Text('Une erreur est survenue lors de l\'inscription.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inscription'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _firstNameController,
              decoration: InputDecoration(labelText: 'Prénom'),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _lastNameController,
              decoration: InputDecoration(labelText: 'Nom'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _register(context),
              child: Text('Inscription'),
            ),
          ],
        ),
      ),
    );
  }
}
