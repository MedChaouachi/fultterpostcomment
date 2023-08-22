import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String senderEmail; // New property
  final String receiverEmail; // Replace receiverId with receiverEmail
  final String message;
  final Timestamp timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.senderEmail,
    required this.receiverEmail,
    required this.message,
    required this.timestamp,
  });

  factory Message.fromSnapshot(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Message(
      id: snapshot.id,
      senderId: data['senderId'] ?? '',
      senderEmail: data['senderEmail'] ?? '',
      receiverEmail: data['receiverEmail'] ?? '', // Replace receiverId with receiverEmail
      message: data['text'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}
