List<Counter> counters = [
  Counter('Maniera', []),
  Counter('Modo e Maniera', []),
  Counter('Modo e Maniera Tale', []),
  Counter('Databeees', []),
];

class Counter {
  final String _name;
  final List<DateTime> _dateHistory;

  Counter(this._name, this._dateHistory);

  String get cName {
    return _name;
  }

  List<DateTime> get cDateHistory {
    return _dateHistory;
  }
}
