import 'dart:async';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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

void main() async {
  await initHiveForFlutter();

  final HttpLink httpLink = HttpLink(
    'https://abonelik-app.hasura.app/v1/graphql',
  );

  final AuthLink authLink = AuthLink(
      getToken: () async =>
          'KoplvKhAjqPNC8Ax5Odi7f1j8ZnCptKUZx0s6n2RsfoTHqzsQA8bgNGKpXOr48Us',
      headerKey: 'x-hasura-admin-secret');

  final Link link = authLink.concat(httpLink);

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: link,
      cache: GraphQLCache(store: HiveStore()),
    ),
  );
  runApp(GraphQLProvider(
    client: client,
    child: MaterialApp(
      title: 'Subscription App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Subscription App Home Page'),
    ),
  ));
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(staticSubscriptions),
          pollInterval: const Duration(seconds: 10),
        ),
        builder: (QueryResult result,
            {VoidCallback? refetch, FetchMore? fetchMore}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return const Text('Loading');
          }

          List subscriptions = result.data?['type'];

          return ListView.builder(
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                final subscription = subscriptions[index];

                return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Image.network(subscription['image_url'],
                          height: 75, width: 75, fit: BoxFit.contain),
                      Text(subscription['name']),
                    ]);
              });
        },
      ),
    );
  }
}
