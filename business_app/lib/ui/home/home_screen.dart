// ignore_for_file: deprecated_member_use

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

class _HomeState extends State<HomeScreen> with TickerProviderStateMixin {
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
                  'SubApp',
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
                                    child: const Text("Add New Customer"),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              scrollable: true,
                                              title: const Text(
                                                  'Add New Customer Form'),
                                              content: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Form(
                                                  child: Column(
                                                    children: <Widget>[
                                                      TextFormField(
                                                        decoration:
                                                            const InputDecoration(
                                                          labelText:
                                                              'Customer Name',
                                                          icon: Icon(Icons
                                                              .account_box),
                                                        ),
                                                      ),
                                                      TextFormField(
                                                        decoration:
                                                            const InputDecoration(
                                                          labelText:
                                                              'Customer ID',
                                                          icon: Icon(
                                                              Icons.message),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              actions: [
                                                RaisedButton(
                                                    child: const Text(
                                                        "Send Invation"),
                                                    onPressed: () {
                                                      // your code
                                                    })
                                              ],
                                            );
                                          });
                                    },
                                  ),
                                  customerList(),
                                ],
                              ),
                              EditBusinessForm(user: user, context: context),
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

EditBusinessForm({required User user, required BuildContext context}) {
  final _formKey = GlobalKey<FormState>();

  TextEditingController businessName = TextEditingController();
  TextEditingController serviceType = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController details = TextEditingController();
  TextEditingController contact = TextEditingController();

  return Query(
      options: QueryOptions(
        document: GetBusinessInfo(user.ownerOfType),
      ),
      builder: (QueryResult result,
          {VoidCallback? refetch, FetchMore? fetchMore}) {
        if (result.hasException) {
          return Text(result.exception.toString());
        }
        if (result.isLoading) {
          return const Text('Loading');
        }
        var data = result.data?['type'][0];
        businessName.text = data['name'].toString();
        serviceType.text = data['serviceType'].toString();
        price.text = data['price'].toString();
        address.text = data['address'].toString();
        details.text = data['details'].toString();
        contact.text = data['contact'].toString();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Column(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            controller: businessName,
                            decoration: const InputDecoration(
                              labelText: 'Business Name',
                              icon: Icon(Icons.account_box),
                            ),
                          ),
                          TextFormField(
                            controller: price,
                            decoration: const InputDecoration(
                              labelText: 'Price',
                              icon: Icon(Icons.money),
                            ),
                          ),
                          TextFormField(
                            controller: serviceType,
                            decoration: const InputDecoration(
                              labelText: 'Service Type',
                              icon: Icon(Icons.room_service),
                            ),
                          ),
                          TextFormField(
                            controller: address,
                            decoration: const InputDecoration(
                              labelText: 'Address',
                              icon: Icon(Icons.location_city),
                            ),
                          ),
                          TextFormField(
                            controller: details,
                            decoration: const InputDecoration(
                              labelText: 'Details',
                              icon: Icon(Icons.details),
                            ),
                          ),
                          TextFormField(
                            controller: contact,
                            decoration: const InputDecoration(
                              labelText: 'Contact',
                              icon: Icon(Icons.mail),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              child: ElevatedButton(
                                child: const Text("Save"),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Processing Data')),
                                    );
                                    var result = await UpdateBusinessData(
                                        user.ownerOfType,
                                        contact.text,
                                        address.text,
                                        details.text,
                                        businessName.text,
                                        price.text,
                                        serviceType.text);
                                    refetch!();
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                  }
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        );
      });
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

              return const Text("");
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
