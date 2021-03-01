import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csulb_dsc_2021/services/database.dart';
import '../../services/helper/helperFunctions.dart';
import 'package:flutter/material.dart';

import '../../services/auth.dart';

import './register.dart';

// Widgets
import '../../widgets/graphics.dart';
import '../loading.dart';

class Login extends StatefulWidget {
  static const routeName = '/login';

  LoginState createState() => LoginState();
}

class LoginState extends State<Login> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  var loading = false;

  final _passwordFocusNode = FocusNode();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  String error = '';

  List<String> occupation = [
    "Student",
    "Donor",
  ];
  String selectedLocation;

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      SizedBox(height: 100),
                      Logo(),
                      Container(
                        padding: const EdgeInsets.only(
                          left: 15,
                          right: 15,
                        ),
                        height: 100,
                        child: Center(
                          child: Text(
                            "Hermes",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                          left: 15,
                          right: 15,
                          top: 0,
                          bottom: 15,
                        ),
                        height: 90,
                        child: TextFormField(
                          controller: _emailController,
                          validator: (val) =>
                              val.isEmpty ? 'Enter your email' : null,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Email",
                            hintText: "Email",
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_passwordFocusNode);
                          },
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                          left: 15,
                          right: 15,
                          top: 0,
                          bottom: 0,
                        ),
                        height: 90,
                        child: TextFormField(
                          controller: _passwordController,
                          validator: (val) =>
                              val.isEmpty ? 'Enter your password' : null,
                          obscureText: true,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Password",
                            hintText: "Password",
                            fillColor: Colors.white,
                          ),
                          focusNode: _passwordFocusNode,
                          onFieldSubmitted: (_) async {
                            if (_formKey.currentState.validate()) {
                              setState(() => loading = true);
                              dynamic result = await _auth.login(
                                _emailController.text,
                                _passwordController.text,
                              );
                              if (result == null) {
                                setState(() {
                                  error = 'Incorrect email and/or password.';
                                  loading = false;
                                });
                              }
                            }
                          },
                        ),
                      ),
                      Container(
                        height: 50,
                        child: Text(
                          error,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 14.0,
                          ),
                        ),
                      ),
                      Container(
                        height: 50,
                        width: 250,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(
                            20,
                          ),
                        ),
                        child: FlatButton(
                          onPressed: () async {
                            if (_formKey.currentState.validate()) {
                              setState(() => loading = true);
                              dynamic result = await _auth
                                  .login(
                                _emailController.text,
                                _passwordController.text,
                              )
                                  .then((result) async {
                                if (result != null) {
                                  /// perform a query to get a snapshot of the user
                                  QuerySnapshot userInfoSnapshot =
                                      await DatabaseService().getUserByEmail(
                                          _emailController.text);

                                  /// initialize user object
                                  final user = userInfoSnapshot.docs[0].data();

                                  print('retrieved user from login');
                                  print('username: ' + user['username']);
                                  print('email: ' + user['email']);

                                  HelperFunctions().saveUserLoggedIn(isUserLoggedIn: true);
                                  HelperFunctions().saveUserName(userName: user['username']);
                                  HelperFunctions().saveUserEmail(userEmail: user['email']);
                                  HelperFunctions().saveUserRole(userRole: user['role']);

                                } else {
                                  setState(() {
                                    error = 'Incorrect email and/or password.';
                                    loading = false;
                                  });
                                }
                              });
                            }
                          },
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      Container(
                        height: 40,
                        child: Column(
                          children: <Widget>[
                            Expanded(
                              child: Text("Don't have an account?"),
                            ),
                            Expanded(
                              child: FlatButton(
                                onPressed: () {
                                  Navigator.of(context)
                                      .pushNamed(Register.routeName);
                                },
                                child: Text(
                                  "Register",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
