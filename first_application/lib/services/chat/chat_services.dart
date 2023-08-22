import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ChatServices extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendMessage(String senderId, String receiverEmail, String message) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        final senderEmail = currentUser.email;
        final messageData = {
          'senderId': senderId,
          'senderEmail': senderEmail,
          'receiverEmail': receiverEmail,
          'text': message,
          'timestamp': FieldValue.serverTimestamp(),
        };
        await _firestore.collection('chats').add(messageData);
      } else {
        print('User is not logged in.');
      }
    } catch (e) {
      print('Error sending message: $e');
    }
  }
  Stream<QuerySnapshot<Map<String, dynamic>>> getChatMessages(String currentUserEmail, String recipientEmail) {
    return _firestore
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
  Future<String> getRecipientFullName(String email) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .get();

      if (userSnapshot.exists) {
        Map<String, dynamic> userData = userSnapshot.data() ?? {};
        String firstName = userData['firstName'] ?? '';
        String lastName = userData['lastName'] ?? '';

        if (firstName.isNotEmpty && lastName.isNotEmpty) {
          return '$firstName $lastName';
        } else {
          return 'Destinataire inconnu';
        }
      } else {
        return 'Destinataire inconnu';
      }
    } catch (error) {
      print('Erreur lors de la récupération du nom du destinataire: $error');
      return 'Erreur de récupération';
    }
  }




}
