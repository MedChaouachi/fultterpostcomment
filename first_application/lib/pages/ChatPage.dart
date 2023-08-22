import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_application/services/chat/chat_services.dart';
import 'package:intl/intl.dart'; // Pour formater la date et l'heure

class ChatPage extends StatefulWidget {
  final String currentUserEmail;
  final String recipientEmail;

  ChatPage(this.currentUserEmail, this.recipientEmail);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatServices _chatServices = ChatServices();
  final TextEditingController _messageController = TextEditingController();

  String recipientFullName = '';

  @override
  void initState() {
    super.initState();
    _fetchRecipientFullName();
  }

  Future<void> _fetchRecipientFullName() async {
    String fullName = await _chatServices.getRecipientFullName(widget.recipientEmail); // Remplacez cette ligne avec l'appel à votre service pour récupérer le nom complet du destinataire
    if (fullName.isNotEmpty) {
      setState(() {
        recipientFullName = fullName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipientFullName),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _chatServices.getChatMessages(widget.currentUserEmail, widget.recipientEmail),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                List<QueryDocumentSnapshot<Map<String, dynamic>>> messageDocs = snapshot.data!.docs;

                List<QueryDocumentSnapshot<Map<String, dynamic>>> filteredMessages = messageDocs.where((doc) {
                  Map<String, dynamic> messageData = doc.data()!;
                  String senderEmail = messageData['senderEmail'] ?? '';
                  String receiverEmail = messageData['receiverEmail'] ?? '';
                  return (senderEmail == widget.currentUserEmail && receiverEmail == widget.recipientEmail) ||
                      (senderEmail == widget.recipientEmail && receiverEmail == widget.currentUserEmail);
                }).toList();

                return ListView.builder(
                  reverse: true,
                  itemCount: filteredMessages.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> messageData = filteredMessages[index].data()!;
                    String message = messageData['text'] ?? '';
                    String senderId = messageData['senderId'] ?? '';
                    Timestamp? timestamp = messageData['timestamp']; // Notez l'utilisation de Timestamp?

                    bool isCurrentUser = senderId == widget.currentUserEmail;

                    String formattedTime = timestamp != null
                        ? DateFormat.yMMMMd().add_jm().format(timestamp.toDate())
                        : ''; // Si timestamp est null, formattedTime sera une chaîne vide

                    return Column(
                      crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isCurrentUser ? Colors.blue : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              message,
                              style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            formattedTime,
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(labelText: 'Message'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    String message = _messageController.text.trim();
                    if (message.isNotEmpty) {
                      _chatServices.sendMessage(widget.currentUserEmail, widget.recipientEmail, message);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
