import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modoemaniera/models/datesList.dart';

class HistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    dates.sort(
      (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
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
          '${DateFormat.yMd().format(date)}',
        ),
        trailing: Text('${DateFormat.Hms().format(date)}'),
      ),
    );
  }
}
