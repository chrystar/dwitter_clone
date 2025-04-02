import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  final auth = FirebaseAuth.instance;

  Future<void> login() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        setState(() {
          _isLoading = false;
        });
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        if(e.code == 'invalid-email'){
          return;
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
              title: Text('Login'),
              centerTitle: true,
              leading: IconButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                icon: Icon(Icons.arrow_back),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
                child: Form(
                  key: formKey,
                  child: Column(
                    //mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
                      //login button
                      GestureDetector(
                        onTap: ()=> login(),
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Login',
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                
                      //forget password
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Forget password?",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ),
                
                      //google login
                      SizedBox(height: 50),
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(1, 1),
                              color: Colors.grey,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.g_mobiledata),
                            SizedBox(width: 20),
                            Text(
                              'Continue with Google',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        : Center(
          child: CircularProgressIndicator(
              backgroundColor: Colors.blue,
              color: Colors.blueAccent,
            ),
        );
  }
}
