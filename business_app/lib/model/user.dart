import 'dart:io';

class User {
  String userID;

  String email;

  String username;

  String registerDate;

  String appIdentifier;

  User(
      {this.email = '',
      this.username = '',
      this.userID = '',
      this.registerDate = ''})
      : appIdentifier = 'Flutter Login Screen';

  String fullName() => username;

  factory User.fromJson(Map<String, dynamic> parsedJson) {
    return User(
        email: parsedJson['emailAddress'] ?? '',
        username: parsedJson['username'] ?? '',
        userID: parsedJson['id'].toString(),
        registerDate: parsedJson['registerDate'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'username': username,
      'id': userID,
      'registerDate': registerDate,
      'appIdentifier': appIdentifier
    };
  }
}
