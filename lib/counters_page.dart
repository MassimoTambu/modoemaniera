import 'package:flutter/material.dart';
import 'package:holding_gesture/holding_gesture.dart';
import 'package:modoemaniera/counter_form.dart';

import 'database/db_conn.dart';
import 'models/counters.dart';

class CountersPage extends StatefulWidget {
  const CountersPage({Key key}) : super(key: key);

  @override
  CountersPageState createState() => CountersPageState();
}

class CountersPageState extends State<CountersPage> {
  Future<List<Counter>> future;

  @override
  void initState() {
    if (DatabaseCreator.isConnected) {
      future = RepositoryServiceCounters.getAllCounters();
    } else {
      future = Future.delayed(
        Duration(seconds: 1),
        () => RepositoryServiceCounters.getAllCounters(),
      );
    }
    super.initState();
  }

  void updateCounterList() {
    setState(() {
      future = RepositoryServiceCounters.getAllCounters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FutureBuilder(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
              if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemBuilder: (ctx, index) {
                      return Column(
                        children: <Widget>[
                          if (index == 0) const SizedBox(height: 20),
                          CounterElement(
                            counter: snapshot.data[index],
                            updateCounterList: updateCounterList,
                          ),
                        ],
                      );
                    },
                    itemCount: snapshot.data.length,
                  ),
                );
              } else {
                return Text('Questo messaggio non dovrebbe apparire .-.');
              }
            } else {
              return CircularProgressIndicator();
            }
          },
        ),
      ],
    );
  }
}

class CounterElement extends StatefulWidget {
  const CounterElement({
    Key key,
    @required this.counter,
    @required this.updateCounterList,
  }) : super(key: key);

  final Counter counter;
  final Function updateCounterList;

  @override
  _CounterElementState createState() => _CounterElementState();
}

class _CounterElementState extends State<CounterElement> {
  Counter counter;

  @override
  void initState() {
    counter = widget.counter;
    super.initState();
  }

  Future<bool> onEditCounter(DismissDirection direction) {
    if (direction == DismissDirection.endToStart) {
      showDialog(
        context: context,
        builder: (BuildContext ctx) => CounterForm(counter: counter),
      ).then((result) async {
        if (result is Counter) {
          RepositoryServiceCounters.updateCounter(result);
          widget.updateCounterList();
        }
      });
      return Future.value(false);
    }
    return Future.value(true);
  }

  void onRemoveCounter(DismissDirection direction) {
    if (direction == DismissDirection.startToEnd) {
      setState(() {
        RepositoryServiceCounters.deleteCounter(counter);
      });
      Scaffold.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${counter.name} rimosso",
          ),
        ),
      );
      widget.updateCounterList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        padding: const EdgeInsets.only(left: 20),
        color: Colors.red,
        child: const Align(
          alignment: Alignment.centerLeft,
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      secondaryBackground: Container(
        padding: const EdgeInsets.only(right: 20),
        color: Colors.green,
        child: const Align(
          alignment: Alignment.centerRight,
          child: const Icon(
            Icons.edit,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
      confirmDismiss: (direction) => onEditCounter(direction),
      onDismissed: (direction) => onRemoveCounter(direction),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            CounterLabel(widget.counter.name),
            CounterController(counter: counter),
          ],
        ),
      ),
    );
  }
}

class CounterLabel extends StatelessWidget {
  final counter;

  const CounterLabel(this.counter);

  @override
  Widget build(BuildContext context) {
    return Text(
      counter,
      style: TextStyle(
        fontSize: 18,
      ),
    );
  }
}

class CounterController extends StatefulWidget {
  const CounterController({
    Key key,
    @required this.counter,
  }) : super(key: key);

  final Counter counter;

  @override
  _CounterControllerState createState() => _CounterControllerState();
}

class _CounterControllerState extends State<CounterController> {
  void addDateHistory() async {
    final dh = new DateTime.now();
    await RepositoryServiceHistory.addDate(dh, widget.counter.id);
    setState(() {
      widget.counter.dateHistory.add(dh);
    });
  }

  void removeLastDateHistory() async {
    if (widget.counter.dateHistory.length != 0) {
      await RepositoryServiceHistory.removeLastDate(widget.counter.id);
      setState(() {
        widget.counter.dateHistory.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        HoldDetector(
          holdTimeout: Duration(milliseconds: 100),
          enableHapticFeedback: true,
          onHold: () => addDateHistory(),
          child: IconButton(
            icon: Icon(Icons.add),
            onPressed: () => addDateHistory(),
          ),
        ),
        Container(
          width: 25,
          height: 20,
          child: FittedBox(
            child: Text(
              '${widget.counter.dateHistory.length}',
              style: TextStyle(
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        HoldDetector(
          holdTimeout: Duration(milliseconds: 100),
          enableHapticFeedback: true,
          onHold: () => removeLastDateHistory(),
          child: IconButton(
            icon: Icon(Icons.remove),
            onPressed: () => removeLastDateHistory(),
          ),
        ),
      ],
    );
  }
}
