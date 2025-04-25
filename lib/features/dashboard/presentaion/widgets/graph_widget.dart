import 'dart:math';

import 'package:finasstech/core/theme/app_pallete.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum TimePeriod { week, month, quarter, year, custom }

class GraphWidget extends StatefulWidget {
  final bool isGraph;
  final String title;
  final String amount;
  final bool isGradient;
  final List<FlSpot>? data;
  final TimePeriod initialTimePeriod;
  final Function(TimePeriod)? onTimePeriodChanged;

  const GraphWidget({
    super.key,
    this.isGraph = true,
    this.isGradient = false,
    required this.title,
    required this.amount,
    this.data,
    this.initialTimePeriod = TimePeriod.week,
    this.onTimePeriodChanged,
  });

  @override
  State<GraphWidget> createState() => _GraphWidgetState();
}

class _GraphWidgetState extends State<GraphWidget> {
  late TimePeriod _selectedPeriod;
  late List<FlSpot> _displayData;

  @override
  void initState() {
    super.initState();
    _selectedPeriod = widget.initialTimePeriod;
    _displayData = widget.data ?? _generatePlaceholderData(_selectedPeriod);
  }

  List<FlSpot> _generatePlaceholderData(TimePeriod period) {
    // This would ideally come from your data repository
    switch (period) {
      case TimePeriod.week:
        return [
          FlSpot(0, 0),
          FlSpot(1, -252),
          FlSpot(2, -36),
          FlSpot(3, 272),
          FlSpot(4, 360),
          FlSpot(5, 33),
          FlSpot(6, -90),
        ];
      case TimePeriod.month:
        return [
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
          FlSpot(16, 327),
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
        ];
      case TimePeriod.quarter:
        // 3 months data (12 weeks)
        return List.generate(
          12,
          (index) =>
              FlSpot(index.toDouble(), (200 * (index % 4 - 1.5)).toDouble()),
        );
      case TimePeriod.year:
        // 12 months data
        return List.generate(
          12,
          (index) => FlSpot(
            index.toDouble(),
            (400 * sin((index / 3) % 6.28318)).toDouble(),
          ),
        );
      case TimePeriod.custom:
        // Default to monthly data for custom range
        return _generatePlaceholderData(TimePeriod.month);
    }
  }

  LinearGradient _generateGradient({
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

  String _getPeriodLabel(TimePeriod period) {
    switch (period) {
      case TimePeriod.week:
        return 'This week';
      case TimePeriod.month:
        return 'This month';
      case TimePeriod.quarter:
        return 'This quarter';
      case TimePeriod.year:
        return 'This year';
      case TimePeriod.custom:
        return 'Custom period';
    }
  }

  String _getBottomTitleText(double value, TimePeriod period) {
    switch (period) {
      case TimePeriod.week:
        // For week view, show days (0-6)
        final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final day = value.toInt() % 7;
        return value.toInt() % 2 == 0 ? weekdays[day] : '';
      case TimePeriod.month:
        // For month view, show week numbers
        return value.toInt() % 7 == 0 ? 'W${(value / 7).ceil()}' : '';
      case TimePeriod.quarter:
        // For quarter, show month abbreviations
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return value.toInt() % 4 == 0
            ? months[(value.toInt() / 4).floor() % 12]
            : '';
      case TimePeriod.year:
        // For year view, show month abbreviations
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return months[value.toInt() % 12];
      case TimePeriod.custom:
        // For custom, adapt based on range
        return value.toInt().toString();
    }
  }

  void _handleTimePeriodChange(TimePeriod? newPeriod) {
    if (newPeriod != null && newPeriod != _selectedPeriod) {
      setState(() {
        _selectedPeriod = newPeriod;
        _displayData = _generatePlaceholderData(newPeriod);
      });

      if (widget.onTimePeriodChanged != null) {
        widget.onTimePeriodChanged!(newPeriod);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // print('expense data $_displayData');
    return Card.outlined(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Padding(
        padding:
            widget.isGraph
                ? const EdgeInsets.all(25.0)
                : const EdgeInsets.fromLTRB(25, 25, 25, 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 5),
            Text(
              '£${widget.amount.replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color:
                    double.parse(widget.amount) > 0
                        ? AppPallete.primaryColor
                        : Colors.red,
              ),
            ),
            const SizedBox(height: 5),
            DropdownButton<TimePeriod>(
              value: _selectedPeriod,
              underline: Container(),
              icon: const Icon(Icons.keyboard_arrow_down),
              onChanged: _handleTimePeriodChange,
              items:
                  TimePeriod.values.map((TimePeriod period) {
                    return DropdownMenuItem<TimePeriod>(
                      value: period,
                      child: Text(_getPeriodLabel(period)),
                    );
                  }).toList(),
            ),
            const SizedBox(height: 15),

            Visibility(
              visible: widget.isGraph,
              child: SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: false,
                          reservedSize: 37,
                        ),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            // Only show labels at specific intervals to avoid overcrowding
                            final label = _getBottomTitleText(
                              value,
                              _selectedPeriod,
                            );
                            return label.isEmpty
                                ? const SizedBox.shrink()
                                : Text(
                                  label,
                                  style: const TextStyle(
                                    color: Color(0xFFa1b5a5),
                                    fontSize: 10,
                                  ),
                                );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: _displayData,
                        isCurved: true,
                        color: Colors.green,
                        /*gradient: _generateGradient(
                          xyCord: _displayData,
                          positiveColor: AppPallete.primaryColor,
                          negativeColor: AppPallete.inputFieldErrorColor,
                          isLine: true,
                        ),*/
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
          ],
        ),
      ),
    );
  }
}

/*
// Need to import this for Math.sin
class Math {
  static double sin(double x) {
    return x.remainder(6.28318).sin();
  }
}*/
