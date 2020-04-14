import 'package:flutter/material.dart';

import 'package:modoemanierapp/charts_page.dart';
import 'package:modoemanierapp/counter_form.dart';
import 'package:modoemanierapp/history_page.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'counters_page.dart';
import 'database/db_conn.dart';
import 'models/chartEnum.dart';
import 'models/counters.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final DatabaseCreator databaseCreator = new DatabaseCreator();

  @override
  Widget build(BuildContext context) {
    // databaseCreator.deleteDatabase();
    databaseCreator.initDatabase();
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
  final GlobalKey<CountersPageState> _globalKey =
      GlobalKey<CountersPageState>();

  Chart _chartSelected;
  List<Widget> _widgetOptions;

  Text _appBarTitle;
  List<Widget> _appBarButton;
  TabController _tabController;
  FloatingActionButton _floatingActionButton;

  @override
  void initState() {
    initializeDateFormatting("it_IT", null);
    _chartSelected = Chart.Torta;
    _widgetOptions = <Widget>[
      CountersPage(
        key: _globalKey,
      ),
      HistoryPage(),
      ChartsPage(_chartSelected),
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
                  value: Chart.Barre,
                  child: Text('Barre'),
                ),
                const PopupMenuItem<Chart>(
                  value: Chart.Giornata,
                  child: Text('A giornate'),
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
        ).then((result) async {
          if (result is Counter) {
            RepositoryServiceCounters.addCounter(result).then((_) {
              _globalKey.currentState.updateCounterList();
            });
          }
        }),
        child: const Icon(Icons.add),
      );
    });
  }

  void _onChartSelected(Chart c) {
    _chartSelected = c;

    setState(() {
      _widgetOptions = [
        CountersPage(
          key: _globalKey,
        ),
        HistoryPage(),
        ChartsPage(_chartSelected),
      ];
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
        physics: NeverScrollableScrollPhysics(),
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
