import 'package:flutter/material.dart';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:modoemaniera/models/counters.dart';

import 'models/chartEnum.dart';

class CounterChart {
  CounterChart(this.name, this.count);

  final String name;
  final int count;
}

class DailyCounterChartContainer {
  DailyCounterChartContainer(this.name, this.days);

  final String name;
  final List<DailyCounterChart> days;
}

class DailyCounterChart {
  DailyCounterChart(this.count, this.date);

  final int count;
  final DateTime date;
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
      return DailyChart(DailyChart._createSampleData());
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
      return CounterChart(c.name, c.dateHistory.length);
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
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: charts.PieChart(
        seriesList,
        animate: animate,
        defaultRenderer: new charts.ArcRendererConfig(
          arcRendererDecorators: [new charts.ArcLabelDecorator()],
        ),
      ),
    );
  }

  static List<charts.Series<CounterChart, String>> _createSampleData() {
    final data = counters.map((c) {
      return CounterChart(c.name, c.dateHistory.length);
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

class DailyChart extends StatelessWidget {
  final List<charts.Series> seriesList;
  final bool animate;

  DailyChart(this.seriesList, {this.animate});

  /// Creates a [LineChart] with sample data and no transition.
  factory DailyChart.withSampleData() {
    return new DailyChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: charts.TimeSeriesChart(
        seriesList,
        animate: animate,
        // Configure the default renderer as a line renderer. This will be used
        // for any series that does not define a rendererIdKey.
        //
        // This is the default configuration, but is shown here for  illustration.
        defaultRenderer: new charts.LineRendererConfig(),
        behaviors: [charts.SeriesLegend(desiredMaxColumns: 2)],
      ),
    );
  }

  static List<charts.Series<DailyCounterChart, DateTime>> _createSampleData() {
    final cDays = counters
        .map(
          (c) => Counter(
            c.id,
            c.name,
            [...c.dateHistory.map((dh) => DateTime(dh.year, dh.month, dh.day))],
          ),
        )
        .toList();

    List<DateTime> dateUsed;
    List<DailyCounterChart> dailyCounterChart = [];
    List<DailyCounterChartContainer> data = [];
    cDays.forEach((c) {
      dateUsed = [];
      dailyCounterChart = [];
      c.dateHistory.forEach((dh) {
        if (dateUsed.where((d) => d.difference(dh).inDays == 0).length == 0) {
          dailyCounterChart.add(DailyCounterChart(
            c.dateHistory.where((d) => d.difference(dh).inDays == 0).length,
            dh,
          ));
          dateUsed.add(dh);
        }
      });
      data.add(DailyCounterChartContainer(c.name, dailyCounterChart));
    });

    data.forEach((c) {
      print(c.name);
      c.days.forEach((d) {
        print('${d.date}, ${d.count}');
      });
    });

    int i = 0;
    final sampleData = data.map((chart) {
      final s = charts.Series<DailyCounterChart, DateTime>(
        id: data[i].name,
        domainFn: (DailyCounterChart sales, _) => sales.date,
        measureFn: (DailyCounterChart sales, _) => sales.count,
        data: data[i].days,
      );
      i++;
      return s;
    }).toList();

    return sampleData;
  }
}
