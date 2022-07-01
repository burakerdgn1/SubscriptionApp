// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new

import 'package:client_app/all_subscriptions.dart';
import 'package:client_app/calendar.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import './login.dart';
import './product_detail.dart';
import '../settings.dart';
import 'api/api.dart';

final _formKey = GlobalKey<FormState>();

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _TestState();
}

class _TestState extends State<HomePage> {
  int _currentIndex = 0;

  final tabs = <Widget>[
    Home2(),
    Calendar(),
    Center(
      child: Text(""),
    ),
    Center(
      child: Text(""),
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
      body: tabs[_currentIndex],
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
            label: "Calendar",
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

class Home2 extends StatefulWidget {
  const Home2({Key? key}) : super(key: key);

  @override
  State<Home2> createState() => _Home2State();
}

class _Home2State extends State<Home2> {
  int dayToMonth(int day) {
    switch (day) {
      case 30:
        return 1;
      case 90:
        return 3;
      case 365:
        return 12;
    }
    return 0;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        color: Colors.red,
                        height: 10,
                        width: 10,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text("Subscription is expired")
                    ],
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Container(
                        color: Colors.yellow,
                        height: 10,
                        width: 10,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text("Subscription will expire in -- days")
                    ],
                  )
                ],
              ),
            ),
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
        Expanded(
          child: Container(
            margin: EdgeInsets.all(5),
            child: Subscription(
              options: SubscriptionOptions(
                document: GetSubscriptions(GetStorage().read("userID")),
              ),
              builder: (QueryResult result,
                  {VoidCallback? refetch, FetchMore? fetchMore}) {
                if (result.hasException) {
                  return Text(result.exception.toString());
                }

                if (result.isLoading) {
                  return Center(child: const Text('Loading'));
                }

                List subscriptions = result.data?['subscriptions'];

                return ListView.builder(
                    itemCount: subscriptions.length,
                    itemBuilder: (context, index) {
                      final subscription =
                          subscriptions[index]['subscriptionInfo'][0];
                      final DateTime validUntil =
                          DateTime.parse(subscriptions[index]["valid_until"]);

                      final dayLeft =
                          validUntil.difference(DateTime.now()).inDays;

                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            (dayLeft <= 0)
                                ? Container(
                                    width: 20,
                                    color: Colors.red,
                                    height: 40,
                                  )
                                : ((dayLeft <= 10)
                                    ? Container(
                                        width: 20,
                                        height: 40,
                                        color: Colors.yellow,
                                        child: Center(
                                          child: RotationTransition(
                                            turns: new AlwaysStoppedAnimation(
                                                270 / 360),
                                            child: Text(dayLeft.toString()),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        height: 0,
                                        width: 0,
                                      )),
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
                                  Text(subscription['serviceType']),
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
                                      builder: (context) => ProductDetailPage(
                                          subscription, dayLeft)),
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
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ElevatedButton(
            child: const Text(
              '+',
              style: TextStyle(fontSize: 24),
            ),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => AllSubscriptions()));
            },
            style: ElevatedButton.styleFrom(
              fixedSize: const Size(60, 60),
              shape: const CircleBorder(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Total Cost : "),
              Subscription(
                  options: SubscriptionOptions(
                    document: GetSubscriptions(GetStorage().read("userID")),
                  ),
                  builder: (QueryResult result,
                      {VoidCallback? refetch, FetchMore? fetchMore}) {
                    if (result.hasException) {
                      return Text(result.exception.toString());
                    }

                    if (result.isLoading) {
                      return Center(child: const Text('Loading'));
                    }
                    List subscriptions = result.data?['subscriptions'];
                    double sum = 0;
                    for (var subscription in subscriptions) {
                      final DateTime created =
                          DateTime.parse(subscription["created_at"]);

                      final DateTime validUntil =
                          DateTime.parse(subscription["valid_until"]);
                      final dayLeft =
                          validUntil.difference(DateTime.now()).inDays;

                      if (dayLeft > 0) {
                        final int month_Created = created.month;
                        final int valid_until_month = validUntil.month;

                        final month = (valid_until_month - month_Created) % 12;

                        final price = subscription['subscriptionInfo'][0]
                                ["price"] *
                            month;
                        sum = sum + price;
                      }
                    }

                    return Text(
                      sum.toString(),
                    );
                  }),
            ],
          ),
        ),
      ],
    );
  }
}
