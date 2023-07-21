import 'package:flutter/material.dart';
import 'package:first_application/models/publication.dart';
import 'package:first_application/models/comment.dart';
import 'package:first_application/services/database_service.dart';
import 'package:first_application/pages/PublicationsPage.dart';

class AddPublicationPage extends StatefulWidget {
  @override
  _AddPublicationPageState createState() => _AddPublicationPageState();
}

class _AddPublicationPageState extends State<AddPublicationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  final DatabaseService _databaseService = DatabaseService();

  String? validateNonEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ ne peut pas être vide';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter une publication'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Titre',
                ),
                validator: validateNonEmpty,
              ),
              TextFormField(
                controller: contentController,
                decoration: InputDecoration(
                  labelText: 'Contenu',
                ),
                validator: validateNonEmpty,
              ),
              ElevatedButton(
                child: Text('Ajouter'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    String title = titleController.text;
                    String content = contentController.text;
                    DateTime createdAt = DateTime.now();
                    Publication publication = Publication(
                      id: '',
                      title: title,
                      content: content,
                      createdAt: createdAt,
                      updatedAt: createdAt,
                    );


                    await _databaseService.addPublication(publication);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => PublicationsPage()),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}