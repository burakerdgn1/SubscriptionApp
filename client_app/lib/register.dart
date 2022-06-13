// ignore_for_file: avoid_returning_null_for_void, unnecessary_new, unused_field

import 'dart:ffi';

import 'package:client_app/login.dart';
import 'package:flutter/material.dart';
import 'api/api.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final GlobalKey<FormState> _key = new GlobalKey();
  final TextEditingController _nameController = new TextEditingController();
  final TextEditingController _userNameController = new TextEditingController();
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _confirmPasswordController =
      new TextEditingController();

  String? validateName(String value) {
    String pattern = r'(^[a-zA-Z]*$)';
    RegExp regExp = new RegExp(pattern);
    if (value.isEmpty) {
      return 'Username is required';
    } else if (!regExp.hasMatch(value)) {
      return 'Username must be a-z and A-Z';
    }
    return null;
  }

  String? validateUsername(String value) {
    String pattern = r'(^[a-zA-Z]*$)';
    RegExp regExp = new RegExp(pattern);
    if (value.isEmpty) {
      return 'Username is required';
    } else if (!regExp.hasMatch(value)) {
      return 'Username must be a-z and A-Z';
    }
    return null;
  }

  String? validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value.isEmpty) {
      return 'Email is required';
    } else if (!regExp.hasMatch(value)) {
      return 'Invalid email';
    } else {
      return null;
    }
  }

  String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    } else if (value.length < 4) {
      return 'Password must be at least 4 characters';
    }
    return null;
  }

  String? validateConfirmPassword(String value) {
    if (value.isEmpty) {
      return 'Confirm password is required';
    } else if (value.length < 4) {
      return 'Confirm password must be at least 4 characters';
    }
    return null;
  }

  bool validationEqual(String currentValue, String checkValue) {
    if (currentValue == checkValue) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
      ),
      body: Form(
        key: _key,
        child: SizedBox(
          height: size.height,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(150),
                  child: Image.network(
                    'https://cdn2.iconfinder.com/data/icons/random-outline-3/48/random_14-512.png',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 60),
                      child: TextFormField(
                        controller: _nameController,
                        validator: (value) {
                          String pattern = r'(^[a-zA-Z]*$)';
                          RegExp regExp = new RegExp(pattern);
                          if (value == null || value.isEmpty) {
                            return 'Name is required';
                          } else if (!regExp.hasMatch(value)) {
                            return 'Name must be a-z and A-Z';
                          }
                          return null;
                        },
                        decoration: new InputDecoration(
                          contentPadding: const EdgeInsets.all(16.0),
                          hintText: 'Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 60),
                      child: TextFormField(
                        controller: _userNameController,
                        validator: (value) {
                          String pattern = r'(^[a-zA-Z0-9]*$)';
                          RegExp regExp = new RegExp(pattern);
                          if (value == null || value.isEmpty) {
                            return 'Username is required';
                          } else if (!regExp.hasMatch(value)) {
                            return 'Username must be a-z and A-Z and 0-9';
                          }
                          return null;
                        },
                        decoration: new InputDecoration(
                          contentPadding: const EdgeInsets.all(16.0),
                          hintText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        keyboardType: TextInputType.name,
                        
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 60),
                      child: TextFormField(
                        controller: _emailController,
                        validator: (value) {
                          String pattern =
                              r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                          RegExp regExp = new RegExp(pattern);
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          } else if (!regExp.hasMatch(value)) {
                            return 'Invalid email';
                          } else {
                            return null;
                          }
                        },
                        decoration: new InputDecoration(
                          contentPadding: const EdgeInsets.all(16.0),
                          hintText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 60),
                      child: TextFormField(
                        controller: _passwordController,
                        validator: (value) {
                          RegExp regex = RegExp(
                              r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
                          if (value == null || value.isEmpty) {
                            return 'Please enter password';
                          } else {
                            if (!regex.hasMatch(value)) {
                              return 'At least one uppercase, at least one lowercase, at least one number, at least one special character, minimum 8 characters';
                            } else {
                              return null;
                            }
                          }
                        },
                        obscureText: true,
                        decoration: new InputDecoration(
                          contentPadding: const EdgeInsets.all(16.0),
                          hintText: 'Password',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        keyboardType: TextInputType.visiblePassword,

                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 60),
                      child: TextFormField(
                        controller: _confirmPasswordController,
                        validator: (confirmation) {
                          return confirmation == null
                              ? 'Confirm password is required'
                              : validationEqual(
                                      confirmation, _passwordController.text)
                                  ? null
                                  : 'Password not match';
                        },
                        obscureText: true,
                        decoration: new InputDecoration(
                          contentPadding: const EdgeInsets.all(16.0),
                          hintText: 'Password Again',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        
                      ),
                    ),
                    const SizedBox(height: 20),
                  ]),
              Container(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton(
                  child: Text("Register".toUpperCase(),
                      style: const TextStyle(fontSize: 14)),
                  style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.white),
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.red),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                              side: BorderSide(color: Colors.red)))),
                  onPressed: () async {
                    if (_key.currentState!.validate()) {
                      var result = true; //await RegisterUser();
                      if (result) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  LoginPage(formKey: GlobalKey<FormState>())),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Registered successfully.")));
                      }
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
