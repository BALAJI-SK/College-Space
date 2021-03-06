import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../screens/Profile/ProfileHelpers.dart';

class Authentication with ChangeNotifier
{
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  String userUid;
  String get  getUserUid {
    return userUid;
  }
  Future logIntoAccount(BuildContext context,String email, String password) async{
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      userUid= FirebaseAuth.instance.currentUser.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
      warningText(context,'No user found for that email.');
      } else if (e.code == 'wrong-password') {
        warningText(context,'Wrong password provided for that user.');
      }
    }

    print(userUid);
    notifyListeners();
  }

  Future createAccount(String email, String password) async{

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      userUid= FirebaseAuth.instance.currentUser.uid;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password providederrorMessage = e.toString(); is too weak.');

      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }

    print(userUid);
    notifyListeners();
  }

  Future logOutViaEmail(){
    return firebaseAuth.signOut();
  }


  Future signInWithGoogle() async{

    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
    final AuthCredential authCredential =  GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken
    );
    final UserCredential userCredential = await firebaseAuth.signInWithCredential(authCredential);
    final User user = userCredential.user;
    assert(user.uid != null);

    userUid = user.uid;
    print("Google user UID => $userUid");
    notifyListeners();
  }

  Future signOutWithGoogle() async{
    return googleSignIn.signOut();
  }
  warningText(BuildContext context, String warning) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
                color: constantColors.darkColor,
                borderRadius: BorderRadius.circular(15.0)),
            height: MediaQuery.of(context).size.height * 0.12,
            width: MediaQuery.of(context).size.width,
            child: Center(
              child: Text(
                warning,
                style: TextStyle(
                    color: constantColors.whiteColor,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          );
        });
  }
}