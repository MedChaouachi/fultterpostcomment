import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:first_application/models/publication.dart';
import 'package:first_application/models/comment.dart';
import 'package:first_application/services/database_service.dart';
import 'package:first_application/pages/add_publication_page.dart';

class PublicationsPage extends StatefulWidget {
  @override
  _PublicationsPageState createState() => _PublicationsPageState();
}
Publication? selectedPublication;

class _PublicationsPageState extends State<PublicationsPage> {
  final DatabaseService _databaseService = DatabaseService();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');
  Publication? publication;

  Future<void> _refreshPublications() async {
    // Récupérer les publications à partir de la source de données externe (par exemple, une base de données)
    List<Publication> publications = await _databaseService.getPublications();

    // Mettre à jour l'état du widget avec les nouvelles publications récupérées
    setState(() {
      // Assurez-vous que vous avez une liste de publications pour la mettre à jour.
      // Si la liste est null, créez-en une nouvelle pour éviter une erreur.
      // Vous pouvez utiliser une liste vide [] comme valeur par défaut.
      publications = publications ?? [];
    });
  }

  Future<void> _refreshPublication2() async {
    setState(() {
      selectedPublication = null; // Réinitialiser la publication sélectionnée pour cacher les commentaires
    });
    await _refreshPublications(); // Actualiser la liste des publications
  }


  void _showEditPublicationDialog(String publicationId) async {
    Publication? currentPublication =
    await _databaseService.getPublicationById(publicationId);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier la publication'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: currentPublication?.title,
                  decoration: InputDecoration(labelText: 'Titre'),
                  onChanged: (value) {
                    if (currentPublication != null) {
                      currentPublication.title = value;
                    }
                  },
                ),
                TextFormField(
                  initialValue: currentPublication?.content,
                  decoration: InputDecoration(labelText: 'Contenu'),
                  onChanged: (value) {
                    if (currentPublication != null) {
                      currentPublication.content = value;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Enregistrer'),
              onPressed: () {
                _databaseService
                    .updatePublication(publicationId, currentPublication!)
                    .then((_) {
                  _refreshPublications();
                  Navigator.of(context).pop();
                });
              },
            ),
          ],
        );
      },
    );
  }



  void _showAddCommentDialog(String publicationId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController commentController = TextEditingController();

        return AlertDialog(
          title: Text('Ajouter un commentaire'),
          content: SingleChildScrollView(
            child: TextFormField(
              controller: commentController,
              decoration: InputDecoration(labelText: 'Commentaire'),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Ajouter'),
              onPressed: () {
                String commentContent = commentController.text.trim();
                if (commentContent.isNotEmpty) {
                  String commentId = Comment.generateUniqueId(commentContent, DateTime.now(), publicationId);
                  Comment comment = Comment(
                    id: commentId,
                    content: commentContent,
                    createdAt: DateTime.now(),
                    updatedAt:  DateTime.now(),// Use DateTime.now() as the default value if null
                    publicationId: publicationId,
                  );

                  _databaseService.addComment(publicationId, comment).then((_) {
                    _refreshPublications();
                    Navigator.of(context).pop();
                  });
                }
              },
            ),
          ],
        );
      },
    );
  }




  void _showCommentsDialog(Publication publication) async {
    List<Comment> comments = await _databaseService.getComments(publication.id);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Commentaires'),
          content: Container(
            width: double.maxFinite,
            height: 300, // Adjust the height as needed
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                Comment comment = comments[index];
                String formattedCreatedAt = _formatDateTime(comment.createdAt);
                String formattedUpdatedAt = _formatDateTime(comment.updatedAt); // Get formatted updatedAt
                return ListTile(
                  title: Text(comment.content),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date de création : $formattedCreatedAt'),
                      if (comment.updatedAt != comment.createdAt)
                        Text('Date de modification : $formattedUpdatedAt'),// Display the date of modification
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          _showEditCommentDialog(comment, publication);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          _deleteComment(publication, comment);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              child: Text('Fermer'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the comments dialog
              },
            ),
          ],
        );
      },
    );
  }


  void _showEditCommentDialog(Comment comment, Publication publication) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController commentController = TextEditingController(text: comment.content);

        return AlertDialog(
          title: Text('Modifier le commentaire'),
          content: SingleChildScrollView(
            child: TextFormField(
              controller: commentController,
              decoration: InputDecoration(labelText: 'Commentaire'),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Enregistrer'),
              onPressed: () async {
                String updatedContent = commentController.text.trim();
                if (updatedContent.isNotEmpty) {
                  Comment updatedComment = Comment(
                    id: comment.id,
                    content: updatedContent,
                    createdAt: comment.createdAt,
                    updatedAt: DateTime.now(),
                    publicationId: comment.publicationId,
                  );

                  await _databaseService.updateComment(comment.id, publication.id, updatedComment);
                 // _refreshComments(publication.id); // Refresh comments using the publication's ID
                  Navigator.of(context).popUntil((route) => route.isFirst); // Close the edit comment dialog
                 // _showCommentsDialog(publication); // Show the updated comments dialog
                  _refreshPublications();
                }
              },
            ),
          ],
        );
      },
    );
  }

//



  void _deleteComment(Publication publication, Comment comment) {
    if (publication == null) {
      // Publication is null, return without deleting the comment
      print("mafamech publication");
      return;
    }

    if (comment == null) {
      // Comment is null, return without deleting the comment
      print("mafamech commentaire ");
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text('Êtes-vous sûr de vouloir supprimer ce commentaire ?'),
          actions: [
            TextButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the confirmation dialog
              },
            ),
            TextButton(
              child: Text('Supprimer'),
              onPressed: () {
                _databaseService.deleteComment(comment.id, publication.id).then((_) {
                  Navigator.of(context).popUntil((route) => route.isFirst); // Close all dialogs and return to the first screen
                 // _showCommentsDialog(publication); // Show the updated comments dialog
                  _refreshPublications();
                });
              },
            ),
          ],
        );
      },
    );
  }








  String _formatDateTime(DateTime dateTime) {
    return _dateFormat.format(dateTime);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight + MediaQuery.of(context).padding.top),
        child: AppBar(
          title: Text('Publications'),
          backgroundColor: Colors.blue,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPublications,
        child: FutureBuilder<List<Publication>>(
          future: _databaseService.getPublications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              List<Publication> publications = snapshot.data!;
              return ListView.builder(
                itemCount: publications.length,
                itemBuilder: (context, index) {
                  Publication publication = publications[index];
                  String formattedDateTime = _formatDateTime(publication.createdAt);
                  String formattedDateTime1 = _formatDateTime(publication.updatedAt);
                  return Card(
                    child: ExpansionTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(publication.title),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  _showEditPublicationDialog(publication.id);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _databaseService.deletePublication(publication.id).then((_) {
                                    _refreshPublications();
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.add_comment),
                                onPressed: () {
                                  _showAddCommentDialog(publication.id);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(publication.content),
                          Text('Date de création : $formattedDateTime'),
                          if (publication.updatedAt != publication.createdAt)
                            Text('Date de modification : $formattedDateTime1'),
                        ],
                      ),
                      children: [
                        // Display the images for the publication
                        if (publication.imageUrls.isNotEmpty)
                          GridView.builder(
                            shrinkWrap: true,
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // Number of columns in the grid
                            ),
                            itemCount: publication.imageUrls.length,
                            itemBuilder: (context, index) {
                              return Image.network(publication.imageUrls[index]);
                            },
                          ),

                        FutureBuilder<List<Comment>>(
                          future: _databaseService.getComments(publication.id),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            } else if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            } else {
                              List<Comment> comments = snapshot.data!;
                              return Column(
                                children: comments.map((comment) {
                                  String formattedCreatedAt = _formatDateTime(comment.createdAt);
                                  String formattedUpdatedAt = _formatDateTime(comment.updatedAt);
                                  return ListTile(
                                    title: Text(comment.content),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Date de création : $formattedCreatedAt'),
                                        if (comment.updatedAt != comment.createdAt)
                                          Text('Date de modification : $formattedUpdatedAt'),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit),
                                          onPressed: () {
                                            _showEditCommentDialog(comment, publication);
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () {
                                            _deleteComment(publication, comment);
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddPublicationPage()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
//flutter run -d chrome --web-renderer html
