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
      home: const DefaultTabController(
        length: 3,
        child: const NavigationMenu(),
      ),
    );
  }
}

class NavigationMenu extends StatefulWidget {
  @override
  _NavigationMenuState createState() => _NavigationMenuState();

  const NavigationMenu();
}

class _NavigationMenuState extends State<NavigationMenu>
    with SingleTickerProviderStateMixin {
  List<Counter> counters = cList.counters;
  int _selectedIndex = 0;
  Chart _chartSelected;
  List<Widget> _widgetOptions;

  Text _appBarTitle;
  List<Widget> _appBarButton;
  TabController _tabController;
  FloatingActionButton _floatingActionButton;

  @override
  void initState() {
    _widgetOptions = <Widget>[
      CountersPage(counters),
      HistoryPage(),
      ChartsPage(),
    ];
    _tabController = new TabController(vsync: this, length: 3);
    setFirstTab();
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        setFirstTab();
      } else if (_tabController.index == 1) {
        setState(() {
          _appBarTitle = Text('Cronologia');
          _appBarButton = null;
          _floatingActionButton = null;
        });
      } else if (_tabController.index == 2) {
        setState(() {
          _appBarTitle = Text('Grafici');
          _appBarButton = [
            PopupMenuButton<Chart>(
              onSelected: (Chart result) {
                _onChartSelected(result);
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<Chart>>[
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
          ];
          _floatingActionButton = null;
        });
      }
    });
    super.initState();
  }

  void setFirstTab() {
    setState(() {
      _appBarTitle = Text('Lista Contatori');
      _appBarButton = null;
      _floatingActionButton = FloatingActionButton(
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
      );
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
        title: _appBarTitle,
        centerTitle: true,
        actions: _appBarButton,
      ),
      body: TabBarView(
        controller: _tabController,
        children: _widgetOptions,
      ),
      floatingActionButton: _floatingActionButton,
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: [
          Tab(
            icon: Icon(Icons.donut_small),
            text: 'Contatori',
          ),
          Tab(
            icon: Icon(Icons.history),
            text: 'Cronologia',
          ),
          Tab(
            icon: Icon(Icons.insert_chart),
            text: 'Grafici',
          ),
        ],
        labelColor: Colors.amber[800],
        unselectedLabelColor: Colors.blueGrey[100],
        indicatorSize: TabBarIndicatorSize.label,
        indicatorPadding: EdgeInsets.all(5.0),
        indicatorColor: Colors.orange,
      ),
    );
  }
}
