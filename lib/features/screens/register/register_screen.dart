import 'package:dwitter_clone/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _fireStore = FirebaseFirestore.instance;
  bool _isLoading = false;

  Future<void> register() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        // final UserCredential userCredential =
        //     await _auth.createUserWithEmailAndPassword(
        //   email: _emailController.text.trim(),
        //   password: _passwordController.text.trim(),
        // );
        // await _fireStore.collection('users').doc(userCredential.user!.uid).set(
        //   {
        //     "userName": _nameController.text.trim(),
        //     "displayName": _nameController.text.trim(),
        //   },
        // );

        final authProvider = Provider.of<AuthProviders>(context, listen: false);
        final UserModel? registeredUserModel = await authProvider.registerUser(
            _emailController.text.trim(),
            _passwordController.text.trim(),
            UserModel(
              email: _emailController.text.trim(),
              name: _nameController.text.trim(),
              profileImage: '',
              createdAt: DateTime.now(),
            ),
            context);
        setState(() {
          _isLoading = false;
        });

        if (registeredUserModel != null) {
          // Registration successful
          final String? uid = registeredUserModel.uid; // Get the UID
          print('User UID: $uid'); // Use the UID

          if (context.mounted) {
            Navigator.pushReplacementNamed(context, '/home'); // Navigate
          }
        } else {
          // Registration failed
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration failed')),
            );
          }
        }

        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('email has already been used'),
            ),
          );
        }
        print(e.code);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading == false
        ? Scaffold(
            appBar: AppBar(
              title: Text('Register'),
              centerTitle: true,
              automaticallyImplyLeading: false,
            ),
            body: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        label: Text('username'),
                        filled: true,
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'please enter username';
                        }
                      },
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        label: Text('Email'),
                        filled: true,
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'please enter a valide email';
                        }
                      },
                    ),
                    SizedBox(height: 30),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        label: Text('Password'),
                        filled: true,
                        border: InputBorder.none,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'please enter password';
                        }
                        if (value.length < 6) {
                          return 'password must be more than 6';
                        }
                      },
                    ),
                    SizedBox(height: 40),
                    GestureDetector(
                      onTap: () {
                        _isLoading;
                        register();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Register',
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: 'Already have an account?',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: 'Login',
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Navigator.pushReplacementNamed(
                                context, '/login'),
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          )
        : Center(
          child: CircularProgressIndicator(
              backgroundColor: Colors.blue,
            ),
        );
  }
}
