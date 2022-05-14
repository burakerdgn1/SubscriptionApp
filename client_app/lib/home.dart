// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_new


import 'package:flutter/material.dart';
import 'package:qrcode_generator/product_detail.dart';
import 'package:qrcode_generator/login.dart';

import '../settings.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _TestState();
}

class _TestState extends State<Home> {
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
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
              child: new ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: 10,
                itemBuilder: (BuildContext ctxt, int index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          'https://www.gordion-avm.com/media/image/BQQ8S9MXP92QF4.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      InkWell(
                        onTap: () => {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ProductDetailPage()),
                          ),
                        },
                        child: Container(
                          child: Column(
                            children: [
                              Text("Macfit"),
                              Text("Gym "),
                            ],
                          ),
                        ),
                      ),
                      ElevatedButton(
                        child: const Text(
                          'x',
                          style: TextStyle(fontSize: 20),
                        ),
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(40, 40),
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  );
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
            title: Text("Home"),
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note_outlined),
            title: Text("New"),
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cancel_presentation_sharp),
            title: Text("X"),
            backgroundColor: Colors.blue,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            title: Text("Shop"),
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
