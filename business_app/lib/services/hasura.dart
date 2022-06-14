import 'dart:developer';
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

// --- Functions ---
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
          }
        }
      }
    """);
}

Future<Map<String, dynamic>?> GetUserData(String? email) async {
  try {
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
      return null;
    } else {
      var userData = result.data?['users'][0];
      return userData;
    }
  } on Exception catch (_) {
    return null;
  }
}
