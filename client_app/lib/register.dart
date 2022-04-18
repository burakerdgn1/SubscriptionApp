import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  RegisterPage({Key? key}) : super(key: key);

  // ignore: non_constant_identifier_names
  Future<bool> Register(String email, String password, String username) async {
    var queryString = """
    mutation register_user {
    insert_users(objects: {emailAddress: "$email", password: "$password", username: "$username"}) {
      returning {
        id
        registerDate
      }
    }
  }
  """;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
