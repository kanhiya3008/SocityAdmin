import 'package:MyDen/model/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
class AuthService {
 final FirebaseAuth _auth = FirebaseAuth.instance;
 GoogleSignIn _googleSignIn = GoogleSignIn();
 static final Firestore firestore = Firestore.instance;


 UserData userData = UserData();
 Future<FirebaseUser> getCurrentUser() async {
   FirebaseUser currentUser;
   currentUser = await _auth.currentUser();
   print(currentUser.uid);
   return currentUser;
 }

 Future<FirebaseUser> signInWithEmailAndPassword(String email, String password) async {
   try {
     AuthResult result = await _auth.signInWithEmailAndPassword(
         email: email, password: password);
     FirebaseUser user = result.user;
     return user;
   } catch (e) {
     throw e;
   }
 }
 Future<FirebaseUser> signUpWithEmailAndPassword(String email, String password,String name) async {
   try {
     AuthResult result = await _auth.createUserWithEmailAndPassword(
         email: email, password: password);
     FirebaseUser user = result.user;

     return user;
   } catch (e) {
     print(e.toString());
     return null;
   }
 }


 Future resetPass(String email) async {
   try {
     return await _auth.sendPasswordResetEmail(email: email);
   } catch (e) {
     print(e.toString());
     return null;
   }
 }



 Future<FirebaseUser> signInWithGoogle() async {
   GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
   GoogleSignInAuthentication _signInAuthentication =
   await _signInAccount.authentication;

   final AuthCredential credential = GoogleAuthProvider.getCredential(
       accessToken: _signInAuthentication.accessToken,
       idToken: _signInAuthentication.idToken);
   AuthResult result = await _auth.signInWithCredential(credential);
   FirebaseUser userDetails = result.user;
   return userDetails;
 }

 Future<FirebaseUser> signInWithFacebook() async{

 }






















 Future<bool> authenticateUser(FirebaseUser user) async {
   QuerySnapshot result = await firestore
       .collection("users")
       .where("email", isEqualTo: user.email)
       .getDocuments();

   final List<DocumentSnapshot> docs = result.documents;
   return docs.length == 0 ? true : false;
 }


 Future<void> addDataToDb(FirebaseUser currentUser) async {
   userData = UserData(
     uid: currentUser.uid,
     email: currentUser.email,
     name: currentUser.displayName,
     profilePhoto: currentUser.photoUrl,
   );
   firestore
       .collection("users")
       .document(currentUser.uid)
       .setData(userData.toJson());
 }
 Future<void> addDataAfterSignUp(Map currentUser) async {
   userData = UserData(
     uid: currentUser["uid"],
     email: currentUser["email"],
     name: currentUser["nickname"],
     profilePhoto: currentUser["photoUrl"],
     gender: currentUser["gender"]
   );

   firestore
       .collection("users")
       .document(currentUser["uid"])
       .setData(userData.toJson());
 }


 Future signOut() async {
   try {
     return await _auth.signOut();
   } catch (e) {
     print(e.toString());
     return null;
   }
 }




}




