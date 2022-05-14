import 'dart:ffi';

import 'package:flutter/material.dart';

class Register extends StatelessWidget {
  const Register({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
      ),
      body: Container(
        height: size.height,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
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
            Column(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 60),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextField(),
              ),
              Text("Name"),
              SizedBox(height: 10),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 60),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextField(),
              ),
              Text("Username"),
              SizedBox(height: 10),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 60),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextField(),
              ),
              Text("Email"),
              SizedBox(height: 10),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 60),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextField(
                  obscureText: true,
                ),
              ),
              Text("Password"),
              SizedBox(height: 10),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 60),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: TextField(
                  obscureText: true,
                ),
              ),
              Text("Password Again"),
            ]),
            Container(
              alignment: Alignment.bottomCenter,
              child: ElevatedButton(
                child: Text("Register".toUpperCase(),
                    style: TextStyle(fontSize: 14)),
                style: ButtonStyle(
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white),
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.red),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            side: BorderSide(color: Colors.red)))),
                onPressed: () => null,
              ),
            )
          ],
        ),
      ),
    );
  }
}
