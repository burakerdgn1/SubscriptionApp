import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:project_management/constants.dart';
import 'package:project_management/model/user.dart';
import 'package:project_management/services/helper.dart';
import 'package:project_management/ui/auth/authentication_bloc.dart';
import 'package:project_management/ui/auth/login/login_screen.dart';
import 'package:project_management/ui/auth/welcome/welcome_screen.dart';
import 'package:provider/provider.dart';

import '../../services/hasura.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({Key? key, required this.user}) : super(key: key);

  @override
  State createState() => _HomeState();
}

class _HomeState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late User user;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    //user = widget.user;
    // ignore: unnecessary_new
    user = new User(
        email: "test@business.com",
        username: "Test Business",
        userID: "6",
        ownerOfType: "3",
        registerDate: "Today");
    _tabController = TabController(vsync: this, length: 3);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state.authState == AuthState.unauthenticated) {
          pushAndRemoveUntil(context, const WelcomeScreen(), false);
        }
      },
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                child: Text(
                  'Drawer Header',
                  style: TextStyle(color: Colors.white),
                ),
                decoration: BoxDecoration(
                  color: Color(COLOR_PRIMARY),
                ),
              ),
              ListTile(
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.black),
                ),
                leading: Transform.rotate(
                    angle: pi / 1,
                    child: const Icon(Icons.exit_to_app, color: Colors.black)),
                onTap: () {
                  context.read<AuthenticationBloc>().add(LogoutEvent());
                },
              ),
            ],
          ),
        ),
        appBar: AppBar(
          title: const Text(
            'Dashboard',
            style: TextStyle(color: Colors.black),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Column(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.grey.shade400,
                          child: ClipOval(
                            child: SizedBox(
                              width: 70,
                              height: 70,
                              child: Image.asset(
                                'images/placeholder.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(user.username),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(user.email),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  // ignore: prefer_const_literals_to_create_immutables
                  children: [
                    DashboardButton(
                        icon: "images/icons/people.png",
                        text: "Customers",
                        color: Colors.orange,
                        onPressed: () => _tabController.animateTo(0)),
                    DashboardButton(
                        icon: "images/icons/edit-business.png",
                        text: "Edit Business",
                        color: Colors.blueGrey,
                        onPressed: () => _tabController.animateTo(1)),
                    DashboardButton(
                        icon: "images/icons/statistics-xxl.png",
                        text: "Statistics",
                        color: Colors.amber,
                        onPressed: () => _tabController.animateTo(2))
                  ],
                ),
                DefaultTabController(
                  length: 3,
                  child: SizedBox(
                    height: 600.0,
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: <Widget>[
                              Column(
                                children: [
                                  ElevatedButton(
                                      onPressed: () {},
                                      child: const Text("Add New Customer")),
                                  customerList(),
                                ],
                              ),
                              Container(
                                color: Colors.yellow,
                                child: Column(children: [
                                  const Text("1"),
                                  const Text("1"),
                                ]),
                              ),
                              StatisticsTab(user: user),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Container customerList() {
    return Container(
      child: Query(
        options: QueryOptions(
          document: GetCustomers(user.ownerOfType),
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
              shrinkWrap: mounted,
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                final userInfo = subscriptions[index]['user_info'];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          'images/placeholder.jpg',
                          fit: BoxFit.cover,
                          height: 50,
                        ),
                      ),
                      Column(
                        children: [
                          Text(userInfo['username']),
                          Text(userInfo['emailAddress'])
                        ],
                      ),
                      ElevatedButton(
                        child: const Text(
                          'i',
                          style: TextStyle(fontSize: 20),
                        ),
                        onPressed: () {},
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
    );
  }
}

class StatisticsTab extends StatelessWidget {
  final User user;

  const StatisticsTab({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.yellow,
        child: Query(
            options: QueryOptions(
              document: GetCustomers(user.ownerOfType),
            ),
            builder: (QueryResult result,
                {VoidCallback? refetch, FetchMore? fetchMore}) {
              if (result.hasException) {
                return Text(result.exception.toString());
              }
              if (result.isLoading) {
                return const Text('Loading');
              }
              var subscriptionsCount = result.data?['subscriptions'].length;
              var price =
                  result.data?['subscriptions'][0]['subtypeinfo']['price'];

              var expectedRevenueMonthly = price * subscriptionsCount;

              return Text("");
            }));
  }
}

class DashboardButton extends StatelessWidget {
  final String icon;
  final String text;
  final MaterialColor color;
  final Function() onPressed;

  const DashboardButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.color,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
              side: BorderSide(
                color: color,
              ),
            ),
            primary: color,
          ),
          child: Column(
            children: [
              Image.asset(
                icon,
                fit: BoxFit.contain,
                height: 50,
                width: 50,
              ),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            ],
          ),
          onPressed: onPressed),
    );
  }
}
