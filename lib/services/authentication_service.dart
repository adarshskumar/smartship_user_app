import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:smartshipemployee/screens/welcome_screen.dart';

class AuthService {
//  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  handleAuth(bool checkUserAlreadyLogin) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasData) {
          return WelcomeScreen();
        } else {
          return WelcomeScreen();
        }
      },
    );
  }

  signout() async {
    await FirebaseAuth.instance.signOut();
  }

  signin(AuthCredential authcred) {
    print("token");
    FirebaseAuth.instance.signInWithCredential(authcred).then(
        (value) => {print(value.credential), print(value.user.phoneNumber)});
  }

  signinwithOTP(otp, verId) {
    AuthCredential authcreds =
        PhoneAuthProvider.credential(verificationId: verId, smsCode: otp);
    signin(authcreds);
  }
}
