import 'dart:async';
import 'package:flutter/material.dart';

import 'U_Grub/app.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'U_Grub/login.dart';

void main() {
  GoogleSignInAccount user;
   login().then((GoogleSignIn g){
    user = g.currentUser;
    runApp(new GrubApp(user: user,));
  });

}

Future<GoogleSignIn> login() async {
  await ensureLoggedIn();
  return googleSignIn;
}

