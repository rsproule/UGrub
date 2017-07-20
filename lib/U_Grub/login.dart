import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';


import 'dart:async';

//routing (if I need it)


final googleSignIn = new GoogleSignIn();
final firebaseAnalytics = new FirebaseAnalytics();
final auth = FirebaseAuth.instance;

Future<Null> ensureLoggedIn() async {
  GoogleSignInAccount user = googleSignIn.currentUser;
  if (user == null)
    user = await googleSignIn.signInSilently();
  if(user != null){
    firebaseAnalytics.logLogin();
  }
  if (user == null) {
    await googleSignIn.signIn();
    firebaseAnalytics.logSignUp(signUpMethod: "Google");
  }
  //auth
  if (auth.currentUser == null) {
    GoogleSignInAuthentication credentials =
    await googleSignIn.currentUser.authentication;
    await auth.signInWithGoogle(
      idToken: credentials.idToken,
      accessToken: credentials.accessToken,
    );
  }

}

login() async {
  await ensureLoggedIn();
}