import 'package:dwitter_clone/features/screens/Login/login_screen.dart';
import 'package:dwitter_clone/features/screens/bottom_nav/bottom_nav.dart';
import 'package:dwitter_clone/features/screens/home_screen/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthState extends StatefulWidget {
  const AuthState({super.key});

  @override
  State<AuthState> createState() => _AuthStateState();
}

class _AuthStateState extends State<AuthState> {
  final _auth = FirebaseAuth.instance;

  Future<void> checkAuthState() async {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(
              backgroundColor: Colors.blue,
              color: Colors.orange,
            );
          }
          if (snapshot.hasData) {
            return BottomNav();
          } else {
            return LoginScreen();
          }
        });
  }
}
