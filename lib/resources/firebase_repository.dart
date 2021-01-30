

import 'package:MyDen/resources/auth_methods.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseMethods {
 final AuthService auth = AuthService();
 final _auth = FirebaseAuth.instance;

 Future<FirebaseUser> signUpWithEmail(String email, String password,String name) =>  auth.signUpWithEmailAndPassword(email, password,name);


 Future<FirebaseUser> signInWithEmail(String email, String password) =>  auth.signInWithEmailAndPassword(email, password);


 Future<FirebaseUser> getCurrentUser() => auth.getCurrentUser();


 Future<FirebaseUser> facebookIn() => auth.signInWithFacebook();
 Future<FirebaseUser> signIn() => auth.signInWithGoogle();
 Future<bool> authenticateUser(FirebaseUser user) => auth.authenticateUser(user);
 Future<void> addDataToDb(FirebaseUser user) => auth.addDataToDb(user);
 Future<void> addDataAfterSignUp(Map user) => auth.addDataAfterSignUp(user);


 Stream<FirebaseUser> get currentUser => _auth.onAuthStateChanged;
 Future<AuthResult> signInWithCredentail(AuthCredential credential) => _auth.signInWithCredential(credential);









}