import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Auth {

  FirebaseAuth auth = FirebaseAuth.instance;

  User? getUser() {
    return auth.currentUser;
  }

  String? getUserId() {
    return auth.currentUser?.uid;
  }

  String? getUserEmail() {
    return auth.currentUser?.email;
  }

  Future<void> signOut() {
    return auth.signOut();
  }

}