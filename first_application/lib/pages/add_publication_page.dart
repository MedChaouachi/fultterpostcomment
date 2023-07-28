import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:first_application/models/publication.dart';
import 'package:first_application/services/database_service.dart';
import 'package:first_application/pages/PublicationsPage.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:html' as html;
import 'package:firebase_storage_web/firebase_storage_web.dart' as firebase_storage_web;

class AddPublicationPage extends StatefulWidget {
  @override
  _AddPublicationPageState createState() => _AddPublicationPageState();
}

class _AddPublicationPageState extends State<AddPublicationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  final DatabaseService _databaseService = DatabaseService();
  List<String> imageUrls = [];

  String? validateNonEmpty(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ce champ ne peut pas être vide';
    }
    return null;
  }

  Future<void> addPublicationWithImages() async {
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
        imageUrls: imageUrls,
      );

      await _databaseService.addPublication(publication);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PublicationsPage()),
      );
    }
  }

  List<XFile> publicationImages = [];

  Future<void> _getImagesFromGallery() async {
    List<XFile> resultList = [];

    if (kIsWeb) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );
      if (result != null && result.files.isNotEmpty) {
        for (var file in result.files) {
          resultList.add(XFile.fromData(Uint8List.fromList(file.bytes!), name: file.name));
        }
      }
    } else {
      final picker = ImagePicker();
      List<XFile>? pickedFiles;

      try {
        pickedFiles = await picker.pickMultiImage(
          maxWidth: 1800,
          maxHeight: 1800,
        );
      } catch (e) {
        print('Error picking images: $e');
      }

      if (pickedFiles != null && pickedFiles.isNotEmpty) {
        resultList.addAll(pickedFiles);
      }
    }

    setState(() {
      publicationImages = resultList;
      print(publicationImages);
    });
  }

  Future<void> _uploadImagesToStorageAndRetrieveUrl() async {
    for (var image in publicationImages) {
      String imageUrl;
      if (kIsWeb) {
        imageUrl = await uploadImageToStorageAndRetrieveUrlWeb(image);
      } else {
        imageUrl = await uploadImageToStorageAndRetrieveUrlMobile(image);
      }

      if (imageUrl.isNotEmpty) {
        imageUrls.add(imageUrl);
      }
    }
    print("Image URLs: $imageUrls");
  }

  // Inside _uploadImagesToStorageAndRetrieveUrlWeb() method
  Future<String> uploadImageToStorageAndRetrieveUrlWeb(XFile image) async {
    try {
      String imageName = Uuid().v4() + ".jpg";
      firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance.ref().child("images").child(imageName);

      firebase_storage.UploadTask uploadTask = ref.putData(await image.readAsBytes());

      firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }



  Future<String> uploadImageToStorageAndRetrieveUrlMobile(XFile image) async {
    try {
      firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;
      String imageName = Uuid().v4() + ".jpg";
      firebase_storage.Reference ref = storage.ref().child("images").child(imageName);

      firebase_storage.UploadTask uploadTask = ref.putFile(File(image.path));

      firebase_storage.TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  bool isLoading = false;
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: titleController,
                  validator: validateNonEmpty,
                  decoration: InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: contentController,
                  validator: validateNonEmpty,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Contenu',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  child: Text('Ajouter des images'),
                  onPressed: () {
                    _getImagesFromGallery();
                  },
                ),

                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 20.0),
                  child: Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: const BoxDecoration(
                      color: Color(0xFFDBE2E7),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: publicationImages
                            .map((image) => Image.network(
                          image.path!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ))
                            .toList(),
                      ),
                    ),
                  ),
                ),

                ElevatedButton(
                  child: Text('Ajouter'),
                  onPressed: () async {
                    if (isLoading) return; // Do nothing if the upload is already in progress
                    setState(() {
                      isLoading = true; // Set loading to true before starting upload
                    });

                    await _uploadImagesToStorageAndRetrieveUrl();
                    addPublicationWithImages().then((_) {
                      setState(() {
                        isLoading = false; // Set loading to false after the upload is complete
                      });
                    });
                  },
                ),

                // Display loading indicator while uploading images
                if (isLoading)
                  Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }


}
