import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/publication.dart';
import '../models/comment.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> addPublication(Publication publication) async {
    await _firestore.collection('publications').add({
      'title': publication.title,
      'content': publication.content,
      'imageUrls': publication.imageUrls, // Add the image filenames to the new publication
      'createdAt': publication.createdAt,
      'updatedAt': publication.createdAt, // Set updatedAt to the same value as createdAt when adding a new publication
    });
  }

  Future<void> updatePublication(String publicationId, Publication updatedPublication) async {
    CollectionReference publications = _firestore.collection('publications');
    DocumentReference publicationRef = publications.doc(publicationId);

    // Set the updatedAt field to the current date
    DateTime updatedAt = DateTime.now();

    await publicationRef.update({
      'title': updatedPublication.title,
      'content': updatedPublication.content,
      'imageUrls': updatedPublication.imageUrls, // Update the image filenames
      'updatedAt': updatedAt, // Update the updatedAt field with the current date
    });
  }

  Future<List<Publication>> getPublications() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('publications').orderBy('createdAt', descending: true).get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        DateTime createdAt = data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now();
        DateTime updatedAt = data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : createdAt;
        return Publication(
          id: doc.id,
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          imageUrls: List<String>.from(data['imageUrls'] ?? []), // Convert imageUrls to a list of strings
          createdAt: createdAt,
          updatedAt: updatedAt,
        );
      }).toList();
    } catch (error) {
      // Handle errors, e.g., if the collection does not exist.
      print('Error getting publications: $error');
      return [];
    }
  }



  Future<void> deletePublication(String publicationId) async {
    CollectionReference publications = _firestore.collection('publications');
    DocumentReference publicationRef = publications.doc(publicationId);
    await publicationRef.delete();
  }



  Future<Publication?> getPublicationById(String publicationId) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('publications').doc(publicationId).get();
      if (snapshot.exists) {
        return Publication.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    } catch (error) {
      // Handle errors, e.g., if the document does not exist.
      print('Error getting publication by ID: $error');
      return null;
    }
  }

  Future<void> addComment(String publicationId, Comment comment) async {
    CollectionReference publications = _firestore.collection('publications');
    DocumentReference publicationRef = publications.doc(publicationId);

    await publicationRef.update({
      'comments': FieldValue.arrayUnion([
        {
          'id': comment.id,
          'content': comment.content,
          'createdAt': Timestamp.fromDate(comment.createdAt),
          'updatedAt': Timestamp.fromDate(comment.updatedAt), // Save updatedAt as a Timestamp
          'publicationId': comment.publicationId,
        },
      ]),
    });
  }

  Future<void> updateComment(String commentId, String publicationId, Comment updatedComment) async {
    try {
      CollectionReference publications = _firestore.collection('publications');
      DocumentReference publicationRef = publications.doc(publicationId);

      // Get the current publication data
      DocumentSnapshot publicationSnapshot = await publicationRef.get();

      if (publicationSnapshot.exists) {
        Map<String, dynamic>? publicationData = publicationSnapshot.data() as Map<String, dynamic>?;

        if (publicationData != null) {
          List<dynamic> comments = publicationData['comments'] ?? [];

          // Find the index of the comment with the given ID
          int commentIndex = comments.indexWhere((comment) => comment['id'] == commentId);

          if (commentIndex != -1) {
            // Update the comment at the specific index
            comments[commentIndex] = {
              'id': commentId,
              'content': updatedComment.content,
              'createdAt': Timestamp.fromDate(updatedComment.createdAt),
              'updatedAt': Timestamp.now(), // Update the updatedAt field with the current date
              'publicationId': updatedComment.publicationId,
            };

            // Update the publication with the updated comments list
            await publicationRef.update({
              'comments': comments,
            });
          }
        }
      } else {
        // Handle the case where the publication does not exist, if necessary
      }
    } catch (e) {
      // Handle errors as needed
      print('Error updating comment: $e');
    }
  }


  Future<void> deleteComment(String commentId, String publicationId) async {
    try {
      CollectionReference publications = _firestore.collection('publications');
      DocumentReference publicationRef = publications.doc(publicationId);

      // Get the current publication data
      DocumentSnapshot publicationSnapshot = await publicationRef.get();

      if (publicationSnapshot.exists) {
        Map<String, dynamic>? publicationData = publicationSnapshot.data() as Map<String, dynamic>?;

        if (publicationData != null) {
          List<dynamic> comments = publicationData['comments'] ?? [];

          // Find the index of the comment with the given ID
          int commentIndex = comments.indexWhere((comment) => comment['id'] == commentId);

          if (commentIndex != -1) {
            // Remove the comment from the list
            comments.removeAt(commentIndex);

            // Update the publication with the updated comments list
            await publicationRef.update({
              'comments': comments,
            });
          }
        }
      } else {
        // Handle the case where the publication does not exist, if necessary
      }
    } catch (e) {
      // Handle errors as needed
      print('Error deleting comment: $e');
    }
  }

  Future<List<Comment>> getComments(String publicationId) async {
    try {
      DocumentSnapshot publicationSnapshot = await _firestore.collection('publications').doc(publicationId).get();

      if (publicationSnapshot.exists) {
        Map<String, dynamic>? publicationData = publicationSnapshot.data() as Map<String, dynamic>?;

        if (publicationData != null) {
          dynamic commentsData = publicationData['comments'];

          if (commentsData is List) {
            // Handle the case where the 'comments' field is already a list
            List<Comment> comments = commentsData.map((commentData) {
              if (commentData != null) {
                return Comment(
                  id: commentData['id'] ?? '',
                  content: commentData['content'] ?? '',
                  createdAt: _parseCreatedAt(commentData['createdAt']),
                  updatedAt: _parseUpdatedAt(commentData['updatedAt']), // Parse updatedAt
                  publicationId: commentData['publicationId'] ?? '',
                );
              } else {
                // Handle the case where a commentData is null (optional)
                return Comment(id: '', content: '', createdAt: DateTime.now(), updatedAt: DateTime.now(), publicationId: '');
              }
            }).toList();

            return comments;
          } else if (commentsData is Map) {
            // Handle the case where the 'comments' field is a map
            List<Comment> comments = commentsData.values.map((commentData) {
              if (commentData != null) {
                return Comment(
                  id: commentData['id'] ?? '',
                  content: commentData['content'] ?? '',
                  createdAt: _parseCreatedAt(commentData['createdAt']),
                  updatedAt: _parseUpdatedAt(commentData['updatedAt']), // Parse updatedAt
                  publicationId: commentData['publicationId'] ?? '',
                );
              } else {
                // Handle the case where a commentData is null (optional)
                return Comment(id: '', content: '', createdAt: DateTime.now(), updatedAt: DateTime.now(), publicationId: '');
              }
            }).toList();

            return comments;
          }
        }
      }

      // The publication with the given ID does not exist or has no comments.
      // You can handle this according to your needs, such as returning an empty list.
      return [];
    } catch (error) {
      // Handle errors, e.g., if the document or field does not exist.
      print('Error getting comments: $error');
      return [];
    }
  }

  static DateTime _parseCreatedAt(dynamic createdAtData) {
    if (createdAtData is Timestamp) {
      // If it's already a Timestamp, return the toDate()
      return createdAtData.toDate();
    } else if (createdAtData is String) {
      // If it's a String, parse it into DateTime
      return DateTime.parse(createdAtData);
    } else {
      // If it's neither Timestamp nor String, return the current time (or handle accordingly)
      return DateTime.now();
    }
  }
  static DateTime _parseUpdatedAt(dynamic updatedAtData) {
    if (updatedAtData is Timestamp) {
      // If it's already a Timestamp, return the toDate()
      return updatedAtData.toDate();
    } else if (updatedAtData is String) {
      // If it's a String, parse it into DateTime
      return DateTime.parse(updatedAtData);
    } else {
      // If it's neither Timestamp nor String, return the current time (or handle accordingly)
      return DateTime.now();
    }
  }

}
