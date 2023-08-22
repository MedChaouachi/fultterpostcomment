import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:first_application/pages/ChatPage.dart'; // Import the ChatPage

class UserListPage extends StatelessWidget {
  final String currentUserEmail; // Current user's email

  UserListPage(this.currentUserEmail);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Utilisateurs'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').where('email', isNotEqualTo: currentUserEmail).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<QueryDocumentSnapshot> userDocs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: userDocs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> userData = userDocs[index].data() as Map<String, dynamic>;
              String firstName = userData['firstName'] ?? '';
              String lastName = userData['lastName'] ?? '';
              String email = userData['email'] ?? '';
              String userId = userData['userId'] ?? '';

              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatPage(currentUserEmail, email), // Pass the current user's email and the recipient's email
                    ),
                  );
                },
                child: ListTile(
                  title: Text('$firstName $lastName'),
                  subtitle: Text(email),
                  trailing: Icon(Icons.message),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
