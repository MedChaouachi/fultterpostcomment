import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String id;
  String content;
  DateTime createdAt;
  DateTime updatedAt;
  String publicationId;


  Comment({
    required this.id,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.publicationId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String), // Add the updatedAt field
      publicationId: json['publicationId'] ?? '',
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'publicationId': publicationId, // Assurez-vous de l'inclure dans la sauvegarde de JSON
    };
  }

  factory Comment.fromFirestore(Map<String, dynamic> data) {
    return Comment(
      id: data['id'],
      content: data['content'],
      createdAt: (data['createdAt'] is Timestamp) ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
      updatedAt: (data['updatedAt'] is Timestamp) ? (data['updatedAt'] as Timestamp).toDate() : DateTime.now(), // Add the updatedAt field
      publicationId: data['publicationId'],
    );
  }

  static String generateUniqueId(String content, DateTime createdAt, String publicationId) {
    // Ici, vous pouvez utiliser une logique pour générer un ID unique.
    // Par exemple, vous pouvez concaténer le contenu, la date de création et l'ID de publication
    // pour former un ID unique.
    String uniqueId = '$content-${createdAt.toIso8601String()}-$publicationId';
    // Vous pouvez également utiliser une librairie pour générer un ID aléatoire si vous préférez.
    return uniqueId;
  }

}
