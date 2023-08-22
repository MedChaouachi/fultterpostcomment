import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_application/models/StaticUser.dart';
import 'package:first_application/pages/UserListPage.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _login(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      String userEmail = userCredential.user!.email!;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserListPage(userEmail)),
      );
    } catch (e) {
      showDialog(
        context: context, // Ajoutez ce paramètre
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur de connexion'),
            content: Text('Les informations de connexion sont incorrectes.'),
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
        title: Text('Login'),
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
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
