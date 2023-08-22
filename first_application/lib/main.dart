import 'package:flutter/material.dart';
import 'package:first_application/pages/add_publication_page.dart';
import 'package:first_application/pages/PublicationsPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:first_application/services/chat/chat_services.dart'; // Assurez-vous d'importer correctement votre service de chat
import 'firebase_options.dart';
import 'package:first_application/pages/disqusintegration.dart';
import 'package:first_application/pages/RegisterPage.dart';
import 'package:first_application/pages/login_page.dart';
import 'package:provider/provider.dart'; // Importer Provider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider( // Ajouter le ChangeNotifierProvider ici
      create: (context) => ChatServices(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
