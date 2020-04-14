import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modoemanierapp/models/datesList.dart';

import 'models/counters.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    dates = [];
    counters.forEach((c) {
      c.dateHistory.forEach((dh) {
        dates.add({'name': c.name, 'date': dh});
      });
    });

    dates.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );
    return ListView.builder(
      itemBuilder: (ctx, index) {
        return CounterHistory(
          dates[index]['name'],
          dates[index]['date'],
        );
      },
      itemCount: dates.length,
    );
  }
}

class CounterHistory extends StatelessWidget {
  final String name;
  final DateTime date;

  CounterHistory(this.name, this.date);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 5,
      ),
      child: ListTile(
        title: Text(
          '$name',
          style: Theme.of(context).textTheme.title,
        ),
        subtitle: Text(
          '${DateFormat.yMMMMd('it').format(date)}',
        ),
        trailing: Text('${DateFormat.Hms('it').format(date)}'),
      ),
    );
  }
}
