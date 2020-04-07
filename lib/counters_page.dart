import 'package:flutter/material.dart';
import 'package:holding_gesture/holding_gesture.dart';
import 'package:modoemaniera/main.dart';

import 'models/counters.dart';

class CountersPage extends StatelessWidget {
  final List<Counter> counters;

  CountersPage(this.counters);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (ctx, index) {
        return CounterController(
          counter: counters[index],
        );
      },
      itemCount: counters.length,
    );
  }
}

class CounterController extends StatefulWidget {
  final Counter counter;

  const CounterController({Key key, @required this.counter}) : super(key: key);

  @override
  _CounterControllerState createState() => _CounterControllerState();
}

class _CounterControllerState extends State<CounterController> {
  Counter counter;

  @override
  void initState() {
    super.initState();
    counter = widget.counter;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          CounterElement(widget.counter.cName),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              HoldDetector(
                holdTimeout: Duration(milliseconds: 100),
                onHold: () {
                  this.setState(
                    () => counter.cDateHistory.add(
                      DateTime.now(),
                    ),
                  );
                },
                child: IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    this.setState(
                      () => counter.cDateHistory.add(
                        DateTime.now(),
                      ),
                    );
                  },
                ),
              ),
              Container(
                width: 25,
                height: 20,
                child: FittedBox(
                  child: Text(
                    '${counter.cDateHistory.length}',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              HoldDetector(
                holdTimeout: Duration(milliseconds: 100),
                onHold: () {
                  if (counter.cDateHistory.length != 0) {
                    this.setState(
                      () => counter.cDateHistory.removeLast(),
                    );
                  }
                },
                child: IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    if (counter.cDateHistory.length != 0) {
                      this.setState(
                        () => counter.cDateHistory.removeLast(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CounterElement extends StatelessWidget {
  final counter;

  const CounterElement(this.counter);

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
