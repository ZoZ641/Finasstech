import 'dart:math';

import 'package:finasstech/core/theme/app_pallete.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

enum TimePeriod { week, month, quarter, year }

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

  @override
  void didUpdateWidget(GraphWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update display data if it changes
    if (widget.data != null && widget.data != oldWidget.data) {
      setState(() {
        _displayData = widget.data!;
      });
    }
  }

  List<FlSpot> _generatePlaceholderData(TimePeriod period) {
    // Generate placeholder data with the correct number of points for each period
    switch (period) {
      case TimePeriod.week:
        // 7 data points for a week
        return List.generate(
          7,
          (index) =>
              FlSpot(index.toDouble(), (Random().nextDouble() * 500).abs()),
        );
      case TimePeriod.month:
        // 4 data points for a month (4 weeks)
        return List.generate(
          4,
          (index) =>
              FlSpot(index.toDouble(), (Random().nextDouble() * 500).abs()),
        );
      case TimePeriod.quarter:
        // 3 data points for a quarter (3 months)
        return List.generate(
          3,
          (index) =>
              FlSpot(index.toDouble(), (Random().nextDouble() * 500).abs()),
        );
      case TimePeriod.year:
        // 4 data points for a year (4 quarters)
        return List.generate(
          4,
          (index) =>
              FlSpot(index.toDouble(), (Random().nextDouble() * 500).abs()),
        );
    }
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
    }
  }

  String _getBottomTitleText(double value, TimePeriod period) {
    // Only show label for integer values
    if (value != value.toInt()) return '';
    switch (period) {
      case TimePeriod.week:
        const weekdays = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
        if (value.toInt() >= 0 && value.toInt() < 7) {
          return weekdays[value.toInt()];
        }
        return '';
      case TimePeriod.month:
        if (value.toInt() >= 0 && value.toInt() < 4) {
          return 'W${value.toInt() + 1}';
        }
        return '';
      case TimePeriod.quarter:
        final now = DateTime.now();
        final quarterStartMonth = ((now.month - 1) ~/ 3) * 3;
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
        if (value.toInt() >= 0 && value.toInt() < 3) {
          return months[quarterStartMonth + value.toInt()];
        }
        return '';
      case TimePeriod.year:
        if (value.toInt() >= 0 && value.toInt() < 4) {
          return 'Q${value.toInt() + 1}';
        }
        return '';
    }
  }

  void _handleTimePeriodChange(TimePeriod? newPeriod) {
    if (newPeriod != null && newPeriod != _selectedPeriod) {
      setState(() {
        _selectedPeriod = newPeriod;
        _displayData = widget.data ?? _generatePlaceholderData(newPeriod);
      });

      if (widget.onTimePeriodChanged != null) {
        widget.onTimePeriodChanged!(newPeriod);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceEvenly,
                    gridData: FlGridData(show: false),
                    //maxY: _getMaxY(),
                    //minY: _getMinY(),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() < 0 ||
                                (value.toInt() >= _displayData.length) ||
                                value != value.floorToDouble()) {
                              return const SizedBox();
                            }
                            final label = _getBottomTitleText(
                              value,
                              _selectedPeriod,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                label,
                                style: const TextStyle(
                                  color: Color(0xFFa1b5a5),
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups:
                        _displayData
                            .map(
                              (spot) => BarChartGroupData(
                                x: spot.x.toInt(),
                                barRods: [
                                  BarChartRodData(
                                    toY: spot.y.abs(),
                                    fromY: 0,
                                    gradient: LinearGradient(
                                      colors:
                                          spot.y >= 0
                                              ? [
                                                AppPallete.primaryColor,
                                                AppPallete.primaryColor
                                                    .withAlpha(150),
                                              ]
                                              : [
                                                AppPallete.errorColor,
                                                AppPallete.errorColor.withAlpha(
                                                  150,
                                                ),
                                              ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    width: 16,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ],
                              ),
                            )
                            .toList(),
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
