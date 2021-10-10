import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';

class FirebaseAuthController{
  static Future<User?> signIn ({ required String email, required String password}) async {
   UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
  return userCredential.user;
  }

  static Future<void> signOut() async{
    await FirebaseAuth.instance.signOut();
  }
}
