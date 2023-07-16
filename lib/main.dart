// Flutter
import 'package:flutter/material.dart';
// Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'ColorTest.dart';
// Theme
import 'app_theme_data.dart' as theme;
// Pages
import 'auth_gate.dart';
import 'dog_list.dart';
import 'add_dog.dart';



void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: theme.appThemeData(context),
      home: const AuthGate(),
      routes: {
        '/dog_list' : (context) => DogList(),
        '/add_dog' : (context) => AddDog(),
      },
    );
  }
}

