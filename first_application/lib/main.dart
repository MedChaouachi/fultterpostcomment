import 'package:flutter/material.dart';
import 'package:first_application/pages/add_publication_page.dart';
import 'package:first_application/pages/PublicationsPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PublicationsPage(),
    );
  }
}
