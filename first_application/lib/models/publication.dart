import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:first_application/models/comment.dart';

class Publication {
  String id;
  String title;
  String content;
  DateTime createdAt;
  DateTime updatedAt; // New field for date of modification
  List<Comment> comments;

  Publication({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt, // Initialize with createdAt when creating a new publication
    List<Comment>? comments,
  }) : comments = comments ?? [];

  factory Publication.fromMap(Map<String, dynamic> map) {
    return Publication(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
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
}
