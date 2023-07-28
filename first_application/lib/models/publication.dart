import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_application/models/comment.dart';

class Publication {
  String id;
  String title;
  String content;
  List<String> imageUrls; // List of image URLs
  DateTime createdAt;
  DateTime updatedAt; // New field for date of modification
  List<Comment> comments;


  Publication({
    required this.id,
    required this.title,
    required this.content,
    required this.imageUrls, // Initialize with an empty list for multiple image URLs
    required this.createdAt,
    required this.updatedAt, // Initialize with createdAt when creating a new publication
    List<Comment>? comments,
  }) : comments = comments ?? [];

  factory Publication.fromMap(Map<String, dynamic> map) {
    List<dynamic> imageUrlsData = map['imageUrls'] ?? [];
    List<String> imageUrls = List<String>.from(imageUrlsData);

    return Publication(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrls: imageUrls,
      createdAt: map['createdAt'] != null ? (map['createdAt'] as Timestamp).toDate() : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? (map['updatedAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  set setTitle(String title) {
    this.title = title;
  }

  set setContent(String content) {
    this.content = content;
  }

  // Add a method to add image URLs
  void addImageUrl(String imageUrl) {
    imageUrls.add(imageUrl);
  }

  // Add a method to remove image URLs
  void removeImageUrl(String imageUrl) {
    imageUrls.remove(imageUrl);
  }
  String get imageUrl => imageUrls.isNotEmpty ? imageUrls.first : '';

  // Define the setter for imageUrl
  set imageUrl(String value) {
    if (imageUrls.isEmpty) {
      imageUrls.add(value);
    } else {
      imageUrls[0] = value;
    }
  }
}
