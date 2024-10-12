import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyBJTLL-PI4GFMYOXiIn29ALwOUYg_UFeuc",
            authDomain: "ecobin-16e9d.firebaseapp.com",
            projectId: "ecobin-16e9d",
            storageBucket: "ecobin-16e9d.appspot.com",
            messagingSenderId: "330593333648",
            appId: "1:330593333648:web:9f9db2efbcdee29bb8c315",
            measurementId: "G-CWLWLZEPET"));
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
