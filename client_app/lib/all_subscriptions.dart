import 'package:client_app/api/api.dart';
import 'package:client_app/home.dart';
import 'package:client_app/product_detail.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:tuple/tuple.dart';

class AllSubscriptions extends StatefulWidget {
  const AllSubscriptions({Key? key}) : super(key: key);

  @override
  State<AllSubscriptions> createState() => _AllSubscriptionsState();
}

class _AllSubscriptionsState extends State<AllSubscriptions> {
  late double xP;
  late double yP;
  void _getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      xP = position.latitude;
      yP = position.longitude;
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    return (Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000);
  }

  String format(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }

  Tuple2<double, double> stringToPosition(String str) {
    var splittedStr = str.split(",");
    double xPosition = double.parse(splittedStr[0]);
    double yPosition = double.parse(splittedStr[1]);
    var result = Tuple2<double, double>(xPosition, yPosition);
    return result;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    final time3 = DateTime(now.year, now.month + 3, now.day).toString();

    final time12 = DateTime(now.year + 1, now.month, now.day).toString();

    final time = DateTime(now.year, now.month + 1, now.day).toString();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("All Subscriptions"),
        centerTitle: true,
      ),
      body: Subscription(
          options: SubscriptionOptions(document: getAllSubscriptions()),
          builder: (QueryResult result,
              {VoidCallback? refetch, FetchMore? fetchMore}) {
            if (result.hasException) {
              return Text(result.exception.toString());
            }

            if (result.isLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            List subscriptions = result.data?['type'];

            return ListView.builder(
              itemCount: subscriptions.length,
              itemBuilder: (context, index) {
                final subscription = subscriptions[index];

                Tuple2 location = stringToPosition(subscription['position']);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                            Text(subscription['serviceType']),
                            SizedBox(
                              height: 5,
                            ),
                            Text(format(calculateDistance(
                                    xP, yP, location.item1, location.item2)) +
                                " km away"),
                            TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProductDetailPage(
                                            subscription, null)),
                                  );
                                },
                                child: Text("Details")),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: InkWell(
                                onTap: () async {
                                  final List userSubs =
                                      await GetSubscriptionList(
                                          GetStorage().read("userID"));
                                  if (!userSubs.contains(subscription["id"])) {
                                    final result = await AddNewSubscription(
                                        GetStorage().read("userID"),
                                        subscription["id"],
                                        time);

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => const HomePage()));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "You have already had this subscription"),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blue.shade300,
                                      shape: BoxShape.circle),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Center(
                                      child: Text("1"),
                                    ),
                                  ),
                                )),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: InkWell(
                                onTap: () async {
                                  final List userSubs =
                                      await GetSubscriptionList(
                                          GetStorage().read("userID"));
                                  if (!userSubs.contains(subscription["id"])) {
                                    final time3 = DateTime(
                                            now.year, now.month + 3, now.day)
                                        .toString();

                                    final result = await AddNewSubscription(
                                        GetStorage().read("userID"),
                                        subscription["id"],
                                        time3);

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => HomePage()));
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "You have already had this subscription"),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.blue.shade500,
                                      shape: BoxShape.circle),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Center(
                                      child: Text("3"),
                                    ),
                                  ),
                                )),
                          ),
                          InkWell(
                              onTap: () async {
                                final List userSubs = await GetSubscriptionList(
                                    GetStorage().read("userID"));
                                if (!userSubs.contains(subscription["id"])) {
                                  final result = await AddNewSubscription(
                                      GetStorage().read("userID"),
                                      subscription["id"],
                                      time12);

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => HomePage()));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "You have already had this subscription"),
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.blue.shade700,
                                    shape: BoxShape.circle),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Center(
                                    child: Text("12"),
                                  ),
                                ),
                              )),
                        ],
                      )
                    ],
                  ),
                );
              },
            );
          }),
    );
  }
}
