import 'package:dwitter_clone/features/auth/authstate/auth_state.dart';
import 'package:dwitter_clone/features/screens/Login/login_screen.dart';
import 'package:dwitter_clone/features/screens/home_screen/home_page.dart';
import 'package:dwitter_clone/features/screens/register/register_screen.dart';
import 'package:dwitter_clone/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthState(),
        '/register': (context) => RegisterScreen(),
        '/login': (context) => LoginScreen(),
        '/home': (context) => HomePage(),
      },
    );
  }
}


