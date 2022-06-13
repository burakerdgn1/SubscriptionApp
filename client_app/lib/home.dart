// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import './product_detail.dart';
import './login.dart';
import 'api/api.dart';

import '../settings.dart';

final _formKey = GlobalKey<FormState>();

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _TestState();
}

class _TestState extends State<HomePage> {
  int _currentIndex = 0;

  final tabs = <Widget>[
    Center(
      child: Text("Home"),
    ),
    Center(
      child: Text("Subs"),
    ),
    Center(
      child: Text(""),
    ),
    Center(
      child: Text("Shop"),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: <Widget>[
          PopupMenuButton(
              // add icon, by default "3 dot" icon
              // icon: Icon(Icons.book)
              itemBuilder: (context) {
            return [
              PopupMenuItem<int>(
                value: 0,
                child: Text("Settings"),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: Text("Logout"),
              ),
            ];
          }, onSelected: (value) {
            if (value == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Settings()),
              );
            } else if (value == 1) {
              Navigator.pop(context);
              LogOut().then((value) => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginPage(formKey: _formKey)),
                  ));
            }
          }),
        ],
      ),
      body: //tabs[_currentIndex]
          Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
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
              ],
            ),
            Container(
              height: 250.0,
              width: double.infinity,
              margin: EdgeInsets.all(5),
              child: Query(
                options: QueryOptions(
                  document: GetSubscriptions(GetStorage().read("userID")),
                ),
                builder: (QueryResult result,
                    {VoidCallback? refetch, FetchMore? fetchMore}) {
                  if (result.hasException) {
                    return Text(result.exception.toString());
                  }

                  if (result.isLoading) {
                    return const Text('Loading');
                  }

                  List subscriptions = result.data?['subscriptions'];

                  return ListView.builder(
                      itemCount: subscriptions.length,
                      itemBuilder: (context, index) {
                        final subscription =
                            subscriptions[index]['subscriptionInfo'][0];
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  subscription['image_url'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              Container(
                                child: Column(
                                  children: [
                                    Text(subscription['name']),
                                    Text("Gym "),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                child: const Text(
                                  'i',
                                  style: TextStyle(fontSize: 20),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailPage(subscription)),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  fixedSize: const Size(40, 40),
                                  shape: const CircleBorder(),
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                },
              ),
            ),
            ElevatedButton(
              child: const Text(
                '+',
                style: TextStyle(fontSize: 24),
              ),
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                fixedSize: const Size(60, 60),
                shape: const CircleBorder(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        iconSize: 30,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            label: "New",
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cancel_presentation_sharp),
            label: "X",
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Shop",
            backgroundColor: Colors.blue,
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
