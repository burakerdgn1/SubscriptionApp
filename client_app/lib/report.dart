// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables


import 'package:flutter/material.dart';
import 'package:qrcode_generator/calendar.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ReportPage extends StatefulWidget {
  ReportPage({Key? key}) : super(key: key);

  @override
  _ReportPageState createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Report Page"),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Container(
              height: 225,
              child: SfCartesianChart(
                title: ChartTitle(text: 'Report Graph'),
                // Initialize category axis
                primaryXAxis: CategoryAxis(),
                series: <ChartSeries>[
                  // Initialize line series
                  LineSeries<ChartData, String>(
                    dataSource: [
                      // Bind data source
                      ChartData('Jan', 10),
                      ChartData('Feb', 40),
                      ChartData('Mar', 20),
                      ChartData('Apr', 30),
                      ChartData('May', 25)
                    ],
                    xValueMapper: (ChartData data, _) => data.x,
                    yValueMapper: (ChartData data, _) => data.y,
                    // Render the data label
                    dataLabelSettings: DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
            Calendar(),
            Container(
              child: Text(
                "Schedule",
                style: TextStyle(fontSize: 20),
              ),
              alignment: Alignment.centerLeft,
            ),
            ListTile(
              
              title: Text(
                'Activity 1',
                textScaleFactor: 1.5,
              ),
              trailing: Icon(Icons.menu),
              subtitle: Text('About activity 1'),
              selected: true,
              
            ),
            ListTile(
              title: Text(
                'Activity 2',
                textScaleFactor: 1.5,
              ),
              trailing: Icon(Icons.menu),
              subtitle: Text('About activity 2'),
              selected: true,
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double? y;
}
