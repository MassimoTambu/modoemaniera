import 'package:flutter/material.dart';

import 'package:modoemaniera/charts_page.dart';
import 'package:modoemaniera/counter_form.dart';
import 'package:modoemaniera/history_page.dart';
import 'package:modoemaniera/models/counters.dart' as cList;
import 'counters_page.dart';
import 'models/chartEnum.dart';
import 'models/counters.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contatori Modo e Maniera',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          accentColor: Colors.amber,
          appBarTheme: AppBarTheme(color: Colors.blue)),
      home: const NavigationMenu(),
    );
  }
}

class NavigationMenu extends StatefulWidget {
  @override
  _NavigationMenuState createState() => _NavigationMenuState();

  const NavigationMenu();
}

class _NavigationMenuState extends State<NavigationMenu> {
  List<Counter> counters = cList.counters;
  int _selectedIndex = 0;
  Chart _chartSelected;
  List<Widget> _widgetOptions;

  @override
  void initState() {
    _widgetOptions = <Widget>[
      CountersPage(counters),
      HistoryPage(),
      ChartsPage(),
    ];
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onChartSelected(Chart c) {
    setState(() {
      _chartSelected = c;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          _selectedIndex == 0
              ? 'Lista Contatori'
              : _selectedIndex == 1 ? 'Cronologia' : 'Grafici',
        ),
        centerTitle: true,
        actions: _selectedIndex == 2
            ? <Widget>[
                PopupMenuButton<Chart>(
                  onSelected: (Chart result) {
                    _onChartSelected(result);
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuEntry<Chart>>[
                    const PopupMenuItem<Chart>(
                      value: Chart.Torta,
                      child: Text('Torta'),
                    ),
                    const PopupMenuItem<Chart>(
                      value: Chart.Coca,
                      child: Text('Coca'),
                    ),
                    const PopupMenuItem<Chart>(
                      value: Chart.Maiale,
                      child: Text('Maiale'),
                    ),
                    const PopupMenuItem<Chart>(
                      value: Chart.Mortaci,
                      child: Text('Mortaci'),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => showDialog(
                context: context,
                builder: (BuildContext ctx) => CounterForm(),
              ).then((result) {
                if (result is Counter) {
                  setState(() {
                    counters.add(result);
                  });
                }
              }),
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.donut_small),
            title: Text('Contatori'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            title: Text('Cronologia'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart),
            title: Text('Grafici'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
