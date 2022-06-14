// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, prefer_const_constructors_in_immutables

import 'package:client_app/qrcodepage.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'functions/qr_funcs.dart';

class ProductDetailPage extends StatefulWidget {
  final dynamic subscription;
  ProductDetailPage(this.subscription, {Key? key}) : super(key: key);

  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "View Subscription",
        ),
      ),
      body: _buildProductDetailsPage(context),
    );
  }

  _buildProductDetailsPage(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return ListView(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(4.0),
          child: Card(
            elevation: 4.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildProductImagesWidgets(),
                _buildProductTitleWidget(),
                SizedBox(height: 12.0),
                Center(
                    child: ElevatedButton(
                        onPressed: () => {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => QRCodePage(
                                        GenerateQRCode(
                                            widget.subscription["id"],
                                            GetStorage().read("userID")))),
                              )
                            },
                        child: Text("QR Code"))),
                SizedBox(height: 12.0),
                _buildPriceWidgets(),
                SizedBox(height: 12.0),
                _buildDivider(screenSize),
                SizedBox(height: 12.0),
                _buildFurtherInfoWidget(),
                SizedBox(height: 12.0),
                _buildDivider(screenSize),
                SizedBox(height: 12.0),
                _buildSizeChartWidgets(),
                SizedBox(height: 12.0),
                _buildDetailsAndMaterialWidgets(),
                SizedBox(height: 12.0),
                _buildStyleNoteHeader(),
                SizedBox(height: 6.0),
                _buildDivider(screenSize),
                SizedBox(height: 4.0),
                _buildStyleNoteData(),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildDivider(Size screenSize) {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.grey[600],
          width: screenSize.width,
          height: 0.25,
        ),
      ],
    );
  }

  _buildProductImagesWidgets() {
    TabController imagesController = TabController(length: 3, vsync: this);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 250.0,
        child: Center(
          child: DefaultTabController(
            length: 3,
            child: Stack(
              children: <Widget>[
                TabBarView(
                  controller: imagesController,
                  children: <Widget>[
                    Image.network(
                      widget.subscription["image_url"],
                    ),
                    Image.network(
                      widget.subscription["image_url"],
                    ),
                    Image.network(
                      widget.subscription["image_url"],
                    ),
                  ],
                ),
                Container(
                  alignment: FractionalOffset(0.5, 0.95),
                  child: TabPageSelector(
                    controller: imagesController,
                    selectedColor: Colors.grey,
                    color: Colors.white,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildProductTitleWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Center(
        child: Text(
          //name,
          widget.subscription["name"],
          style: TextStyle(fontSize: 16.0, color: Colors.black),
        ),
      ),
    );
  }

  _buildPriceWidgets() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            widget.subscription["price"].toString() + " TRY/month",
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
          SizedBox(
            width: 8.0,
          ),
          SizedBox(
            width: 8.0,
          ),
        ],
      ),
    );
  }

  _buildFurtherInfoWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: <Widget>[
          Icon(
            Icons.info,
            color: Colors.grey[600],
          ),
          SizedBox(
            width: 12.0,
          ),
          Text(
            widget.subscription["serviceType"],
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  _buildSizeChartWidgets() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.info,
                color: Colors.grey[600],
              ),
              SizedBox(
                width: 12.0,
              ),
              Text(
                "Info",
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _buildDetailsAndMaterialWidgets() {
    TabController tabController = new TabController(length: 2, vsync: this);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TabBar(
            controller: tabController,
            tabs: <Widget>[
              Tab(
                child: Text(
                  "Details",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "Contact",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            height: 50.0,
            child: TabBarView(
              controller: tabController,
              children: <Widget>[
                Text(
                  "Details\nAbout",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                Text(
                  "Phone Number etc.",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildStyleNoteHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12.0,
      ),
      child: Text(
        "Address",
        style: TextStyle(
          color: Colors.grey[800],
        ),
      ),
    );
  }

  _buildStyleNoteData() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12.0,
      ),
      child: Text(
        "Adress....",
        style: TextStyle(
          color: Colors.grey[600],
        ),
      ),
    );
  }
}
