import 'package:ecobin_app/user_management/models/UserModel.dart';
import 'package:ecobin_app/user_management/screens/wrapper.dart';
import 'package:ecobin_app/user_management/services/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserModel?>.value(
        initialData: UserModel(uid: ""),
        value: AuthServices().user,
        child: const MaterialApp(
          debugShowCheckedModeBanner: false,
          home: Wrapper(),
          initialRoute: '/',
          routes: {
            // '/login': (context) => LoginPage(),
            // other routes
          },
        ));
  }
}
