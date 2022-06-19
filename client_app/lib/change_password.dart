import 'package:client_app/account_settings.dart';
import 'package:flutter/material.dart';
import 'api/api.dart';
import 'package:get_storage/get_storage.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({
    Key? key,
  }) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final GlobalKey<FormState> _key = new GlobalKey();
  final TextEditingController _passwordController = new TextEditingController();
  final TextEditingController _confirmPasswordController =
      new TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: Text("Change Password")),
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
                alignment: Alignment.topCenter,
                child: RaisedButton(
                  onPressed: () async {
                    if (_key.currentState!.validate()) {
                      final bool result = await UpdatePassword(
                          GetStorage().read("userID"),
                          _passwordController.text);
                      if (result) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => EditProfilePage()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Password Changed."),
                          ),
                        );
                      }
                    }
                  },
                  color: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 50),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    "SAVE",
                    style: TextStyle(
                        fontSize: 14, letterSpacing: 2.2, color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
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
}
