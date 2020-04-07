import 'package:flutter/material.dart';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:modoemaniera/models/counters.dart';

import 'models/chartEnum.dart';

class CounterChart {
  final String name;
  final int count;

  CounterChart(this.name, this.count);
}

class ChartsPage extends StatefulWidget {
  ChartsPage(this._chartSelected);

  final Chart _chartSelected;

  @override
  _ChartsPageState createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  @override
  Widget build(BuildContext context) {
    if (widget._chartSelected == Chart.Torta) {
      return PieChart(PieChart._createSampleData());
    } else if (widget._chartSelected == Chart.Barre) {
      return BarChart(BarChart._createSampleData());
    } else if (widget._chartSelected == Chart.Giornata) {
      return BarChart(BarChart._createSampleData());
    } else if (widget._chartSelected == Chart.ParolaDellaGiornata) {
      return BarChart(BarChart._createSampleData());
    } else {
      return null;
    }
  }
}

class BarChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  BarChart(this.seriesList, {this.animate});

  /// Creates a [BarChart] with sample data and no transition.
  factory BarChart.withSampleData() {
    return BarChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: charts.BarChart(
        seriesList,
        animate: animate,
        domainAxis: charts.OrdinalAxisSpec(
          renderSpec: new charts.SmallTickRendererSpec(
            minimumPaddingBetweenLabelsPx: 30,
            // Tick and Label styling here.
            labelStyle: new charts.TextStyleSpec(
              fontSize: 13, // size in Pts.
              color: charts.MaterialPalette.black,
            ),

            // Change the line colors to match text color.
            lineStyle:
                new charts.LineStyleSpec(color: charts.MaterialPalette.black),
          ),
          viewport: new charts.OrdinalViewport('AePS', 3),
        ),
        behaviors: [
          new charts.SeriesLegend(),
          new charts.SlidingViewport(),
          new charts.PanAndZoomBehavior(),
        ],
      ),
    );
  }

  static List<charts.Series<CounterChart, String>> _createSampleData() {
    final data = counters.map((c) {
      return CounterChart(c.cName, c.cDateHistory.length);
    }).toList();

    return [
      charts.Series<CounterChart, String>(
        id: 'Ripetizioni',
        colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,
        domainFn: (CounterChart sales, _) => sales.name,
        measureFn: (CounterChart sales, _) => sales.count,
        data: data,
      )
    ];
  }
}

class PieChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  PieChart(this.seriesList, {this.animate});

  /// Creates a [BarChart] with sample data and no transition.
  factory PieChart.withSampleData() {
    return PieChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: charts.PieChart(seriesList,
          animate: animate,
          defaultRenderer: new charts.ArcRendererConfig(
              arcRendererDecorators: [new charts.ArcLabelDecorator()])),
    );
  }

  static List<charts.Series<CounterChart, String>> _createSampleData() {
    final data = counters.map((c) {
      return CounterChart(c.cName, c.cDateHistory.length);
    }).toList();

    return [
      charts.Series<CounterChart, String>(
        id: 'Ripetizioni',
        domainFn: (CounterChart sales, _) => sales.name,
        measureFn: (CounterChart sales, _) => sales.count,
        data: data,
      )
    ];
  }
}
