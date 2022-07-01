import 'package:client_app/api/api.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:table_calendar/table_calendar.dart';

class Calendar extends StatefulWidget {
  @override
  _CalendarState createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  late CalendarController _controller;
  late Map<DateTime, List<dynamic>> _events;
  late List<dynamic> _selectedEvents;

  late DateTime now;

  @override
  void initState() {
    super.initState();
    _controller = CalendarController();
    _events = {};
    now = DateTime.now();
    _selectedEvents = [];
  }

  String toMonthName(int month) {
    switch (month) {
      case 1:
        return "January";
        break;
      case 2:
        return "February";
        break;
      case 3:
        return "March";
        break;
      case 4:
        return "April";
        break;
      case 5:
        return "May";
        break;
      case 6:
        return "June";
        break;
      case 7:
        return "July";
        break;
      case 8:
        return "August";
        break;
      case 9:
        return "September";
        break;
      case 10:
        return "October";
        break;
      case 11:
        return "November";
        break;

      case 12:
        return "December";
        break;
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Subscription(
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

          for (var i = 0; i < subscriptions.length; i++) {
            List names = [];
            DateTime time = DateTime.parse(subscriptions[i]["valid_until"]);
            names.add(subscriptions[i]['subscriptionInfo'][0]["name"]);
            _events[time] = names;
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                          onPressed: () {
                            _controller.previousPage();
                            setState(() {
                              _selectedEvents = [];
                              now = DateTime(now.year, now.month - 1);
                            });
                          },
                          icon: Icon(Icons.chevron_left)),
                      Center(
                        child: Text(
                          toMonthName(now.month) + " " + now.year.toString(),
                        ),
                      ),
                      IconButton(
                          onPressed: () {
                            _controller.nextPage();
                            setState(() {
                              _selectedEvents = [];
                              now = DateTime(now.year, now.month + 1);
                            });
                          },
                          icon: Icon(Icons.chevron_right)),
                    ],
                  ),
                ),
                TableCalendar(
                  events: _events,
                  headerVisible: false,
                  initialCalendarFormat: CalendarFormat.month,
                  onHeaderTapped: (_) {
                    setState(() {
                      _selectedEvents = [];
                    });
                  },
                  calendarStyle: CalendarStyle(
                    canEventMarkersOverflow: true,
                    todayColor: Colors.orange,
                    selectedColor: Theme.of(context).primaryColor,
                    todayStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.white),
                  ),
                  headerStyle: HeaderStyle(
                    centerHeaderTitle: true,
                    formatButtonVisible: false,
                  ),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  builders: CalendarBuilders(
                    selectedDayBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(color: Colors.white),
                        )),
                    todayDayBuilder: (context, date, events) => Container(
                        margin: const EdgeInsets.all(4.0),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10.0)),
                        child: Text(
                          date.day.toString(),
                          style: TextStyle(color: Colors.white),
                        )),
                  ),
                  calendarController: _controller,
                  onDaySelected: (date, events, holidays) {
                    setState(() {
                      _selectedEvents = events;
                    });
                  },
                ),
                ..._selectedEvents.map((event) => Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height / 20,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Colors.white,
                            border: Border.all(color: Colors.grey)),
                        child: Center(
                            child: Text(
                          event,
                          style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        )),
                      ),
                    )),
              ],
            ),
          );
        });
  }
}
