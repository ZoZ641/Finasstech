import 'dart:io';

import 'package:finasstech/core/theme/app_pallete.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraphWidget extends StatefulWidget {
  final bool isGraph;
  final String title;
  final String duration;
  final String amount;
  final bool isGradient;
  const GraphWidget({
    super.key,
    this.isGraph = true,
    this.isGradient = false,
    required this.title,
    required this.duration,
    required this.amount,
  });

  @override
  State<GraphWidget> createState() => _GraphWidgetState();
}

//! Figure where to put this function
LinearGradient generateGradient({
  required Color positiveColor,
  required Color negativeColor,
  required List<FlSpot> xyCord,
  required bool isLine,
}) {
  List<Color> colors = [];
  List<double> stops = [];

  for (int i = 0; i < xyCord.length; i++) {
    double stop = i / (xyCord.length - 1);
    stops.add(stop);

    if (xyCord[i].y >= 0) {
      colors.add(positiveColor);
    } else {
      colors.add(negativeColor);
    }
  }

  if (!isLine) {
    colors.add(Colors.transparent);
    stops.add(1.0);
  }

  return LinearGradient(
    colors: colors,
    stops: stops,
    begin: isLine ? Alignment.centerLeft : Alignment.topCenter,
    end: isLine ? Alignment.centerRight : Alignment.bottomCenter,
  );
}

class _GraphWidgetState extends State<GraphWidget> {
  List<FlSpot> placeholderData = [
    FlSpot(0, 0),
    FlSpot(1, -252),
    FlSpot(2, -36),
    FlSpot(3, 272),
    FlSpot(4, 360),
    FlSpot(5, 33),
    FlSpot(6, -90),
    FlSpot(7, -252),
    FlSpot(8, -237),
    FlSpot(9, -327),
    FlSpot(10, 296),
    FlSpot(11, -38),
    FlSpot(12, -441),
    FlSpot(13, 166),
    FlSpot(14, -486),
    FlSpot(15, -39),
    /*FlSpot(16, 327),
                          FlSpot(17, -328),
                          FlSpot(18, 256),
                          FlSpot(19, 78),
                          FlSpot(20, -436),
                          FlSpot(21, 96),
                          FlSpot(22, -215),
                          FlSpot(23, 348),
                          FlSpot(24, 30),
                          FlSpot(25, -151),
                          FlSpot(26, -50),
                          FlSpot(27, -227),
                          FlSpot(28, -335),
                          FlSpot(29, -316),
                          FlSpot(30, -452),*/
  ];
  @override
  Widget build(BuildContext context) {
    return Card.outlined(
      child: Padding(
        padding:
            widget.isGraph
                ? EdgeInsets.all(25.0)
                : EdgeInsets.fromLTRB(25, 25, 25, 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 5),
            Text(
              '£${widget.amount}',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              widget.duration,
              style: TextStyle(fontSize: 20, color: Color(0xFFa1b5a5)),
            ),
            SizedBox(height: 15),
            Visibility(
              visible: widget.isGraph,
              child: SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      //show: false,
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                          reservedSize: 37,
                        ),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                        ),
                      ),
                      /*bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text('Day ${value.toInt()}');
                          },
                          interval: 1,
                        ),
                      ),*/
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: placeholderData,
                        isCurved: true,
                        // color: Color(0xFFa5baa9),
                        gradient: generateGradient(
                          xyCord: placeholderData,
                          positiveColor: AppPallete.primaryColor,
                          negativeColor: AppPallete.inputFieldErrorColor,
                          isLine: true,
                        ),
                        barWidth: 4,
                        isStrokeCapRound: true,
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppPallete.underGraphColor,
                              AppPallete.underGraphColor.withAlpha(100),
                              AppPallete.underGraphColor.withAlpha(50),
                              AppPallete.underGraphColor.withAlpha(0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            //SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
