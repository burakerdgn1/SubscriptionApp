import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
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

String staticSubscriptions = """
  query staticSubscriptions {
    type {
      id
      image_url
      name
      price
    }
  }
""";

// --- Functions ---

GetUser(id) {
  return gql("""
    query getUsers (\$id:Int){
      users(where: {id:{_eq:\$id}}){
        id
        username
        password
        emailAddress
      }
    }
    """);
}

UpdatePassword(id, String password) async {
  FirebaseUser user = await FirebaseAuth.instance.currentUser();

  user?.updatePassword(password).then((_) {
    print("Successfully changed password");
  }).catchError((error) {
    print("Password can't be changed" + error.toString());
    //This might happen, when the wrong password is in, the user isn't found, or if the user hasn't logged in recently.
  });

  String update = '''
  mutation updateUsers(\$id: Int, \$password:String){
    action: update_users(where:{id:{_eq:\$id}}, _set:{password:\$password}){
      returning{
        id
        password
      }
    }

  }
  ''';
  final variable = {"id": id, "password": password};

  QueryResult result = await graphQLClient
      .query(QueryOptions(document: gql(update), variables: variable));
  if (!result.hasException) {
    return true;
  } else {
    return false;
  }
}

GetSubscriptions(UserID) {
  return gql("""
      query GetSubscriptions {
      subscriptions(where: {user: {_eq: $UserID}}) {
          id
          created_at
          valid_until
          subscriptionInfo {
            id
            image_url
            name
            price
            serviceType
            address
            details
            contact
            position
          }
        }
      }
    """);
}

AddNewSubscription(user, type, valid_until) async {
  String queryString = """
                    mutation insert_subscriptions(\$type:Int, \$user: Int, \$valid_until:timestamp) {
                      action: insert_subscriptions(objects: {user: \$user, type: \$type, valid_until: \$valid_until}){
                        returning {
                          user
                        }
                      }
                    }
          """;
  final variable = {"user": user, "type": type, "valid_until": valid_until};

  final result = await graphQLClient
      .mutate(MutationOptions(document: gql(queryString), variables: variable));

  print(result.exception);
}

//unsubscribe with type id
Unsubscribe(user, type) async {
  String queryString = """
                    mutation delete_subscriptions(\$type:Int, \$user: Int) {
                       delete_subscriptions(where:  {user: {_eq: $user}, type: {_eq: $type}}) {
                        returning {
                         
                        }
                      }
                    }
          """;
  final variable = {"user": user, "type": type};

  final result =
      await graphQLClient.mutate(MutationOptions(document: gql(queryString)));
  print(result.exception);
}

//for user with Id
GetSubscriptionList(UserID) async {
  var queryString = gql("""
      query GetSubscriptions {
      subscriptions(where: {user: {_eq: $UserID}}) {
          id
          created_at
          valid_until
          subscriptionInfo {
            id
            image_url
            name
            price
            serviceType
            address
            details
            contact
          }
        }
      }
    """);
  QueryResult result =
      await graphQLClient.query(QueryOptions(document: queryString));

  List subscriptions = result.data?['subscriptions'];
  List subscriptionlistID = [];
  for (var i = 0; i < subscriptions.length; i++) {
    final subscription = subscriptions[i]['subscriptionInfo'][0];
    subscriptionlistID.add(subscription["id"]);
  }

  return subscriptionlistID;
}

getAllSubscriptions() {
  return gql("""
     query {
      type {
        id
        image_url
        name
        price
        serviceType
        address
        details
        contact
        position
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
    return {"openDoor": false, "validUntil": "null"};
  }
}

RegisterUser(emailAddress, username, password) async {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseUser? user;
  try {
    var userCredential = await auth.createUserWithEmailAndPassword(
      email: emailAddress,
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

  print(user);

  if (user != null) {
    var queryString = """
            mutation insert_users(\$username: String,\$emailAddress:String, \$password: String){
              action: insert_users(objects: {username: \$username,emailAddress:\$emailAddress,password:\$password}) {
                returning {
                    id
                  }
              }
            }
          """;
    final variable = {
      "username": username,
      "password": password,
      "emailAddress": emailAddress
    };
    QueryResult result = await graphQLClient.query(QueryOptions(
      document: gql(queryString),
      variables: variable,
    ));

    return user == null ? false : true;
  }
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
    var emailAddress = user.email;
    var queryString = """
              query MyQuery {
                users(where: {emailAddress: {_eq: "$email"}}) {
                  registerDate
                  id
                  emailAddress
                  username
                }
              }
          """;
    var result = await graphQLClient.query(QueryOptions(
      document: gql(queryString),
    ));
    if (result.data?['users'].length == 0) {
      return false;
    } else {
      var userData = result.data?['users'][0];
      log(userData['id'].toString());
      GetStorage().write("userID", userData['id']);
      return true;
    }
  } on Exception catch (_) {
    log("User Not Found: " + email);
    return false;
  }
}

Future<bool> IsLoggedIn() async {
  var currentUser = await FirebaseAuth.instance.currentUser() != null;
  return currentUser && GetStorage().read("userID") != -1;
}

Future<bool> LogOut() async {
  GetStorage().write("userID", -1);
  await FirebaseAuth.instance.signOut();
  return true;
}
