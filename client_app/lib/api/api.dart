// ignore: import_of_legacy_library_into_null_safe
// ignore_for_file: non_constant_identifier_names

import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

//Hasura
final HttpLink httpLink = HttpLink(
  'https://abonelik-app.hasura.app/v1/graphql',
);
final AuthLink authLink = AuthLink(
    getToken: () async =>
        'KoplvKhAjqPNC8Ax5Odi7f1j8ZnCptKUZx0s6n2RsfoTHqzsQA8bgNGKpXOr48Us',
    headerKey: 'x-hasura-admin-secret');
final Link link = authLink.concat(httpLink);
var graphQLClient = GraphQLClient(
  cache: GraphQLCache(store: HiveStore()),
  link: link,
);
ValueNotifier<GraphQLClient> client = ValueNotifier(
  graphQLClient,
);

// --- Functions ---
GetSubscriptions(UserID) {
  return gql("""
      query GetSubscriptions {
      subscriptions(where: {user: {_eq: $UserID}}) {
          id
          subscriptionInfo {
            id
            image_url
            name
            price
          }
        }
      }
    """);
}

Future<String> CheckSubscriptionValidationString(String? data) async {
  try {
    List<String>? splitData = data?.split(":");
    if (splitData != null && splitData.length > 1) {
      String subID = splitData[0];
      String userID = splitData[1];

      var queryString = """
          query MyQuery {
            subscriptions(where: {id: {_eq: $subID}, user: {_eq: $userID}}, limit: 1) {
              id
              valid_until
            }
          }
        """;
      var result = await graphQLClient.query(QueryOptions(
        document: gql(queryString),
      ));
      if (result.data?['subscriptions'].length == 0) {
        return "Subscription not found.";
      } else {
        var subData = result.data?['subscriptions'][0];
        return "Valid Until: " + subData['valid_until'];
      }
    } else {
      return "Subscription date is invalid.";
    }
  } on Exception {
    return "QR Code is invalid.";
  }
}

Future<Object> CheckSubscriptionValidation(String subID, String userID) async {
  try {
    var queryString = """
            query MyQuery {
              subscriptions(where: {id: {_eq: $subID}, user: {_eq: $userID}}, limit: 1) {
                id
                valid_until
              }
            }
          """;
    var result = await graphQLClient.query(QueryOptions(
      document: gql(queryString),
    ));
    if (result.data?['subscriptions'].length == 0) {
      return {"openDoor": false, "validUntil": ""};
    } else {
      var subData = result.data?['subscriptions'][0];
      var validUntil = subData['valid_until'];
      log('validUntil: $validUntil');
      var currentDate = DateTime.now();
      var openDoor = DateTime.parse(validUntil).millisecondsSinceEpoch >
          currentDate.millisecondsSinceEpoch;
      return {"openDoor": openDoor, "validUntil": validUntil};
    }
  } on Exception {
    return {"openDoor": false, "validUntil": ""};
  }
}

RegisterUser(email, username, password) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseUser? user;
  try {
    var userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    user = userCredential.user;
    UserUpdateInfo updateInfo = UserUpdateInfo();
    updateInfo.displayName = username;
    await user.updateProfile(updateInfo);
    await user.reload();
    user = auth.currentUser as FirebaseUser?;
  } on Exception catch (e) {
    /* if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      } */
    log(e.toString());
  } catch (e) {
    log(e.toString());
  }

  if (user != null) {
    var queryString = """
            mutation RegisterUser {
              insert_users(object: {emailAddress: "$email", password: "$password", username: "$username"}) {
                returning {
                    id
                  }
              }
            }
          """;
    return await graphQLClient.query(QueryOptions(
      document: gql(queryString),
    ));
  }
}

AddNewSubscription(UserID, ValidUntil, SubType) async {
  var queryString = """
                    mutation AddNewSubscription {
                      insert_subscriptions(objects: {user: "$UserID", valid_until: "$ValidUntil", type: "$SubType"}){
                        returning {
                          id
                        }
                      }
                    }
          """;
  return await graphQLClient.query(QueryOptions(
    document: gql(queryString),
  ));
}

Future<bool> Login(String email, String password) async {
  try {
    final FirebaseUser user =
        (await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    ))
            .user;
    log("Found User: " + user.email);
    return true;
  } on Exception catch (_) {
    log("User Not Found: " + email);
    return false;
  }
}

Future<bool> IsLoggedIn() async {
  return await FirebaseAuth.instance.currentUser() != null;
}
