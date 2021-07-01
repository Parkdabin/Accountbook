import 'package:account_book/sign/signin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'mainscreen/mainscreen.dart';

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        // Initialize FlutterFire:
        future: _initialization,
        builder: (context, snapshot) {
          // Check for errors
          if (snapshot.hasError) {
            return Center(
              child: Text('firebase loading falied'),
            );
          }

          // Once complete, show your application
          if (snapshot.connectionState == ConnectionState.done) {
            return StreamBuilder<User?>(
                stream: FirebaseAuth.instance.authStateChanges(),
                builder: (BuildContext context, AsyncSnapshot<User?> user) {
                  if (user.hasData) {
                    return MainScreen();
                  } else {
                    return SignIn();
                  }
                });
          }

          // Otherwise, show something whilst waiting for initialization to complete
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 10.0,
                ),
                Text(
                  '가계부',
                  style: GoogleFonts.doHyeon(
                      fontSize: 50.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[200]),
                ),
                Text(
                  'Loading',
                  style: GoogleFonts.doHyeon(
                      fontSize: 20.0, color: Colors.grey[600]),
                ),
                Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Text('Copyright 2021. dabin'),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
